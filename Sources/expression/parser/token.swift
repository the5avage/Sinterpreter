enum TokenType {
    case Identifier
    case Number
    case Operator
    case Delimiter
    case Keyword
    case InvalidToken
}

struct Token : CustomStringConvertible {
    let type: TokenType
    let asString: String
    let numLine: Int
    let numRow: Int
    let lbp: Int

    init(type: TokenType, asString: String, numLine: Int, numRow: Int) {
        self.type = type
        self.asString = asString
        self.numLine = numLine
        self.numRow = numRow
        if type == .Operator, let tmp = leftBindingPower[asString] {
            lbp = tmp
        } else if type == .Identifier || type == .Number || type == .Keyword || type == .Delimiter {
            lbp = 0
        } else {
            lbp = Int.max
        }
    }

    var description: String {
        return "\(type): \"\(asString)\" Line: \(numLine) Row: \(numRow)"
    }

    func nud(tokens: TokenStream) throws -> Expression {
        switch self.type {
            case .Identifier, .Number:
                return parseAtom(self, tokens)
            case .Operator, .Keyword:
                guard let nud = nudTable[self.asString] else {
                    throw "Unknown prefix operator: \(self)"
                }
                return try nud(self, tokens)
            case .InvalidToken:
                throw "\(self)"
            default:
                fatalError("This should never happen.")
        }
    }

    func led(left: Expression, tokens: TokenStream) throws -> Expression {
        switch self.type {
            case .Operator:
                guard let led = ledTable[self.asString] else {
                    throw "Unknown infix operator: \(self)"
                }
                return try led(self, left, tokens)
            case .InvalidToken:
                throw "\(self)"
            default:
                throw "Unknown infix operator: \(self)"
        }
    }
}