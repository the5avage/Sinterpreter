enum TokenType {
    case Identifier
    case Number
    case Operator
    case Delimiter
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
        if type == .Operator {
            guard let tmp = leftBindingPower[asString] else {
                lbp = 0
                fatalError("Unknown Operator: \(self)")
            }
            lbp = tmp
        } else {
            lbp = 0
        }
    }

    var description: String {
        return "\(type): \"\(asString)\" Line: \(numLine) Row: \(numRow)"
    }

    func nud(tokens: TokenStream) -> Expression {
        switch self.type {
            case .Identifier, .Number:
                return Expression.Leaf(self)
            case .Operator:
                guard let nud = nudTable[self.asString] else {
                    fatalError("No prefix operator: \(self)")
                }
                return nud(self, tokens)
            default:
                fatalError("Nud not implemented: \(self)")
        }
    }

    func led(left: Expression, tokens: TokenStream) -> Expression {
        switch self.type {
            case .Operator:
                guard let led = ledTable[self.asString] else {
                    fatalError("No infix operator: \(self)")
                }
                return led(self, left, tokens)
            default:
                fatalError("Led not implemented. \(self)")
        }
    }
}