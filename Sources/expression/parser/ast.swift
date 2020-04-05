struct Node : CustomStringConvertible
{
    var token: Token
    var children: [Node] = []

    init(token: Token)
    {
        self.token = token
    }

    var description: String
    {
        if children.isEmpty {
            return String(token.asString)
        }
        var result = "(\(token.asString)"
        for child in children {
            result.append(" \(child.description)")
        }
        result.append(")")
        return result
    }
}

func parseStatement<T>(tokens: TokenStream<T>) -> Node? {
    let result = parse(tokens: tokens, rbp: 0)
    if tokens.front != nil && type(of: tokens.front!) != Delimiter.self {
        fatalError("Expected newline after statement: \(tokens.front!)")
    } else {
        tokens.popFront()
    }
    return result
}

func parse<T>(tokens: TokenStream<T>, rbp: Int) -> Node?
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
    var children: [Node] = []

    init<T>(tokens: TokenStream<T>)
    {
        while let node = parse(tokens: tokens, rbp: 0) {
            children.append(node)
        }
    }

    var description: String
    {
        var result = ""
        for child in children {
            result.append("\(child.description)\n")
        }
        return result
    }
}