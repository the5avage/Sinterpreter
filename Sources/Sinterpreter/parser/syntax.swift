let keywords: Set = ["exit", "true", "false", "if", "end", "while", "def"]

/*
All combinations of this chars are valid operators. "!=" is an operator.
"=*+/" is also parsed as ONE operator as long as there are no spaces in between.
This lets us define arbitrary operators.
To define a valid operator we to have to specify a "leftBindingPower" and the
functions "nud" and "led".
*/
let operatorCharacter: Set<Character> = ["+", "-", "*", "/", "=", "!", "|", "&", "(", "<", ">"]

// these operators are parsed seperatly without needing spaces in between
let specialOperators: Set<Character> = [",", ")"]

let nudTable: [String : (Token, TokenStream) throws -> Expression] = [
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
        let result = try parse(tokens: $1, rbp: 0)
        if $1.front!.asString != ")" {
            fatalError("Expected ) not: \($0)")
        }
        $1.popFront()
        return result
    },
    "if" : parseIfWhile,
    "while" : parseIfWhile,
    "def" : parseFuncDef]

let ledTable: [String : (Token, Expression, TokenStream) throws -> Expression] = [
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
    "<" : ledOperator,
    "(" : parseFunctionCall]

let leftBindingPower: [String : Int] = [
    ")" : 0,
    "," : 0,
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
    "/" : 60,
    "(" : 70]

func parseAtom(_ tok: Token, _ tokens: TokenStream) -> Expression {
    return Expression.Leaf(tok)
}

func nudPrefixOperator(_ rbp: Int) -> (Token, TokenStream) throws -> Expression {
    return { Expression.Unary($0, try parse(tokens: $1, rbp: rbp))}
}

func ledOperator(_ tok: Token, _ exp: Expression, _ tokens: TokenStream) throws -> Expression {
    return Expression.Binary(tok, exp, try parse(tokens: tokens, rbp: tok.lbp))
}

func ledOperatorRight(_ tok: Token, _ exp: Expression, _ tokens: TokenStream) throws -> Expression {
    return Expression.Binary(tok, exp, try parse(tokens: tokens, rbp: tok.lbp - 1))
}

func parseFunctionCall(_ tok: Token, _ exp: Expression, _ tokens: TokenStream) throws -> Expression {
    guard case let Expression.Leaf(funName) = exp, funName.type == TokenType.Identifier else {
        throw "Expected identifier at the left to function call operator\ninstead of \(exp)"
    }
    let args: [Expression] = try parseArgumentList(tokens)
    return Expression.FuncCall(funName, args)
}

private func parseIfWhile(_ tok: Token, _ tokens: TokenStream) -> Expression {
    let condition = parseStatement(tokens: tokens)!
    let body = parseBlock(tokens)
    return Expression.Block(tok, condition, body)
}

private func parseBlock(_ tokens: TokenStream) -> [Expression] {
    var result: [Expression] = []
    while tokens.front!.asString != "end" {
        result.append(parseStatement(tokens: tokens)!)
    }
    tokens.popFront() // remove "end" token
    return result
}

private func parseArgumentList(_ tokens: TokenStream) throws -> [Expression] {
    var result: [Expression] = []
    var run: Bool = true

    repeat {
        result.append(try parse(tokens: tokens, rbp: 0))
        guard let seperator = tokens.front else {
            throw "Reached end of file when expecting identifier"
        }
        if seperator.asString == ")" {
            run = false
        } else if seperator.asString != "," {
            throw "Expected \",\" or \")\" instead of \(seperator)"
        }
        tokens.popFront()
    } while run

    return result
}

private func parseFuncDef(_ tok: Token, _ tokens: TokenStream) throws -> Expression {
    guard let name = tokens.front, .Identifier == name.type else {
        throw "Expected identifier (function name) after \"def\" keyword"
    }
    tokens.popFront()

    guard let openBrace = tokens.front, openBrace.asString == "(" else {
        throw "Expected \"(\" after function name."
    }
    tokens.popFront()

    let args: [Token] = try parseArgumentList(tokens).map({
        guard case let Expression.Leaf(tok) = $0, .Identifier == tok.type else {
            throw "Parameter in function definition must be an identifier.\n" +
                  "Instead expression is:"
        }
        return tok
    })

    let body = parseBlock(tokens)

    return Expression.FuncDef(name, args, body)
}