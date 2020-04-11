import Range

//let text = readFile(atPath: "hello.txt", encoding: .ascii)!
//let chars = CharStream(from: text)

let chars = CharStream<ConsoleStream>(from: ConsoleStream())
let tokens = TokenStream(from: chars)
let nodes = ExpressionStream(from: tokens)

let interpreter = Interpreter(source: nodes)

interpreter.run()