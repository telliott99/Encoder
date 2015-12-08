import Foundation

class Encoder {
    let key: String
    let i: UInt32
    init(_ input: String) {
        key = input
        
        // total hack, need String -> UInt32
        var n = Int(key.hashValue)
        if n < 0 { n *= -1 }
        let maxI = Int(UInt32.max)
        if n >= maxI { n = n % maxI }
        i = UInt32(n)
        
        seed()
    }
    func seed() {
        srand(i)
    }
    func next() -> UInt8 {
        return UInt8( Int(rand()) % 256 )
    }
    
    func keyStream(length: Int) -> BinaryData {
        var arr: BinaryData = []
        for _ in 0..<length {
            arr.append(self.next())
        }
        return arr
    }
    
    func xor(a1: BinaryData, _ a2: BinaryData) -> BinaryData {
        return Zip2Sequence(a1,a2).map { $0^$1 }
    }
    
    func encode(u: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(u.count)
        return xor(u,ks)
    }
    
    func decode(a: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(a.count)
        return xor(a,ks)
    }
}