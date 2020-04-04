import Swift
import Range

class CharStream : ForwardRange
{
    typealias Element = Character

    var actualLineNumber: Int = 1
    var actualRowNumber: Int = 1

    var front: Character?

    var remaining: Substring

    init(_ from: Substring) {
        remaining = from
        front = remaining.popFirst()
    }

    func popFront() {
        front = remaining.popFirst()
        if front == "\n" {
            actualLineNumber += 1
            actualRowNumber = 1
        } else {
            actualRowNumber += 1
        }
    }
}