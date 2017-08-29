
public struct MySequence<T>: Sequence {
    let array: [T]
    
    public init(array: [T]) {
        self.array = array
    }
    
    public func makeIterator() -> MyIterator<T> {
        return MyIterator(array: array)
    }
}

public struct MyIterator<T>: IteratorProtocol {
    let array: [T]
    var p = 0
    
    init(array: [T]) {
        self.array = array
    }
    
    @_specialize(Float)
    public mutating func next() -> T? {
        guard p < array.count else {
            return nil
        }
        p += 1
        return array[p-1]
    }
}

public struct MyFloatSequence: Sequence {
    let array: [Float]
    
    public init(array: [Float]) {
        self.array = array
    }
    
    public func makeIterator() -> MyFloatIterator {
        return MyFloatIterator(array: array)
    }
}

public struct MyFloatIterator: IteratorProtocol {
    let array: [Float]
    var p = 0
    
    init(array: [Float]) {
        self.array = array
    }
    
    public mutating func next() -> Float? {
        guard p < array.count else {
            return nil
        }
        p += 1
        return array[p-1]
    }
}
