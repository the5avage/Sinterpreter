import Swift
import Range

class CharStream<R: ForwardRange> : ForwardRange where R.Element == Character {
    typealias Element = Character

    var actualLineNumber: Int = 1
    var actualRowNumber: Int = 1
    var front: Character?
    var remaining: R

    init(from: R) {
        remaining = from
        front = remaining.front
    }

    func popFront() {
        remaining.popFront()
        front = remaining.front
        if front == "\n" {
            actualLineNumber += 1
            actualRowNumber = 0
        } else {
            actualRowNumber += 1
        }
    }
}