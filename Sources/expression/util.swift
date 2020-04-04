import Foundation

extension ArraySlice
{
    mutating func pop(while pred: (Self.Element) -> Bool) -> Self
    {
        var tmp = self
        while let c = tmp.first {
            if !pred(c) {
                let result = self[..<tmp.startIndex]
                self = self[tmp.startIndex...]
                return result
            }
            tmp.removeFirst()
        }
        let result = self
        self = []
        return result
    }
}

extension Substring
{
    mutating func pop(while pred: (Self.Element) -> Bool) -> Self
    {
        var tmp = self
        while let c = tmp.first {
            if !pred(c) {
                let result = self[..<tmp.startIndex]
                self = self[tmp.startIndex...]
                return result
            }
            tmp.removeFirst()
        }
        let result = self
        self = Substring()
        return result
    }
}

func readFile(atPath path: String, encoding: String.Encoding = .utf8 ) -> String?
{
    guard let raw = FileManager.default.contents(atPath: path)
        else { return nil }
    return String(data: raw, encoding: .ascii)
}