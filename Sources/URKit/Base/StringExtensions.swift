//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

extension String {
    public static let empty = ""
    public static let space = " "
    public static let comma = ","
    public static let quote = "\""
    public static let tab = "\t"
    public static let newline = "\n"
    public static let cr = "\r"
    public static let crlf = "\r\n"
}

extension String {
    public var utf8Data: Data {
        toData(utf8: self)
    }
    
    public var hexData: Data? {
        toData(hex: self)
    }
}

extension String {
    public func trim() -> String {
        trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}

extension String {
    public func removeWhitespaceRuns() -> String {
        var lastWasSpace = false
        
        let chars = compactMap { c -> Character? in
            if c.isWhitespace {
                if !lastWasSpace {
                    lastWasSpace = true
                    return " "
                } else {
                    return nil
                }
            } else {
                lastWasSpace = false
                return c
            }
        }
        return String(chars)
    }
}

extension String {
    public func prefix(count: Int) -> String {
        return String(prefix(count))
    }

    public func suffix(count: Int) -> String {
        return String(suffix(count))
    }
    
    public func truncated(count: Int, terminator: String = "…") -> String {
        guard self.count > count else {
            return self
        }
        
        return prefix(count: count) + terminator
    }
}

extension String {
    public func chunked(into size: Int) -> [String] {
        var result: [String] = []
        var chunk = ""
        for c in self {
            chunk.append(c)
            if chunk.count == size {
                result.append(chunk)
                chunk = ""
            }
        }
        if !chunk.isEmpty {
            result.append(chunk)
        }
        return result
    }

    public func indented(_ level: Int = 1, with indentationMark: String = .tab, lineSeparator: String = .newline) -> String {
        let indentation = String(repeating: indentationMark, count: level)
        let lines = components(separatedBy: lineSeparator)
        let indentedLines = lines.joined(separator: lineSeparator + indentation)
        return indentation + indentedLines
    }
}


public func deserialize<T, D>(_ t: T.Type, _ data: D) -> String? where T: StringProtocol, D : DataProtocol {
    String(data: Data(data), encoding: .utf8)
}

extension String: Serializable {
    public var serialized: Data {
        self.utf8Data
    }
}

extension StringProtocol {
    public func flanked(_ leading: String, _ trailing: String) -> String {
        leading + self + trailing
    }

    public func flanked(_ around: String) -> String {
        around + self + around
    }
    
    public func quoted() -> String {
        flanked(.quote)
    }
    
    public func parenthesized() -> String {
        flanked("(", ")")
    }
    
    public func braced() -> String {
        flanked("{", "}")
    }
    
    public func bracketed() -> String {
        flanked("[", "]")
    }
}

extension JoinedSequence where Base.Element == String {
    public func flanked(_ leading: String, _ trailing: String) -> String {
        String(self).flanked(leading, trailing)
    }

    public func flanked(_ around: String) -> String {
        String(self).flanked(around)
    }
    
    public func quoted() -> String {
        flanked(.quote)
    }
    
    public func parenthesized() -> String {
        flanked("(", ")")
    }
    
    public func braced() -> String {
        flanked("{", "}")
    }
    
    public func bracketed() -> String {
        flanked("[", "]")
    }
}
