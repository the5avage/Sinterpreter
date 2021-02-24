import Foundation

if CommandLine.argc == 1 {
    let chars = CharStream(from: ConsoleStream())
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    let interpreter = Interpreter(source: nodes)
    interpreter.run()
} else if CommandLine.argc == 2 {
    guard let text = readFile(atPath: CommandLine.arguments[1], encoding: .ascii) else {
        print("Error: Could not open file \"\(CommandLine.arguments[1])\"!")
        exit(1)
    }
    let chars = CharStream(from: text.cache)
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    let interpreter = Interpreter(source: nodes)
    interpreter.run()
} else if CommandLine.argc == 3 && CommandLine.arguments[1] == "-print" {
    guard let text = readFile(atPath: CommandLine.arguments[2], encoding: .ascii) else {
        print("Error: Could not open file \"\(CommandLine.arguments[2])\"!")
        exit(1)
    }
    let chars = CharStream(from: text.cache)
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    for n in nodes {
        if case .Invalid(let s) = n {
            break
        }
        print(n)
    }
} else {
    print("Invalid console arguments!")
    print("Use no arguments for REPL, <filename> to execute a file and")
    print("-print <filename> to output the AST.")
}