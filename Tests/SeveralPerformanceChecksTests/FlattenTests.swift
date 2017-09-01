
import XCTest

class FlattenTests: XCTestCase {
    
    func testFlatMap() {
        let e = [Float](repeating: 1, count: 1000)
        let a = Array(repeating: e, count: 1000)
        
        measure {
            for _ in 0..<100 {
                _ = a.flatMap { $0 }
            }
        }
    }
    
    func testPointer() {
        let e = [Float](repeating: 1, count: 1000)
        let a = Array(repeating: e, count: 1000)
        
        measure {
            for _ in 0..<100 {
                let eCount = e.count
                var array = [Float](repeating: 0, count: a.count*e.count)
                array.withUnsafeMutableBufferPointer {
                    var dst = $0.baseAddress!
                    for i in a {
                        i.withUnsafeBufferPointer {
                            let src = $0.baseAddress!
                            memcpy(dst, src, eCount)
                        }
                        dst += eCount
                    }
                }
            }
        }
    }
}
