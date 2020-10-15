import Range

struct Interpreter {
    let source: ExpressionStream

    init(source: ExpressionStream) {
        self.source = source
    }

    func run() {
        while let node = source.front {
            if case let Expression.Leaf(token) = node, token.asString == "exit" {
                break
            }
            do {
                print(try evaluate(node))
            } catch {
                print("Error: \(error)")
            }
            source.popFront()
        }
    }
}

enum Type : CustomStringConvertible {
    case Double(Double)
    case Bool(Bool)

    var description: String {
        switch self {
            case .Double(let d):
                return String(d)
            case .Bool(let b):
                return String(b)
        }
    }
}

let unaryOperatorAction: [String : (Expression) throws -> Type] = [
    "-" : unaryActionDouble(-),
    "!" : unaryActionBool(!)]

let binaryOperatorAction: [String : (Expression, Expression) throws -> Type] = [
    "+" : binaryActionDouble(+),
    "-" : binaryActionDouble(-),
    "*" : binaryActionDouble(*),
    "/" : binaryActionDouble(/),
    "=" : assignmentOperatorAction,
    "==" : binaryActionBool(==),
    "!=" : binaryActionBool(!=),
    "&&" : binaryActionBool({$0 && $1}),
    "||" : binaryActionBool({$0 || $1}),
    "<" : binaryActionDoubleToBool({$0 < $1}),
    ">" : binaryActionDoubleToBool({$0 > $1})
]

// global variables
//var variables: [String : Type] = [:]

typealias Scope = [String : Type]

struct Stack {
    private var stack: [Scope] = [[:]]

    mutating func push(_ a: Scope) {
        stack.append(a)
    }

    mutating func pop() {
        stack.removeLast()
    }

    func getValue(_ name: String) throws -> Type {
        for scope in stack.lazy.reversed() {
            guard let found = scope[name] else {
                continue
            }
            return found
        }
        throw "Unknown variable \"\(name)\""
    }

    mutating func setValue(_ name: String, _ value: Type) {
        stack[stack.count - 1][name] = value
    }
}

private var stack = Stack()

private struct FunctionKey : Hashable {
    var name: String
    var arity: Int
}

private struct FunctionObject {
    var paramNames: [String]
    var fun: () throws -> Type

    func call(_ param: [Type]) throws -> Type {
        var stackFrame: Scope = [:]
        for i in 0 ..< param.count {
            stackFrame[paramNames[i]] = param[i]
        }
        stack.push(stackFrame)
        let result = try fun()
        stack.pop()
        return result
    }
}

private var defFunctions : [FunctionKey : FunctionObject] = [:]

// declared functions
var unaryFunctions: [String : (Expression) throws -> Type] = ["addTwo" : unaryActionDouble({ $0 + 2})]

var binaryFunctions: [String : (Expression, Expression) throws -> Type] = ["addTwo" : binaryActionDouble({ $0 + $1})]

func unaryActionDouble(_ action: @escaping (Double) -> (Double)) -> (Expression) throws -> Type {
    return {
        if case let Type.Double(a) = try evaluate($0) {
            return Type.Double(action(a))
        }
        throw "Expected argument of type double: \($0)"
    }
}

func unaryActionBool(_ action: @escaping (Bool) -> (Bool)) -> (Expression) throws -> Type {
    return {
        if case let Type.Bool(a) = try evaluate($0) {
            return Type.Bool(action(a))
        }
        throw "Expected argument of type bool: \($0)"
    }
}

func binaryActionDouble(_ action: @escaping (Double, Double) -> (Double)) -> (Expression, Expression) throws -> Type {
    return {
        if case let Type.Double(a) = try evaluate($0), case let Type.Double(b) = try evaluate($1) {
            return Type.Double(action(a, b))
        }
        throw "Expected arguments of type double: \($0) \($1)"
    }
}

func binaryActionDoubleToBool(_ action: @escaping (Double, Double) -> (Bool)) -> (Expression, Expression) throws -> Type {
    return {
        if case let Type.Double(a) = try evaluate($0), case let Type.Double(b) = try evaluate($1) {
            return Type.Bool(action(a, b))
        }
        throw "Expected arguments of type double: \($0) \($1)"
    }
}

func binaryActionBool(_ action: @escaping (Bool, Bool) -> (Bool)) -> (Expression, Expression) throws -> Type {
    return {
        if case let Type.Bool(a) = try evaluate($0), case let Type.Bool(b) = try evaluate($1) {
            return Type.Bool(action(a, b))
        }
        throw "Expected arguments of type bool: \($0) \($1)"
    }
}

func assignmentOperatorAction(left: Expression, right: Expression) throws -> Type {
    if case .Leaf(let token) = left, token.type == .Identifier {
        let result = try evaluate(right)
        stack.setValue(token.asString, result)
        return result
    }
    throw "\(left) is not an L-Value"
}

