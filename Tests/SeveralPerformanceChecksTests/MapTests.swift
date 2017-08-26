
import XCTest

class MapTests: XCTestCase {
    
    func testMap() {
        let x = (0..<1_000_000).map { Int($0) }
        let f: (Int)->Int = { $0 + 1 }
        
        measure {
            for _ in 0..<100 {
                _ = x.map(f)
            }
        }
    }
    
    func testNoMap() {
        let x = (0..<1_000_000).map { Int($0) }
        let f: (Int)->Int = { $0 + 1 }
        
        measure {
            for _ in 0..<100 {
                var new = [Int]()
                new.reserveCapacity(x.count)
                for i in 0..<x.count {
                    new.append(f(x[i]))
                }
            }
        }
    }
    
    func testNoMap_noclosure() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                var new = [Int]()
                new.reserveCapacity(x.count)
                for i in 0..<x.count {
                    new.append(x[i] + 1)
                }
            }
        }
    }
    
    func testNoMap_noclosure_noreserve() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                var new = [Int]()
                for i in 0..<x.count {
                    new.append(x[i] + 1)
                }
            }
        }
    }
    
    func testNoMap_zerofill() {
        let x = (0..<1_000_000).map { Int($0) }
        let f: (Int)->Int = { $0 + 1 }
        
        measure {
            for _ in 0..<100 {
                var new = [Int](repeating: 0, count: x.count)
                for i in 0..<x.count {
                    new[i] = f(x[i])
                }
            }
        }
    }
    
    func testNoMap_zerofill_noclosure() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                var new = [Int](repeating: 0, count: x.count)
                for i in 0..<x.count {
                    new[i] = x[i] + 1
                }
            }
        }
    }
    
    func testNoMap_zerofill_noclosure_pointer() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                var new = [Int](repeating: 0, count: x.count)
                x.withUnsafeBufferPointer {
                    var src = $0.baseAddress!
                    new.withUnsafeMutableBufferPointer {
                        var dst = $0.baseAddress!
                        for _ in 0..<$0.count {
                            dst.pointee = src.pointee + 1
                            src += 1
                            dst += 1
                        }
                    }
                }
                
            }
        }
    }
    
}
