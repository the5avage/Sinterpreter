enum Expression : CustomStringConvertible {
    case Leaf(Token)
    indirect case Unary(Token, Expression)
    indirect case Binary(Token, Expression, Expression)

    var description: String
    {
        switch self {
            case .Leaf(let token):
                return String(token.asString)
            case .Unary(let token, let child):
                return "(\(token.asString) \(child.description))"
            case .Binary(let token, let child1, let child2):
                return "(\(token.asString) \(child1.description) \(child2.description))"
        }
    }
}

func parseStatement(tokens: TokenStream) -> Expression? {
    let result = parse(tokens: tokens, rbp: 0)
    if let tok = tokens.front, tok.type != .Delimiter {
        fatalError("Expected newline after statement: \(tokens.front!)")
    } else {
        tokens.popFront()
    }
    return result
}

func parse(tokens: TokenStream, rbp: Int) -> Expression?
{
    guard var left = tokens.next()?.nud(tokens: tokens) else {
        return nil
    }
    while let tok = tokens.front, rbp < tok.lbp {
        tokens.popFront()
        left = tok.led(left: left, tokens: tokens)
    }
    return left
}

struct Tree : CustomStringConvertible
{
    var children: [Expression] = []

    init(from: ExpressionStream) {
        for node in from {
            children.append(node)
        }
    }

    var description: String {
        var result = ""
        for child in children {
            result.append("\(child.description)\n")
        }
        return result
    }
}