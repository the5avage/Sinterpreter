import Range

if CommandLine.argc == 1 {
    let chars = CharStream<ConsoleStream>(from: ConsoleStream())
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    let interpreter = Interpreter(source: nodes)
    interpreter.run()
} else if CommandLine.argc == 2 {
    let text = readFile(atPath: CommandLine.arguments[1], encoding: .ascii)!
    let chars = CharStream(from: text.cache)
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    let interpreter = Interpreter(source: nodes)
    interpreter.run()
} else if CommandLine.argc == 3 && CommandLine.arguments[1] == "-print" {
    let text = readFile(atPath: CommandLine.arguments[2], encoding: .ascii)!
    let chars = CharStream(from: text.cache)
    let tokens = TokenStream(from: chars)
    let nodes = ExpressionStream(from: tokens)
    let tree = Tree(from: nodes)
    print(tree)
}