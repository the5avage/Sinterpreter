import Range

class NodeStream<S: Sequence> : ForwardRange where S.Element == Character {
    let source: TokenStream<S>
    var front: Node?

    init(from: TokenStream<S>) {
        source = from
        front = parse(tokens: source, rbp: 0)
    }

    func popFront() {
        front = parse(tokens: source, rbp: 0)
    }
}