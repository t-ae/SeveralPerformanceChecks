import Foundation

public struct MyArray<Element> {
    var buffer: ManagedBuffer<Int, Element>
    
    init(count: Int) {
        buffer = ManagedBuffer.create(minimumCapacity: count) { _ in count }
    }
    
    public init(repeating value: Element, count: Int) {
        self.init(count: count)
        buffer.withUnsafeMutablePointerToElements { p in
            p.initialize(to: value, count: count)
        }
    }
    
    mutating func ensureUniquelyReferenced() {
        guard !isKnownUniquelyReferenced(&buffer) else {
            return
        }
        let newBuffer = ManagedBuffer<Int, Element>.create(minimumCapacity: count) { buf in
            self.buffer.withUnsafeMutablePointerToElements { src in
                buf.withUnsafeMutablePointerToElements { dst in
                    dst.initialize(from: src, count: count)
                }
            }
            return count
        }
        self.buffer = newBuffer
    }
}

extension MyArray: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return buffer.header }
    
    public func index(after index: Int) -> Int {
        return index + 1
    }
    
    public subscript(index: Int) -> Element {
        get {
            return buffer.withUnsafeMutablePointerToElements { $0[index] }
        }
        set {
            ensureUniquelyReferenced()
            buffer.withUnsafeMutablePointerToElements { $0[index] = newValue }
        }
    }
}
