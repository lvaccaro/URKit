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

extension Data {
    public init?<S>(hex: S) where S: StringProtocol {
        guard let data = toData(hex: hex) else {
            return nil
        }
        self = data
    }
    
    public var hex: String {
        toHex(data: self)
    }
}

extension Data {
    public var bytes: [UInt8] {
        Array(self)
    }
}

extension Data {
    public var utf8: String? {
        toUTF8(data: self)
    }
}

extension Data {
    public init<A>(of a: A) {
        let d = Swift.withUnsafeBytes(of: a) {
            Data($0)
        }
        self = d
    }
    
    public func store<A>(into a: inout A) {
        precondition(MemoryLayout<A>.size >= count)
        withUnsafeMutablePointer(to: &a) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                self.copyBytes(to: $0, count: count)
            }
        }
    }
}

extension Data {
    @inlinable public func withUnsafeByteBuffer<ResultType>(_ body: (UnsafeBufferPointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeBytes { rawBuf in
            try body(rawBuf.bindMemory(to: UInt8.self))
        }
    }

    @inlinable public mutating func withUnsafeMutableByteBuffer<ResultType>(_ body: (UnsafeMutableBufferPointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeMutableBytes { rawBuf in
            try body(rawBuf.bindMemory(to: UInt8.self))
        }
    }
}

extension Data: Serializable {
    public var serialized: Data {
        self
    }
}

extension Data {
    public var base64: String {
        self.base64EncodedString()
    }
    
    public init?(base64 string: String) {
        self.init(base64Encoded: string)
    }
}
