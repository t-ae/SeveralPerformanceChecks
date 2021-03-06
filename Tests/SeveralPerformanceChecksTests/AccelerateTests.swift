
import XCTest
#if os(macOS)
    import Accelerate
#endif

class AcceleratePerformanceTests: XCTestCase {
    #if os(macOS)
    // MARK: - Stride Copy
    func testCopy() {
        let stride = 2
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c/stride)
        
        measure {
            for _ in 0..<100 {
                for i in 0..<c/stride {
                    b[i] = a[stride*i]
                }
            }
        }
    }
    
    func testCopy_Pointer() {
        let stride = 2
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c/stride)
        
        measure {
            for _ in 0..<100 {
                var pa = UnsafePointer(a)
                var pb = UnsafeMutablePointer(mutating: &b)
                for _ in 0..<c/stride {
                    pb.pointee = pa.pointee
                    pa += stride
                    pb += 1
                }
            }
        }
    }
    
    func testCopy_BLAS() {
        let stride = 2
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c/stride)
        measure {
            for _ in 0..<100 {
                cblas_scopy(Int32(c/stride), a, Int32(stride), &b, 1)
            }
        }
    }
    
    func testCopy_vDSP() {
        let stride = 2
        let c = 1_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: c/stride)
        measure {
            for _ in 0..<100 {
                vDSP_mmov(a, &b, vDSP_Length(c/stride), 1, vDSP_Length(stride), 1)
            }
        }
    }
    
    // MARK: - Negate
    func testNegate_BLAS() {
        let count = 1_000_000
        let a = [Float](repeating: 1, count: count)
        measure {
            for _ in 0..<100 {
                var ans = [Float](repeating: 0, count: count)
                ans.withUnsafeMutableBufferPointer { p in
                    cblas_saxpy(Int32(count), -1, a, 1, p.baseAddress!, 1)
                }
            }
        }
    }
    
    func testNegate_vDSP() {
        let count = 1_000_000
        let a = [Float](repeating: 1, count: count)
        measure {
            for _ in 0..<100 {
                var ans = [Float](repeating: 0, count: count)
                vDSP_vneg(a, 1, &ans, 1, vDSP_Length(count))
            }
        }
    }
    
    // MARK: - Add
    func testAdd_BLAS() {
        let count = 1_000_000
        let a = [Float](repeating: 1, count: count)
        let b = [Float](repeating: 1, count: count)
        
        measure {
            for _ in 0..<100 {
                var ans = b
                ans.withUnsafeMutableBufferPointer { p in
                    cblas_saxpy(Int32(count), 1, a, 1, p.baseAddress!, 1)
                }
            }
        }
    }
    
    func testAdd_ATLAS() {
        let count = 1_000_000
        let a = [Float](repeating: 1, count: count)
        let b = [Float](repeating: 1, count: count)
        
        measure {
            for _ in 0..<100 {
                var ans = b
                ans.withUnsafeMutableBufferPointer { p in
                    catlas_saxpby(Int32(count), 1, a, 1, 1, p.baseAddress!, 1)
                }
            }
        }
    }

    func testAdd_vDSP() {
        let count = 1_000_000
        let a = [Float](repeating: 1, count: count)
        let b = [Float](repeating: 1, count: count)
        measure {
            for _ in 0..<100 {
                var ans = [Float](repeating: 1, count: count)
                vDSP_vadd(a, 1, b, 1, &ans, 1, vDSP_Length(count))
            }
        }
    }
    
    // MARK: scalar add
    func testAddScalar_BLAS() {
        let count = 1_000_000
        let a = [Float](repeating: 0, count: count)
        let b: [Float] = [1]
        measure {
            for _ in 0..<100 {
                var ans = a
                ans.withUnsafeMutableBufferPointer { p in
                    cblas_saxpy(Int32(count), 1, b, 0, p.baseAddress!, 1)
                }
            }
        }
    }
    
    func testAddScalar_vDSP1() {
        let count = 1_000_000
        let a = [Float](repeating: 0, count: count)
        let b: [Float] = [1]
        measure {
            for _ in 0..<100 {
                var ans = [Float](repeating: 0, count: count)
                vDSP_vadd(a, 1, b, 0, &ans, 1, vDSP_Length(count))
            }
        }
    }
    
    func testAddScalar_vDSP2() {
        let count = 1_000_000
        let a = [Float](repeating: 0, count: count)
        let b: [Float] = [1]
        
        measure {
            for _ in 0..<100 {
                var ans = [Float](repeating: 0, count: count)
                vDSP_vsadd(a, 1, b, &ans, 1, vDSP_Length(count))
            }
        }
    }
    
    // Scalar multiply scalar add
    func testSMSA_BLAS() {
        let count = 5_000_000
        let a = [Float](repeating: 1, count: count)
        
        measure {
            var y = [Float](repeating: 1, count: count)
            cblas_saxpy(Int32(count), 1, a, 1, &y, 1)
        }
    }
    
    func testSMSA_vDSP() {
        let count = 5_000_000
        let a = [Float](repeating: 1, count: count)
        
        measure {
            var mul: Float = 1
            var add: Float = 1
            var y = [Float](repeating: 0, count: count)
            vDSP_vsmsa(a, 1, &mul, &add, &y, 1, vDSP_Length(count))
        }
    }
    
    // MARK: - Matmul
    func testMatmul_BLAS() {
        let M: Int32 = 1000
        let N: Int32 = 1000
        let K: Int32 = 300
        let a = [Float](repeating: 1, count: Int(M*K))
        let b = [Float](repeating: 1, count: Int(K*N))
        var c = [Float](repeating: 0, count: Int(M*N))

        measure {
            for _ in 0..<100 {
                cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                            M, N, K,
                            1, a, K, b, N, 0, &c, N)
            }
        }
    }

    func testMatmul_vDSP() {
        let M: vDSP_Length = 1000
        let N: vDSP_Length = 1000
        let K: vDSP_Length = 300
        let a = [Float](repeating: 1, count: Int(M*K))
        let b = [Float](repeating: 1, count: Int(K*N))
        var c = [Float](repeating: 0, count: Int(M*N))
        
        measure {
            for _ in 0..<100 {
                vDSP_mmul(a, 1, b, 1, &c, 1, M, N, K)
            }
        }
    }
    
    // MARK: Minus stride
    func testCopyMinus_BLAS() {
        let stride = -4
        let c = 100_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: -c/stride)
        measure {
            cblas_scopy(Int32(-c/stride), a, Int32(stride), &b, 1)
        }
    }
    
    func testCopyMinus_vDSP() {
        let stride = -4
        let c = 100_000_000
        let a = [Float](repeating: 1, count: c)
        var b = [Float](repeating: 0, count: -c/stride)
        measure {
            let src = UnsafePointer(a) - stride - 1
            vDSP_mmov(src, &b, vDSP_Length(-c/stride), 1, vDSP_Length(-stride), 1)
            vDSP_vrvrs(&b, 1, vDSP_Length(-c/stride))
        }
    }
    
    // MARK: Matrix
    func testCopyMatrix_BLAS() {
        let m = 100000
        let n = 1000
        let a = [Float](repeating: 1, count: m*n)
        var b = [Float](repeating: 0, count: m*n/4)
        measure {
            let numInRow = Int32(n/2)
            var src = UnsafePointer(a)
            var dst = UnsafeMutablePointer(mutating: &b)
            let n2 = n/2
            for _ in 0..<m/2 {
                cblas_scopy(numInRow, src, 1, dst, 1)
                src += n
                dst += n2
            }
        }
    }
    
    func testCopyMatrix_vDSP() {
        let m = 100000
        let n = 1000
        let a = [Float](repeating: 1, count: m*n)
        var b = [Float](repeating: 0, count: m*n/4)
        measure {
            let n2 = n/2
            vDSP_mmov(a, &b, vDSP_Length(m/2), vDSP_Length(n/2), vDSP_Length(n), vDSP_Length(n2))
        }
    }
    
    // MARK: - Transpose
    func testTranspose_Pointer() {
        let m = 1000
        let n = 1000
        let a = [Float](repeating: 0, count: m*n)
        var b = [Float](repeating: 0, count: m*n)
        measure {
            a.withUnsafeBufferPointer { ap in
                b.withUnsafeMutableBufferPointer { bp in
                    var ap = ap.baseAddress!
                    for i in 0..<m {
                        var bp = bp.baseAddress! + i
                        for _ in 0..<n {
                            bp.pointee = ap.pointee
                            ap += 1
                            bp += m
                        }
                    }
                }
            }
        }
    }
    
    func testTranspose_BLAS() {
        let m = 3000
        let n = 3000
        let a = [Float](repeating: 0, count: m*n)
        var b = [Float](repeating: 0, count: m*n)
        measure {
            a.withUnsafeBufferPointer { ap in
                b.withUnsafeMutableBufferPointer { bp in
                    var ap = ap.baseAddress!
                    var bp = bp.baseAddress!
                    for _ in 0..<m {
                        cblas_scopy(Int32(n), a, 1, bp, Int32(m))
                        ap += n
                        bp += 1
                    }
                }
            }
        }
    }
    
    func testTranspose_BLAS2() {
        let m = 3000
        let n = 3000
        let a = [Float](repeating: 0, count: m*n)
        var b = [Float](repeating: 0, count: m*n)
        measure {
            a.withUnsafeBufferPointer { ap in
                b.withUnsafeMutableBufferPointer { bp in
                    var ap = ap.baseAddress!
                    var bp = bp.baseAddress!
                    for _ in 0..<n {
                        cblas_scopy(Int32(m), a, Int32(n), bp, 1)
                        ap += 1
                        bp += m
                    }
                }
            }
        }
    }
    
    func testTranspose_vDSP() {
        let m = 3000
        let n = 3000
        let a = [Float](repeating: 0, count: m*n)
        var b = [Float](repeating: 0, count: m*n)
        measure {
            vDSP_mtrans(a, 1, &b, 1, vDSP_Length(m), vDSP_Length(n))
        }
    }
    
    // MARK: - Parallel
    func testParallel0() {
        let count = 1000000
        let a = [Float](repeating: 0, count: count*8)
        let b = [Float](repeating: 0, count: count*8)
        let ans = [Float](repeating: 0, count: count*8)
        measure {
            var ap = UnsafePointer(a)
            var bp = UnsafePointer(b)
            var ansp = UnsafeMutablePointer(mutating: ans)
            for _ in 0..<count {
                vDSP_vadd(ap, 1, bp, 1, ansp, 1, vDSP_Length(8))
                ap += 8
                bp += 8
                ansp += 8
            }
        }
    }
    
    func testParallel1() {
        let count = 1000000
        let a = [Float](repeating: 0, count: count*8)
        let b = [Float](repeating: 0, count: count*8)
        let ans = [Float](repeating: 0, count: count*8)
        measure {
            DispatchQueue.concurrentPerform(iterations: count) { i in
                let ap = UnsafePointer(a).advanced(by: 8*i)
                let bp = UnsafePointer(b).advanced(by: 8*i)
                let ansp = UnsafeMutablePointer(mutating: ans).advanced(by: 8*i)
                
                vDSP_vadd(ap, 1, bp, 1, ansp, 1, 8)
            }
        }
    }
    
    func testParallel2() {
        let count = 1000000
        let a = [Float](repeating: 0, count: count*8)
        let b = [Float](repeating: 0, count: count*8)
        let ans = [Float](repeating: 0, count: count*8)
        measure {
            let divide = 2
            DispatchQueue.concurrentPerform(iterations: divide) { i in
                var ap = UnsafePointer(a).advanced(by: 8*i*count/divide)
                var bp = UnsafePointer(b).advanced(by: 8*i*count/divide)
                var ansp = UnsafeMutablePointer(mutating: ans).advanced(by: 8*i*count/divide)
                for _ in 0..<count/divide {
                    vDSP_vadd(ap, 1, bp, 1, ansp, 1, 8)
                    ap += 8
                    bp += 8
                    ansp += 8
                }
                
                vDSP_vadd(ap, 1, bp, 1, ansp, 1, 8)
            }
        }
    }
    #endif
}
