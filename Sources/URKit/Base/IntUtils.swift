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

public func serialize<I>(_ n: I, littleEndian: Bool = false) -> Data where I: FixedWidthInteger {
    let count = MemoryLayout<I>.size
    var d = Data(repeating: 0, count: count)
    d.withUnsafeMutableBytes {
        $0.bindMemory(to: I.self).baseAddress!.pointee = littleEndian ? n.littleEndian : n.bigEndian
    }
    return d
}

public func deserialize<T, D>(_ t: T.Type, _ data: D, littleEndian: Bool = false) -> T? where T: FixedWidthInteger, D : DataProtocol {
    let size = MemoryLayout<T>.size
    guard data.count >= size else {
        return nil
    }

    var dataBytes = [UInt8](repeating: 0, count: size)
    return dataBytes.withUnsafeMutableBytes {
        data.copyBytes(to: $0, count: size)
        let a = $0.bindMemory(to: T.self).baseAddress!.pointee
        return littleEndian ? T(littleEndian: a) : T(bigEndian: a)
    }
}

extension FixedWidthInteger {
    public func serialized(littleEndian: Bool = false) -> Data {
        serialize(self, littleEndian: littleEndian)
    }
}

extension UInt: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension UInt8: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension UInt16: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension UInt32: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension UInt64: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension Int: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension Int8: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension Int16: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension Int32: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}

extension Int64: Serializable {
    public var serialized: Data {
        serialize(self)
    }
}
