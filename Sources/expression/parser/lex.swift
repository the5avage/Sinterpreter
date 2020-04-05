import Range

class TokenStream<R: ForwardRange> : ForwardRange where R.Element == Character {
    typealias Element = Token

    var source: CharStream<R>
    var _front: Token?

    var frontIsValid: Bool = false

    var front: Token? {
        if !frontIsValid {
            _front = source.matchToken()
            frontIsValid = true
        }
        return _front
    }

    init(from: CharStream<R>) {
        source = from
    }

    func popFront() {
        frontIsValid = false
    }
}

extension CharStream {
    func matchToken() -> Token? {
        while let c = front {
            switch c {
            case "A" ... "z", "_":
                return matchIdentifier()
            case "0" ... "9":
                return matchNumber()
            case _ where isOperatorCharacter(c):
                return matchOperator()
            case "\n":
                return matchNewline()
            case " ", "\t":
                popFront()
            default:
                fatalError("Unexpected character \"\(c)\" Line: \(actualLineNumber) Row: \(actualRowNumber)")
            }
        }
        return nil
    }

    private func matchIdentifier() -> Token {
        let source = String(self.take(while: {
            switch $0 {
            case "A" ... "z", "_", "0" ... "9":
                return true
            default:
                return false
            }
        }))
        return Identifier(asString: source, numLine: actualLineNumber, numRow: actualRowNumber)
    }

    private func matchNumber() -> Token {
        var containsPoint = false
        let source = String(self.take(while: {
            switch $0 {
            case "0" ... "9":
                return true
            case ".":
                if (containsPoint) {
                    return false
                } else {
                    containsPoint = true
                    return true
                }
            default:
                return false
            }
        }))
        return Number(asString: source, numLine: actualLineNumber, numRow: actualRowNumber)
    }

    private func matchOperator() -> Token {
        let source = String(self.take(while: isOperatorCharacter))
        return Operator(asString: source, numLine: actualLineNumber, numRow: actualRowNumber)
    }

    private func matchNewline() -> Token {
        return Delimiter(asString: String(next()!), numLine: actualLineNumber, numRow: actualRowNumber)
    }
}

func isOperatorCharacter(_ c: Character) -> Bool {
    return "+-*/=".contains(c)
}