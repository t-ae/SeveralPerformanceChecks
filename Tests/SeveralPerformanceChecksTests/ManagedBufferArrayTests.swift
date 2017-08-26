
import XCTest
import SeveralPerformanceChecks

class ManagedBufferArrayTests: XCTestCase {
    
    func testIterateArray() {
        let count = 1_000_000
        let a = [Float](repeating: 0, count: count)
        
        measure {
            for _ in 0..<100 {
                _ = a.filter { $0 < 0 }
            }
        }
    }
    
    func testIterateMyArray() {
        let count = 1_000_000
        let a = MyArray<Float>(repeating: 0, count: count)
        
        measure {
            for _ in 0..<100 {
                _ = a.filter { $0 < 0 }
            }
        }
    }
    
    func testIterateMyFloatArray() {
        let count = 1_000_000
        let a = MyFloatArray(repeating: 0, count: count)
        
        measure {
            for _ in 0..<100 {
                _ = a.filter { $0 < 0 }
            }
        }
    }
    
    func testIterateMyArray2() {
        let count = 1_000_000
        let a = MyArray2<Float>(repeating: 0, count: count)
        
        measure {
            for _ in 0..<100 {
                _ = a.filter { $0 < 0 }
            }
        }
    }
}

struct MyArray2<Element> {
    var buffer: ManagedBuffer<Int, Element>
    
    init(count: Int) {
        buffer = ManagedBuffer.create(minimumCapacity: count) { _ in count }
    }
    
    init(repeating value: Element, count: Int) {
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

extension MyArray2: Collection {
    var startIndex: Int { return 0 }
    var endIndex: Int { return buffer.header }
    
    func index(after index: Int) -> Int {
        return index + 1
    }
    
    subscript(index: Int) -> Element {
        get {
            return buffer.withUnsafeMutablePointerToElements { $0[index] }
        }
        set {
            ensureUniquelyReferenced()
            buffer.withUnsafeMutablePointerToElements { $0[index] = newValue }
        }
    }
}
