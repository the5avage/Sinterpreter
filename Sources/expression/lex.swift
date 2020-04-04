import Range

class TokenStream : ForwardRange {
    typealias Element = Token

    var source: CharStream
    var front: Token?

    init(_ str: Substring) {
        source = CharStream(str)
        front = source.matchToken()
    }

    func popFront() {
        front = source.matchToken()
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
            case "+", "-", "*", "/":
                return matchOperator()
            case " ", "\t", "\n":
                popFront()
            default:
                fatalError("Unexpected character \"\(c)\" Line: \(actualLineNumber) Row: \(actualRowNumber)")
            }
        }
        return nil
    }

    private func matchIdentifier() -> Token {
        let str = String(self.take(while: {
            switch $0 {
            case "A" ... "z", "_", "0" ... "9":
                return true
            default:
                return false
            }
        }))
        return Identifier(asString: str, numLine: actualLineNumber, numRow: actualRowNumber)
    }

    private func matchNumber() -> Token {
        var containsPoint = false
        let str = String(self.take(while: {
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
        return Number(asString: str, numLine: actualLineNumber, numRow: actualRowNumber)
    }

    private func matchOperator() -> Token {
        let str = String(self.take(while: {"+-*/".contains($0)}))
        return Operator(asString: str, numLine: actualLineNumber, numRow: actualRowNumber)
    }
}