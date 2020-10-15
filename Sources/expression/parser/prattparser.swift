enum Expression : CustomStringConvertible {
    case Leaf(Token)
    indirect case Unary(Token, Expression)
    indirect case Binary(Token, Expression, Expression)
    indirect case Block(Token, Expression, [Expression])
    indirect case FuncDef(Token, [Token], [Expression])
    case Invalid(String)

    var description: String
    {
        switch self {
            case .Leaf(let token):
                return String(token.asString)
            case .Unary(let token, let child):
                return "(\(token.asString) \(child.description))"
            case .Binary(let token, let child1, let child2):
                return "(\(token.asString) \(child1.description) \(child2.description))"
            case .Block(let token, let condition, let body):
                var result = "(\(token.asString) \(condition.description) ("
                for b in body {
                    result += b.description
                }
                return result + ")"
            case .Invalid(let message):
                return message
            case .FuncDef(let token, let arguments, let body):
                return "(\(token.asString) \(arguments.description) \(body.description))"
        }
    }
}

func parseStatement(tokens: TokenStream) -> Expression? {
    var result: Expression?
    dropEmptyLines(tokens)
    do {
        result = try parse(tokens: tokens, rbp: 0)
    } catch {
        dropLine(tokens)
        return Expression.Invalid("\(error)")
    }

    if let tok = tokens.front, tok.type == .Delimiter {
        tokens.popFront() // drop the end of line token (Delimiter)
    }
    // if parse returns and the last token ist not end of line the result is invalid
    // this happens in a line like "2+2 1+3"
    else {
        result = Expression.Invalid("Expected newline after statement, but token is: \(tokens.front!)")
        dropLine(tokens)
    }

    return result
}

// This is Pratt's Algorithm
func parse(tokens: TokenStream, rbp: Int) throws -> Expression
{
    guard var left = try tokens.next()?.nud(tokens: tokens) else {
        throw "Reached end of file when expecting expression"
    }

    while let tok = tokens.front, rbp < tok.lbp {
        tokens.popFront()
        left = try tok.led(left: left, tokens: tokens)
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

// When an error occurs while parsing an expression we drop all tokens of that line
private func dropLine(_ tokens: TokenStream) {
    repeat {
        tokens.popFront()
    } while tokens.front != nil && tokens.front!.type != .Delimiter
    tokens.popFront()
}

private func dropEmptyLines(_ tokens: TokenStream) {
    while tokens.front != nil && tokens.front!.type == .Delimiter {
        tokens.popFront()
    }
}