import Range

class ConsoleStream : ForwardRange {
    typealias Element = Character
    var buffer: Substring = ""

    var front: Character? {
        if buffer.isEmpty {
            repeat {
                print("--> ", terminator: "")
                guard let newBuffer = readLine(strippingNewline: false) else {
                    return nil
                }
                buffer = newBuffer[...]
            } while buffer == "\n"
        }
        return buffer.first
    }

    func popFront() {
        buffer.removeFirst()
    }
}