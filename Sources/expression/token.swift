class Token : CustomStringConvertible
{
    let asString: String
    let numLine: Int
    let numRow: Int
    var lbp: Int = 0

    init(asString: String, numLine: Int, numRow: Int)
    {
        self.asString = asString
        self.numLine = numLine
        self.numRow = numRow
    }

    var description: String
    {
        return "\(String(describing: type(of: self))): \"\(asString)\" Line: \(numLine) Row: \(numRow)"
    }

    func nud(tokens: inout ArraySlice<Token>) -> Node
    {
        fatalError("Nud not implemented. \(String(describing: type(of: self))) \(asString)")
    }

    func led(left: Node, tokens: inout ArraySlice<Token>) -> Node
    {
        fatalError("Led not implemented. \(String(describing: type(of: self)))")
    }

    func nud(tokens: TokenStream) -> Node
    {
        fatalError("Nud not implemented. \(String(describing: type(of: self))) \(asString)")
    }

    func led(left: Node, tokens: TokenStream) -> Node
    {
        fatalError("Led not implemented. \(String(describing: type(of: self)))")
    }
}

class Identifier : Token
{
    override func nud(tokens: inout ArraySlice<Token>) -> Node {
        return Node(token: self)
    }

    override func nud(tokens: TokenStream) -> Node {
        return Node(token: self)
    }
}

class Operator : Token
{
    override init(asString: String, numLine: Int, numRow: Int)
    {
        super.init(asString: asString, numLine: numLine, numRow: numRow)
        guard let lbp = leftBindingPower[asString] else {
            fatalError("Unknown operator: \(self)")
        }
        self.lbp = lbp
    }

    override func nud(tokens: TokenStream) -> Node {
        if !prefixOperators.contains(asString) {
            fatalError("No prefix operator: \(self)")
        }
        var result = Node(token: self)
        result.children.append(parse(tokens: tokens, rbp: 30)!)
        return result
    }

    override func led(left: Node, tokens: TokenStream) -> Node {
        var result = Node(token: self)
        result.children.append(left)
        result.children.append(parse(tokens: tokens, rbp: lbp)!)
        return result
    }
}

class Number : Token
{
    override func nud(tokens: inout ArraySlice<Token>) -> Node {
        return Node(token: self)
    }

    override func nud(tokens: TokenStream) -> Node {
        return Node(token: self)
    }
}

class InvalidToken : Token
{}

let leftBindingPower: [String: Int] = ["+" : 10, "-" : 10, "*" : 20, "/" : 20]
let prefixOperators = ["-"]