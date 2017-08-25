
import Foundation
import SeveralPerformanceChecks

let count = 1_000_000
let a = MyArray<Float>(repeating: 0, count: count)

_ = a.filter { $0 < 0 }

let b = MyFloatArray(repeating: 0, count: count)

_ = b.filter { $0 < 0 }

