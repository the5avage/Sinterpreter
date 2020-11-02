class TokenStream : ForwardRange {
    typealias Element = Token

    var source: CharStream
    var _front: Token?

    var frontIsValid: Bool = false

    var front: Token? {
        if !frontIsValid {
            _front = source.matchToken()
            frontIsValid = true
        }
        return _front
    }

    init(from: CharStream) {
        source = from
    }

    func popFront() {
        frontIsValid = false
    }
}