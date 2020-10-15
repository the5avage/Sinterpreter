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
    ")" : -1, // never try to parse ) and , as infix operator
    "," : -1,
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

let keywords: Set = ["exit", "true", "false", "if", "end", "while", "def"]

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
    if tokens.front!.asString == ")" {
        throw "Functions with no arguments are currently not supported: \(tok)"
    }
    guard case let Expression.Leaf(lhs) = exp, lhs.type == TokenType.Identifier else {
        throw "Expected identifier at the left to function call operator: \(tok)"
    }
    let arg1 = try parse(tokens: tokens, rbp: 0)
    if tokens.front!.asString == ")" {
        tokens.popFront()
        return Expression.Unary(lhs, arg1)
    } else if tokens.front!.asString != "," {
        fatalError("Expected , or ) while parsing argument list of function: \(tok)")
    }
    tokens.popFront()
    let arg2 = try parse(tokens: tokens, rbp: 0)
    if tokens.front!.asString != ")" {
        fatalError("Function can have a maximum of two arguments: \(tok)")
    }
    tokens.popFront()
    return Expression.Binary(lhs, arg1, arg2)
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

private func parseFuncDefArguments(_ tokens: TokenStream) throws -> [Token] {
    var result: [Token] = []
    var run: Bool = true

    repeat {
        guard let arg = tokens.front else {
            throw "Reached end of file when expecting identifier"
        }
        if arg.type != .Identifier {
            throw "Expected identifier instead of \(arg)"
        }
        result.append(arg)
        tokens.popFront()
        guard let seperator = tokens.front else {
            throw "Reached end of file when expecting identifier"
        }
        if seperator.asString == ")" {
            run = false
        } else if seperator.asString != "," {
            throw "Expected \",\" instead of \(seperator)"
        }
        tokens.popFront()
    } while run

    return result
}

private func parseFuncDef(_ tok: Token, _ tokens: TokenStream) throws -> Expression {
    if tokens.front == nil {
        throw "Reached end of file when expecting identifier"
    }
    if tokens.front!.type != .Identifier {
        throw "Expected identifier instad of \(tokens.front!)"
    }
    let name = tokens.front!
    tokens.popFront()

    if tokens.front!.asString == "(" {
        tokens.popFront()
    } else {
        throw "Expected \"(\" after function name. Instead token is \(tokens.front!)"
    }

    let args = try parseFuncDefArguments(tokens)

    if args.count != 1 && args.count != 2 {
        throw "Only functions with one or two arguments are currently supported"
    }

    let body = parseBlock(tokens)

    return Expression.FuncDef(name, args, body)
}