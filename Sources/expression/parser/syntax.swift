let nudTable: [String : (Token, TokenStream) -> Expression] = ["-" : nudPrefixOperator(30)]

let ledTable: [String : (Token, Expression, TokenStream) -> Expression] = [
    "=" : ledOperatorRight(),
    "+" : ledOperator(),
    "-" : ledOperator(),
    "*" : ledOperator(),
    "/" : ledOperator()]

let leftBindingPower: [String: Int] = ["=" : 5, "+" : 10, "-" : 10, "*" : 20, "/" : 20]

func nudPrefixOperator(_ rbp: Int) -> (Token, TokenStream) -> Expression {
    return { Expression.Unary($0, parse(tokens: $1, rbp: rbp)!)}
}

func ledOperator() -> (Token, Expression, TokenStream) -> Expression {
    return { Expression.Binary($0, $1, parse(tokens: $2, rbp: $0.lbp)!) }
}

func ledOperatorRight() -> (Token, Expression, TokenStream) -> Expression {
    return { Expression.Binary($0, $1, parse(tokens: $2, rbp: $0.lbp - 1)!) }
}