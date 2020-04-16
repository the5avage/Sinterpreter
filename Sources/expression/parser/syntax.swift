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
    "!" : nudPrefixOperator(70),
    "(" : {
        let result = parse(tokens: $1, rbp: 0)!
        if $1.front!.asString != ")" {
            fatalError("Expected ) not: \($0)")
        }
        $1.popFront()
        return result
    }]

let ledTable: [String : (Token, Expression, TokenStream) -> Expression] = [
    "=" : ledOperatorRight,
    "+" : ledOperator,
    "-" : ledOperator,
    "*" : ledOperator,
    "/" : ledOperator,
    "==" : ledOperator,
    "!=" : ledOperator,
    "&&" : ledOperator,
    "||" : ledOperator,
    ">" : ledOperator,
    "<" : ledOperator]

let leftBindingPower: [String : Int] = [
    "=" : 10,
    "||" : 20,
    "&&" : 30,
    "==" : 40,
    "!=" : 40,
    "<" : 45,
    ">" : 45,
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

func ledOperator(_ tok: Token, _ exp: Expression, _ tokens: TokenStream) -> Expression {
    return Expression.Binary(tok, exp, parse(tokens: tokens, rbp: tok.lbp)!)
}

func ledOperatorRight(_ tok: Token, _ exp: Expression, _ tokens: TokenStream) -> Expression {
    return Expression.Binary(tok, exp, parse(tokens: tokens, rbp: tok.lbp - 1)!)
}