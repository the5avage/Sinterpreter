let operatorCharacter: Set<Character> = ["+", "-", "*", "/", "=", "!", "|", "&", "(", ")"]

extension CharStream {
    func matchToken() -> Token? {
        while let c = front {
            switch c {
            case "A" ... "z", "_":
                return matchIdentifierOrKeyword()
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

    private func matchIdentifierOrKeyword() -> Token {
        let source = String(self.take(while: {
            switch $0 {
            case "A" ... "z", "_", "0" ... "9":
                return true
            default:
                return false
            }
        }))
        if keywords.contains(source) {
            return Token(type: TokenType.Keyword,
                            asString: source,
                            numLine: actualLineNumber,
                            numRow: actualRowNumber)
        }
        return Token(type: TokenType.Identifier,
                        asString: source,
                        numLine: actualLineNumber,
                        numRow: actualRowNumber)
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
        return Token(type: TokenType.Number,
                        asString: source,
                        numLine: actualLineNumber,
                        numRow: actualRowNumber)
    }

    private func matchOperator() -> Token {
        let source = String(self.take(while: isOperatorCharacter))
        return Token(type: TokenType.Operator,
                        asString: source,
                        numLine: actualLineNumber,
                        numRow: actualRowNumber)
    }

    private func matchNewline() -> Token {
        return Token(type: TokenType.Delimiter,
                        asString: String(next()!),
                        numLine: actualLineNumber,
                        numRow: actualRowNumber)
    }
}

func isOperatorCharacter(_ c: Character) -> Bool {
    return operatorCharacter.contains(c)
}