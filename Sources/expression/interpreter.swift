import Range

let unaryOperatorAction: [String : (Expression) -> Double] = ["-" : { -evaluate($0) }]

let binaryOperatorAction: [String : (Expression, Expression) -> Double] = [
    "+" : { evaluate($0) + evaluate($1) },
    "-" : { evaluate($0) - evaluate($1) },
    "*" : { evaluate($0) * evaluate($1) },
    "/" : { evaluate($0) / evaluate($1) },
    "=" : assignmentOperatorAction
]

func assignmentOperatorAction(left: Expression, right: Expression) -> Double {
    if case .Leaf(let token) = left, type(of: token) == Identifier.self {
        let result = evaluate(right)
        variables.updateValue(result, forKey: token.asString)
        return result
    }
    fatalError("\(left) is not an L-Value")
}

var variables: [String : Double] = [:]

func evaluate(_ node: Expression) -> Double {
    switch node {
        case .Leaf(let token):
            if type(of: token) == Number.self {
                return Double(token.asString)!
            } else if type(of: token) == Identifier.self {
                guard let result = variables[token.asString] else {
                    fatalError("Variable \(token.asString) was not defined")
                }
                return result
            }
            fatalError("Token \(token) can't be a leaf node")
        case .Unary(let token, let child):
            guard let action = unaryOperatorAction[token.asString] else {
                fatalError("No action for unary operator \(token)")
            }
        return action(child)
        case .Binary(let token, let child1, let child2):
            guard let action = binaryOperatorAction[token.asString] else {
                fatalError("No action for binary operator \(token)")
            }
            return action(child1, child2)
    }
}

struct Interpreter<R: ForwardRange> where R.Element == Character {
    let source: ExpressionStream<R>

    init(source: ExpressionStream<R>) {
        self.source = source
    }

    func run() {
        while let node = source.front {
            print(evaluate(node))
            source.popFront()
        }
    }
}