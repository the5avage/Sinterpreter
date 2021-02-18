public protocol ForwardRange : Sequence, IteratorProtocol {
    associatedtype Element
    var front: Element? { get }
    mutating func popFront()
}

extension IteratorProtocol where Self : ForwardRange {
    public mutating func next() -> Element? {
        _next(this: &self)
    }
}

extension IteratorProtocol where Self : AnyObject & ForwardRange {
    public func next() -> Element? {
        var this = self
        return _next(this: &this)
    }
}

func _next<T: ForwardRange>(this: inout T) -> T.Element? {
    if this.front == nil {
        return nil
    }
    let result = this.front
    this.popFront()
    return result
}

extension ArraySlice : ForwardRange {
    public var front: Element? {
        return first
    }

    public mutating func popFront() {
        removeFirst()
    }
}

public struct TakeWhileResult<R : ForwardRange> : ForwardRange {
    public typealias Element = R.Element

    var source: R
    var predicate: (R.Element) -> Bool
    public var front: R.Element?

    init(source: R, while predicate: @escaping (R.Element) -> Bool) {
        self.source = source
        self.predicate = predicate
        updateFront()
    }

    public mutating func popFront() {
        source.popFront()
        updateFront()
    }

    mutating func updateFront() {
        if let f = source.front, predicate(f) {
            front = f
        } else {
            front = nil
        }
    }
}

extension ForwardRange {
    public func take(while predicate: @escaping (Self.Element) -> Bool) -> TakeWhileResult<Self> {
        return TakeWhileResult(source: self, while: predicate)
    }
}

public struct CachedSequence<T: Sequence> : ForwardRange {
    public typealias Iterator = Self
    public typealias Element = T.Element

    private var base: T.Iterator
    private var _first: T.Element?

    init(_ base: T.Iterator) {
        self.base = base
        _first = self.base.next()
    }

    public var front: T.Element? {
        return _first
    }

    public mutating func popFront() {
        _first = base.next()
    }
}

extension Sequence {
    public var cache: CachedSequence<Self> {
        return CachedSequence(self.makeIterator())
    }
}

extension Sequence {
    public var array: Array<Self.Element> {
        return Array(self)
    }
}