let text = readFile(atPath: "hello.txt", encoding: .ascii)!

var tokens = TokenStream(text)
var tree = Tree(tokens: tokens)
print(tree)