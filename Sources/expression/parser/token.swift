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

    func nud<T>(tokens: TokenStream<T>) -> Expression
    {
        fatalError("Nud not implemented. \(String(describing: type(of: self))) \(asString)")
    }

    func led<T>(left: Expression, tokens: TokenStream<T>) -> Expression
    {
        fatalError("Led not implemented. \(String(describing: type(of: self)))")
    }
}

class Identifier : Token
{
    override func nud<T>(tokens: TokenStream<T>) -> Expression {
        return Expression.Leaf(self)
    }
}

class Operator : Token
{
    var isRightAssociative: Int = 0

    override init(asString: String, numLine: Int, numRow: Int)
    {
        super.init(asString: asString, numLine: numLine, numRow: numRow)
        guard let lbp = leftBindingPower[asString] else {
            fatalError("Unknown operator: \(self)")
        }
        self.lbp = lbp
        if rightAssociativeOperators.contains(asString) {
            isRightAssociative = 1
        }
    }

    override func nud<T>(tokens: TokenStream<T>) -> Expression {
        if !prefixOperators.contains(asString) {
            fatalError("No prefix operator: \(self)")
        }
        return Expression.Unary(self, parse(tokens: tokens, rbp: 30)!)
    }

    override func led<T>(left: Expression, tokens: TokenStream<T>) -> Expression {
        return Expression.Binary(self, left, parse(tokens: tokens, rbp: lbp - isRightAssociative)!)
    }
}

class Number : Token
{
    override func nud<T>(tokens: TokenStream<T>) -> Expression {
        return Expression.Leaf(self)
    }
}

class InvalidToken : Token
{}

class Delimiter : Token
{
    override init(asString: String, numLine: Int, numRow: Int) {
        super.init(asString: asString, numLine: numLine, numRow: numRow)
        self.lbp = -1
    }
}

let leftBindingPower: [String: Int] = ["=" : 5, "+" : 10, "-" : 10, "*" : 20, "/" : 20]
let rightAssociativeOperators: [String] = ["="]
let prefixOperators = ["-"]