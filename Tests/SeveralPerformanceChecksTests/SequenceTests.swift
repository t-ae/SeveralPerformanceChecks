
import XCTest
import SeveralPerformanceChecks

class SequenceTests: XCTestCase {
    
    func testSequence() {
        let array = [Float](repeating: 0, count: 1_000_000)
        measure {
            for _ in 0..<100 {
                _ = array.filter { $0 < 0 }
            }
        }
    }
    
    func testMySequence() {
        let array = [Float](repeating: 0, count: 1_000_000)
        measure {
            for _ in 0..<100 {
                _ = MySequence(array: array).filter { $0 < 0 }
            }
        }
    }
    
    func testMyFloatSequence() {
        let array = [Float](repeating: 0, count: 1_000_000)
        measure {
            for _ in 0..<100 {
                _ = MyFloatSequence(array: array).filter { $0 < 0 }
            }
        }
    }
}
