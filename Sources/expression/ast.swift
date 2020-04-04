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

func parse(tokens: TokenStream, rbp: Int) -> Node?
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

    init(tokens: TokenStream)
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