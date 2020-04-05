let text = readFile(atPath: "hello.txt", encoding: .ascii)!

let chars = CharStream(from: text)
let tokens = TokenStream(from: chars)
let nodes = NodeStream(from: tokens)

let interpreter = Interpreter(source: nodes)

interpreter.run()