
import XCTest

class ClosureCallTests: XCTestCase {
    
    func testClosure() {
        var x = (0..<1_000_000).map { Int($0) }
        let f: (Int)->Int = { $0 + 1 }
        
        measure {
            for _ in 0..<100 {
                for i in 0..<x.count {
                    x[i] = f(x[i])
                }
            }
        }
    }
    
    func testNoClosure() {
        var x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                for i in 0..<x.count {
                    x[i] = x[i] + 1
                }
            }
        }
    }
}
