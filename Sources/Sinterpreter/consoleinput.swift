class ConsoleStream : ForwardRange {
    typealias Element = Character
    var buffer: Substring = ""

    var front: Character? {
        if buffer.isEmpty {
            print("--> ", terminator: "")
            guard let newBuffer = readLine(strippingNewline: false) else {
                return nil
            }
            buffer = newBuffer[...]
        }
        return buffer.first
    }

    func popFront() {
        buffer.removeFirst()
    }
}