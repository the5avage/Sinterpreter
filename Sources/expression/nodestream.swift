class NodeStream {
    let source: TokenStream

    init(from: TokenStream) {
        source = from
    }

    func next() -> Node? {
        return parse(tokens: source, rbp: 0)
    }
}