func evaluate(_ node: Expression) throws -> Type {
    switch node {
        case .Leaf(let token):
            return try evaluateLeaf(token)
        case .Unary(let token, let child):
            return try evaluateUnary(token, child)
        case .Binary(let token, let child1, let child2):
            return try evaluateBinary(token, child1, child2)
        case .Block(let token, let condition, let body):
            return try evaluateBlock(token, condition, body)
        case .FuncDef(let token, let args, let body):
            return try evaluateFuncDef(token, args, body)
        case .Invalid(let message):
            throw message
    }
}

func evaluateLeaf(_ token: Token) throws  -> Type {
    switch token.type {
        case .Number:
            return Type.Double(Double(token.asString)!)
        case .Identifier:
            let result = try stack.getValue(token.asString)
            return result
        case .Keyword:
            if token.asString == "true" {
                return Type.Bool(true)
            } else if token.asString == "false" {
                return Type.Bool(false)
            }
            fallthrough
        default:
            throw "Token \(token) can't be a leaf node"
    }
}

func evaluateUnary(_ token: Token, _ child: Expression) throws -> Type {
    switch token.type {
        case .Operator:
            return try evaluateUnaryOperator(token, child)
        case .Identifier:
            return try evaluateUnaryFunc(token, child)
        default:
            throw "Expected operator or function \(token)"
    }
}

func evaluateBinary(_ token: Token, _ child1: Expression, _ child2: Expression) throws -> Type {
    switch token.type {
        case .Operator:
            return try evaluateBinaryOperator(token, child1, child2)
        case .Identifier:
            return try evaluateBinaryFunc(token, child1, child2)
        default:
            throw "Expected operator or function \(token)"
    }
}

func evaluateBlock(_ token: Token, _ condition: Expression, _ body: [Expression]) throws -> Type {
    if token.asString == "if" {
        return try evaluateIf(token, condition, body)
    } else if token.asString == "while" {
        return try evaluateWhile(token, condition, body)
    } else {
        throw "Expected while or if statement instead of \(token)"
    }
}

func evaluateFuncDef(_ token: Token, _ args: [Token], _ body: [Expression]) throws -> Type {
    let key = FunctionKey(name: token.asString, arity: args.count)

    let obj = FunctionObject(paramNames: args.map({$0.asString}),
                             fun: {
                                var result = Type.Bool(false)
                                for e in body {
                                    result = try evaluate(e)
                                }
                                return result
                             })

    defFunctions[key] = obj

    return Type.Bool(true)
}

func evaluateUnaryOperator(_ token: Token, _ child: Expression) throws -> Type {
    guard let action = unaryOperatorAction[token.asString] else {
        throw "No action for unary operator \(token)"
    }
    return try action(child)
}

func evaluateUnaryFunc(_ token: Token, _ child: Expression) throws -> Type {
    // because we will allow to redefine functions, it makes sense to allow hiding builtin functions
    // that's why we first try to find the function in defFunctions
    guard let userFunc = defFunctions[FunctionKey(name: token.asString, arity: 1)] else {
        guard let builtinFunc = unaryFunctions[token.asString] else {
            throw "Function \(token) was not defined"
        }
        return try builtinFunc(child)
    }
    return try userFunc.call([try evaluate(child)])
}

func evaluateBinaryOperator(_ token: Token, _ child1: Expression, _ child2: Expression) throws -> Type {
    guard let action = binaryOperatorAction[token.asString] else {
        throw "No action for binary operator \(token)"
    }
    return try action(child1, child2)
}

func evaluateBinaryFunc(_ token: Token, _ child1: Expression, _ child2: Expression) throws -> Type {
    // because we will allow to redefine functions, it makes sense to allow hiding builtin functions
    // that's why we first try to find the function in defFunctions
    guard let userFunc = defFunctions[FunctionKey(name: token.asString, arity: 2)] else {
        guard let builtinFunc = binaryFunctions[token.asString] else {
            throw "Function \(token) was not defined"
        }
        return try builtinFunc(child1, child2)
    }
    return try userFunc.call([try evaluate(child1), try evaluate(child2)])
}

func evaluateIf(_ token: Token, _ condition: Expression, _ body: [Expression]) throws -> Type {
    guard case let Type.Bool(test) = try evaluate(condition) else {
        throw "Condition of if statement must evaluate to type bool."
    }
    var result = Type.Bool(test)
    if test {
        for b in body {
            result = try evaluate(b)
        }
    }
    return result
}

func evaluateWhile(_ token: Token, _ condition: Expression, _ body: [Expression]) throws -> Type {
    guard case var Type.Bool(test) = try evaluate(condition) else {
        throw "Condition of while statement must evaluate to type bool."
    }
    var result = Type.Bool(test)
    while test {
        for b in body {
            result = try evaluate(b)
        }
        guard case let Type.Bool(test2) = try evaluate(condition) else {
            throw "Condition of while statement must evaluate to type bool."
        }
        test = test2
    }
    return result
}
