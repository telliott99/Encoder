import Foundation
import RandFW

class Encoder {
    
    let key: String
    var i: UInt32
    
    init(_ input: String) {
        key = input
        i = 0
    }
    
    func intForKey1(_ k: String) -> UInt32 {
        // total hack, need String -> UInt32
        var n = Int(k.hashValue)
        if n < 0 { n *= -1 }
        let maxI = Int(UInt32.max)
        if n >= maxI { n = n % maxI }
        return UInt32(n)
    }
    
    func intForKey2(_ k: String) -> UInt32 {
        var n = 0
        // we can convert the utf8 to [UInt8], amazing!
        var data = BinaryData(k.utf8)
        // so as not to throw away the first utf8 byte
        data.insert(0, at: 0)
        for (i,value) in data.enumerated() {
            if i == 0 { continue }
            n += i * Int(value)
        }
        let maxI = Int(UInt32.max)
        if n >= maxI { n = n % maxI }
        return UInt32(n)
    }
    
    func seed() {
        i = intForKey2(key)
        srand2(Int32(i))
    }
    
    func next() -> UInt8 {
        return UInt8( Int(rand2()) % 256 )
    }
    
    func keyStream(_ length: Int) -> BinaryData {
        var arr: BinaryData = []
        for _ in 0..<length {
            arr.append(self.next())
        }
        return arr
    }
    
    func xor(_ a1: BinaryData, _ a2: BinaryData) -> BinaryData {
        let result = zip(a1,a2).map { $0^$1 }
        return result
    }
    
    func encode(_ u: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(u.count)
        return xor(u,ks)
    }
    
    func decode(_ a: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(a.count)
        return xor(a,ks)
    }
}
