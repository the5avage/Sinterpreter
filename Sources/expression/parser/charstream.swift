import Swift
import Range

class CharStreamGeneric<R: ForwardRange> : ForwardRange where R.Element == Character {
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

/* Type erasure */
class CharStream : ForwardRange {
    let _front: () -> Character?
    let _popFront: () -> ()
    let _actualLineNumber: () -> Int
    let _actualRowNumber: () -> Int

    init<R: ForwardRange>(from: R) where R.Element == Character {
        let closure = CharStreamGeneric(from: from)
        _front = { closure.front }
        _popFront = closure.popFront
        _actualLineNumber = { closure.actualLineNumber }
        _actualRowNumber = { closure.actualRowNumber }
    }

    var front: Character? {
        return _front()
    }

    func popFront() {
        _popFront()
    }

    var actualLineNumber: Int {
        return _actualLineNumber()
    }

    var actualRowNumber: Int {
        return _actualRowNumber()
    }
}