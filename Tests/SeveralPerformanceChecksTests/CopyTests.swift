
import XCTest

#if os(macOS)
    import Accelerate
#endif

class CopyTests: XCTestCase {
    // MARK: - Copy
    func testCopy() {
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c)
        
        measure {
            for _ in 0..<100 {
                for i in 0..<c {
                    b[i] = a[i]
                }
            }
        }
    }
    
    func testCopy_Pointer() {
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c)
        
        measure {
            for _ in 0..<100 {
                var pa = UnsafePointer(a)
                var pb = UnsafeMutablePointer(mutating: &b)
                for _ in 0..<c {
                    pb.pointee = pa.pointee
                    pa += 1
                    pb += 1
                }
            }
        }
    }
    
    func testCopy_memcpy() {
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c)
        
        measure {
            for _ in 0..<100 {
                memcpy(&b, a, c*MemoryLayout<Float>.size)
            }
        }
    }
    
    #if os(macOS)
    
    func testCopy_BLAS() {
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c)
        measure {
            for _ in 0..<100 {
                cblas_scopy(Int32(c), a, 1, &b, 1)
            }
        }
    }
    #endif
}
