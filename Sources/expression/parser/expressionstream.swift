import Range

class ExpressionStream : ForwardRange {
    typealias Element = Expression

    let source: TokenStream
    var _front: Expression?
    var _frontIsValid = false

    var front: Expression? {
        if !_frontIsValid {
            _front = parseStatement(tokens: source)
            _frontIsValid = true
        }
        return _front
    }

    init(from: TokenStream) {
        source = from
    }

    func popFront() {
        _frontIsValid = false
    }
}