
import XCTest

class ArraySliceIterationTests: XCTestCase {
    
    func testArray() {
        let array = [Int](repeating: 0, count: 1_000_000)
        measure {
            for _ in 0..<100 {
                _ = array.map { $0 }
            }
        }
    }
    
    func testArraySlice() {
        let array = [Int](repeating: 0, count: 2_000_000)
        let slice = array[0..<1_000_000]
        measure {
            for _ in 0..<100 {
                _ = slice.map { $0 }
            }
        }
    }
    
}
