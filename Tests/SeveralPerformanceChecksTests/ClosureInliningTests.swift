
import XCTest

class ClosureInliningTests: XCTestCase {
    
    func testNormalMap() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                _ = x.map { $0 + 1 }
            }
        }
    }
    
    func testInline() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                _ = x.inlineMap { $0 + 1 }
            }
        }
    }
    
    func testNoInline() {
        let x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                _ = x.noInlineMap { $0 + 1 }
            }
        }
    }
    
    func testInlineNoClosure() {
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
    
    func testInlineCompound() {
        var x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                x.inlineMapCompound(+=, rhs: 1)
            }
        }
    }
    
    func testNoInlineCompound() {
        var x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                x.noInlineMapCompound(+=, rhs: 1)
            }
        }
    }
    
    func testInlineCompoundNoClosure() {
        var x = (0..<1_000_000).map { Int($0) }
        
        measure {
            for _ in 0..<100 {
                for i in 0..<x.count {
                    x[i] += 1
                }
                
            }
        }
    }
}

extension Array where Element == Int {
    @inline(__always)
    fileprivate func inlineMap(f: (Int)->Int) -> [Int] {
        var new = self
        for i in 0..<count {
            new[i] = f(new[i])
        }
        return new
    }
    
    @inline(never)
    fileprivate func noInlineMap(f: (Int)->Int) -> [Int] {
        var new = self
        for i in 0..<count {
            new[i] = f(new[i])
        }
        return new
    }
    
    @inline(__always)
    fileprivate mutating func inlineMapCompound(_ f: (inout Int, Int)->Void, rhs: Int) {
        for i in 0..<count {
            f(&self[i], rhs)
        }
    }
    
    @inline(never)
    fileprivate mutating func noInlineMapCompound(_ f: (inout Int, Int)->Void, rhs: Int) {
        for i in 0..<count {
            f(&self[i], rhs)
        }
    }
}
