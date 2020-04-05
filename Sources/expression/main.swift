let text = readFile(atPath: "hello.txt", encoding: .ascii)!

let tokens = TokenStream(text)
let nodes = NodeStream(from: tokens)

let interpreter = Interpreter(source: nodes)

interpreter.run()