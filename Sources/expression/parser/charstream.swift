import Swift
import Range

class CharStream<R: ForwardRange> : ForwardRange where R.Element == Character {
    typealias Element = Character

    var actualLineNumber: Int = 1
    var actualRowNumber: Int = 1
    var remaining: R

    init(from: R) {
        remaining = from
    }

    var front: Character? {
        return remaining.front
    }

    func popFront() {
        if front == "\n" {
            actualLineNumber += 1
            actualRowNumber = 1
        } else {
            actualRowNumber += 1
        }
        remaining.popFront()
    }
}