import Range

class ExpressionStream<R: ForwardRange> : ForwardRange where R.Element == Character {
    let source: TokenStream<R>
    var _front: Expression?
    var _frontIsValid = false

    var front: Expression? {
        if !_frontIsValid {
            _front = parseStatement(tokens: source)
            _frontIsValid = true
        }
        return _front
    }

    init(from: TokenStream<R>) {
        source = from
    }

    func popFront() {
        _frontIsValid = false
    }
}