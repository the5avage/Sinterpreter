let unaryOperatorAction: [String : (Node) -> Double] = ["-" : { -evaluate($0) }]

let binaryOperatorAction: [String : (Node, Node) -> Double] = [
    "+" : { evaluate($0) + evaluate($1) },
    "-" : { evaluate($0) - evaluate($1) },
    "*" : { evaluate($0) * evaluate($1) },
    "/" : { evaluate($0) / evaluate($1) },
    "=" : assignmentOperatorAction
]

func assignmentOperatorAction(left: Node, right: Node) -> Double {
    if type(of: left.token) != Identifier.self || left.children.count != 0 {
        fatalError("\(left) is not an L-Value")
    }
    let result = evaluate(right)
    variables.updateValue(result, forKey: left.token.asString)
    return result
}

var variables: [String : Double] = [:]

func evaluate(_ node: Node) -> Double {
    if node.children.count == 0 {
        if type(of: node.token) == Number.self {
            return Double(node.token.asString)!
        } else if type(of: node.token) == Identifier.self {
            return variables[node.token.asString]!
        }
        fatalError("Token \(node.token) can't be a leaf node")
    } else if node.children.count == 1 {
        guard let action = unaryOperatorAction[node.token.asString] else {
            fatalError("No action for unary operator \(node.token)")
        }
        return action(node.children[0])
    } else if node.children.count == 2 {
        guard let action = binaryOperatorAction[node.token.asString] else {
            fatalError("No action for binary operator \(node.token)")
        }
        return action(node.children[0], node.children[1])
    }
    fatalError("There are no operators with more than 2 children yet")
}

struct Interpreter<S: Sequence> where S.Element == Character {
    let source: NodeStream<S>

    init(source: NodeStream<S>) {
        self.source = source
    }

    func run() {
        while let node: Node = source.next() {
            print(evaluate(node))
        }
    }
}