class NodeStream<S: Sequence> where S.Element == Character {
    let source: TokenStream<S>

    init(from: TokenStream<S>) {
        source = from
    }

    func next() -> Node? {
        return parse(tokens: source, rbp: 0)
    }
}