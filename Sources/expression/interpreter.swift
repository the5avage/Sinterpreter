import Range

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

let unaryOperatorAction: [String : (Expression) -> Type] = [
    "-" : unaryActionDouble(-),
    "!" : unaryActionBool(!)]

let binaryOperatorAction: [String : (Expression, Expression) -> Type] = [
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
var variables: [String : Type] = [:]

// declared functions
var unaryFunctions: [String : (Expression) -> Type] = ["addTwo" : unaryActionDouble({ $0 + 2})]

var binaryFunctions: [String : (Expression, Expression) -> Type] = ["addTwo" : binaryActionDouble({ $0 + $1})]

func unaryActionDouble(_ action: @escaping (Double) -> (Double)) -> (Expression) -> Type {
    return {
        if case let Type.Double(a) = evaluate($0) {
            return Type.Double(action(a))
        }
        fatalError("Expected argument of type double: \($0)")
    }
}

func unaryActionBool(_ action: @escaping (Bool) -> (Bool)) -> (Expression) -> Type {
    return {
        if case let Type.Bool(a) = evaluate($0) {
            return Type.Bool(action(a))
        }
        fatalError("Expected argument of type bool: \($0)")
    }
}


func binaryActionDouble(_ action: @escaping (Double, Double) -> (Double)) -> (Expression, Expression) -> Type {
    return {
        if case let Type.Double(a) = evaluate($0), case let Type.Double(b) = evaluate($1) {
            return Type.Double(action(a, b))
        }
        fatalError("Expected arguments of type double: \($0) \($1)")
    }
}

func binaryActionDoubleToBool(_ action: @escaping (Double, Double) -> (Bool)) -> (Expression, Expression) -> Type {
    return {
        if case let Type.Double(a) = evaluate($0), case let Type.Double(b) = evaluate($1) {
            return Type.Bool(action(a, b))
        }
        fatalError("Expected arguments of type double: \($0) \($1)")
    }
}

func binaryActionBool(_ action: @escaping (Bool, Bool) -> (Bool)) -> (Expression, Expression) -> Type {
    return {
        if case let Type.Bool(a) = evaluate($0), case let Type.Bool(b) = evaluate($1) {
            return Type.Bool(action(a, b))
        }
        fatalError("Expected arguments of type bool: \($0) \($1)")
    }
}

func assignmentOperatorAction(left: Expression, right: Expression) -> Type {
    if case .Leaf(let token) = left, token.type == .Identifier {
        let result = evaluate(right)
        variables.updateValue(result, forKey: token.asString)
        return result
    }
    fatalError("\(left) is not an L-Value")
}


func evaluate(_ node: Expression) -> Type {
    switch node {
        case .Leaf(let token):
            switch token.type {
                case .Number:
                    return Type.Double(Double(token.asString)!)
                case .Identifier:
                    guard let result = variables[token.asString] else {
                        fatalError("Variable \(token.asString) was not defined")
                    }
                    return result
                case .Keyword:
                    if token.asString == "true" {
                        return Type.Bool(true)
                    } else if token.asString == "false" {
                        return Type.Bool(false)
                    }
                    fallthrough
                default:
                    fatalError("Token \(token) can't be a leaf node")
            }
        case .Unary(let token, let child):
            switch token.type {
                case .Operator:
                    guard let action = unaryOperatorAction[token.asString] else {
                        fatalError("No action for unary operator \(token)")
                    }
                    return action(child)
                case .Identifier:
                    guard let action = unaryFunctions[token.asString] else {
                        fatalError("Function \(token) was not defined")
                    }
                    return action(child)
                default:
                    fatalError("Expected operator or function \(token)")
            }
        case .Binary(let token, let child1, let child2):
            switch token.type {
                case .Operator:
                    guard let action = binaryOperatorAction[token.asString] else {
                        fatalError("No action for binary operator \(token)")
                    }
                    return action(child1, child2)
                case .Identifier:
                    guard let action = binaryFunctions[token.asString] else {
                        fatalError("Function \(token) was not defined")
                    }
                    return action(child1, child2)
                default:
                    fatalError("Expected operator or function \(token)")
            }
        case .Block(let token, let condition, let body):
            if token.asString == "if" {
                guard case let Type.Bool(test) = evaluate(condition) else {
                    fatalError("Condition of if statement must evaluate to type bool.")
                }
                var result = Type.Bool(test)
                if test {
                    for b in body {
                        result = evaluate(b)
                    }
                }
                return result
            } else if token.asString == "while" {
                guard case var Type.Bool(test) = evaluate(condition) else {
                    fatalError("Condition of while statement must evaluate to type bool.")
                }
                var result = Type.Bool(test)
                while test {
                    for b in body {
                        result = evaluate(b)
                    }
                    guard case let Type.Bool(test2) = evaluate(condition) else {
                        fatalError("Condition of while statement must evaluate to type bool.")
                    }
                    test = test2
                }
                return result
            } else {
                fatalError("Expected while or if statement instead of \(token)")
            }
    }
}

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
            print(evaluate(node))
            source.popFront()
        }
    }
}