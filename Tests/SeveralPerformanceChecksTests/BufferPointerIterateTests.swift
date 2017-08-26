
import XCTest

class BufferPointerIterateTests: XCTestCase {
    
    func testGetSubscript() {
        let x = (0..<1_000_000).map { Int($0) }
        measure {
            for _ in 0..<100 {
                _ = x.withUnsafeBufferPointer { buf -> Int in
                    var sum = 0
                    for i in 0..<buf.count {
                        sum += buf[i]
                    }
                    return sum
                }
            }
        }
    }
    
    func testGetPointer() {
        let x = (0..<1_000_000).map { Int($0) }
        measure {
            for _ in 0..<100 {
                _ = x.withUnsafeBufferPointer { buf -> Int in
                    var sum = 0
                    var p = buf.baseAddress!
                    for _ in 0..<buf.count {
                        sum += p.pointee
                        p += 1
                    }
                    return sum
                }
            }
        }
    }
    
    func testSetSubscript() {
        var x = (0..<1_000_000).map { Int($0) }
        measure {
            for _ in 0..<100 {
                x.withUnsafeMutableBufferPointer { buf in
                    for i in 0..<buf.count {
                        buf[i] /= 3
                    }
                }
            }
        }
    }
    
    func testSetPointer() {
        var x = (0..<1_000_000).map { Int($0) }
        measure {
            for _ in 0..<100 {
                x.withUnsafeMutableBufferPointer { buf in
                    var p = buf.baseAddress!
                    for _ in 0..<buf.count {
                        p.pointee /= 3
                        p += 1
                    }
                }
            }
        }
    }
    
}
