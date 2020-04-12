let nudTable: [String : (Token, TokenStream) -> Expression] = [
    "-" : nudPrefixOperator(70),
    "exit" : {
        if $1.front!.type != TokenType.Delimiter {
            fatalError("Expected newline after \($0)")
        }
        return parseAtom($0, $1)
    },
    "true" : parseAtom,
    "false" : parseAtom,
    "!" : nudPrefixOperator(70)]

let ledTable: [String : (Token, Expression, TokenStream) -> Expression] = [
    "=" : ledOperatorRight(),
    "+" : ledOperator(),
    "-" : ledOperator(),
    "*" : ledOperator(),
    "/" : ledOperator(),
    "==" : ledOperator(),
    "!=" : ledOperator(),
    "&&" : ledOperator(),
    "||" : ledOperator()]

let leftBindingPower: [String : Int] = [
    "=" : 10,
    "||" : 20,
    "&&" : 30,
    "==" : 40,
    "!=" : 40,
    "+" : 50,
    "-" : 50,
    "*" : 60,
    "/" : 60]

let keywords: Set = ["exit", "true", "false"]

func parseAtom(_ tok: Token, _ tokens: TokenStream) -> Expression {
    return Expression.Leaf(tok)
}

func nudPrefixOperator(_ rbp: Int) -> (Token, TokenStream) -> Expression {
    return { Expression.Unary($0, parse(tokens: $1, rbp: rbp)!)}
}

func ledOperator() -> (Token, Expression, TokenStream) -> Expression {
    return { Expression.Binary($0, $1, parse(tokens: $2, rbp: $0.lbp)!) }
}

func ledOperatorRight() -> (Token, Expression, TokenStream) -> Expression {
    return { Expression.Binary($0, $1, parse(tokens: $2, rbp: $0.lbp - 1)!) }
}