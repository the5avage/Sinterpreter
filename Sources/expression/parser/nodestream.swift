import Range

class NodeStream<R: ForwardRange> : ForwardRange where R.Element == Character {
    let source: TokenStream<R>
    var front: Node?

    init(from: TokenStream<R>) {
        source = from
        front = parse(tokens: source, rbp: 0)
    }

    func popFront() {
        front = parse(tokens: source, rbp: 0)
    }
}