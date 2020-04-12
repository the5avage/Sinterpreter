let nudTable: [String : (Token, TokenStream) -> Expression] = [
    "-" : nudPrefixOperator(30),
    "exit" : {
        if $1.front!.type != TokenType.Delimiter {
            fatalError("Expected newline after \($0)")
        }
        return parseAtom($0, $1)
    },
    "true" : parseAtom,
    "false" : parseAtom]

let ledTable: [String : (Token, Expression, TokenStream) -> Expression] = [
    "=" : ledOperatorRight(),
    "+" : ledOperator(),
    "-" : ledOperator(),
    "*" : ledOperator(),
    "/" : ledOperator()]

let leftBindingPower: [String : Int] = [
    "=" : 5,
    "+" : 10,
    "-" : 10,
    "*" : 20,
    "/" : 20]

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