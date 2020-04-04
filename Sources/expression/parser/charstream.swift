import Swift
import Range

class CharStream<S: Sequence>  : ForwardRange where S.Element == Character {
    typealias Element = Character

    var actualLineNumber: Int = 1
    var actualRowNumber: Int = 1
    var front: Character?
    var remaining: S.Iterator

    init(_ source: S) {
        remaining = source.makeIterator()
        front = remaining.next()
    }

    func popFront() {
        front = remaining.next()
        if front == "\n" {
            actualLineNumber += 1
            actualRowNumber = 1
        } else {
            actualRowNumber += 1
        }
    }
}