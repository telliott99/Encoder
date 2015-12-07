import Foundation

/*
The basic data type is [UInt8], or BinaryData
Conversions from that type are for display only
*/

typealias BinaryData = [UInt8]

func binaryFormat(input: BinaryData, limit: Int) -> String {
    let sa = input.map { NSString(format: "%x", $0) as String }
    // couldn't figure this one out as map
    func pad(s: String) -> String { 
        if s.characters.count == 2 { return s }
        return "0" + s
    }
    let ret = sa.map(pad)[0..<limit]
    return ret.joinWithSeparator(" ")
}

func binaryDataToString(input: BinaryData) -> String {
    let ret = input.map { String(Character(UnicodeScalar(UInt32($0)))) }
    return ret.joinWithSeparator("")
}

func stringToIntArray(s: String) -> BinaryData {
    return s.utf8.map{ UInt8($0) }
}

func chunks(s: String, _ size: Int) -> [String] {
    var ret: [String] = []
    var current = ""
    var i = 0
    for c in s.characters {
        if !"0123456789abcdef".characters.contains(c) { continue }
        if (i % 2) == 0 {
            current += String(c)
        }
        else {
            current += String(c)
            ret.append(current)
            current = ""
        }
        i += 1
    }
    return ret
}

func dictionaryBytesToInts() -> [String:UInt8] {

    var D: [String:UInt8] = [:]
    let chars = "0123456789abcdef".characters.map { String($0) }
    for k1 in chars {
        for k2 in chars {
            let i = chars.indexOf(k1)!
            let j = chars.indexOf(k2)!
            D[k1+k2] = UInt8(i*16 + j)
        }
    }

    /*
    var D: [String:UInt8] = [:]
    for (k,v) in Zip2Sequence( 
            "0123456789abcdef".characters.map { String($0) },
            [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] ) {
        D[k] = UInt8(v)
    }

    var D2: [String:UInt8] = [:]
    for k1 in D.keys {
        for k2 in D.keys {
            let v = D[k1]! * 16 + D[k2]!
            D2[k1+k2] = v
        }
    }
    */
    
    return D
}

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

func loadKey(kfn: String) -> String {
    var key: String
    do {
        key = try String(contentsOfFile:kfn, 
        encoding: NSUTF8StringEncoding)
    }
    catch {
        print("could not read key file")
        exit(0)
    }
    return key
}

func loadText(tfn: String) -> String {
    var plaintext: String
    do {
        plaintext = try String(contentsOfFile:tfn, 
        encoding: NSUTF8StringEncoding)
    }
    catch {
        print("could not read message file")
        exit(0)
    }
    return plaintext
}

func loadBinaryData(bfn: String) -> NSData? {
    var data: NSData
    data = NSData(contentsOfFile:bfn)!
    return data
}


func loadArgs() -> [String] {
    let args = Process.arguments
    
    // no error handling
    // I really need a library for this
    if args.count < 3 { exit(0) }

    let fn = args[1]
    let kfn = args[2]
    var ret = [fn,kfn]
    if args.count > 3 {
        ret.append("decode")
    }
    return ret
}

let args = loadArgs()
let ifn = args[0]
let kfn = args[1]
let key = loadText(kfn)
print("key:       \(key)")

let enc = Encoder(key)
let encoding = args.count == 2
let sz = 8

if encoding {
    var plaintext = loadText(ifn)
    print("plaintext: \(plaintext)")
    let n = 8 - plaintext.utf8.count % 8
    let pad = String(count: n,repeatedValue: Character("X"))
    plaintext += pad

    var p = stringToIntArray(plaintext)
    print("p:  \(p[0..<sz]) ... ")
        
    let cipher = enc.encode(p)
    print("c:  \(cipher[0..<sz]) ... ")
    let b = binaryFormat(cipher, limit: 8)
    print("b:  \(b) ...")

    let decoded = enc.decode(cipher)
    print("d:   \(binaryDataToString(decoded))")
    
    let data = NSData(bytes: cipher, 
                             length: cipher.count)
    data.writeToFile("out.bin", atomically: true)
    
} else {  // decoding
    let cipher = loadBinaryData(ifn)
    if (nil == cipher) {
        print("could not load encrypted data file")
        exit(0)
    }
    
    // this is not how you are supposed to do it, but 
    // I couldn't figure it out using NSData!!
    
    let D = dictionaryBytesToInts()
    let stringBytes = chunks(String(cipher!),2)
    print("b:  \(stringBytes[0..<8])")
    
    // we convert "a3" to 163, etc.
    let bytes = stringBytes.map { UInt8(D[$0]!) }
    print("c:  \(bytes[0..<sz]) ... ")
    
    let decoded = enc.decode(bytes)
    print("d:  \(decoded[0..<sz]) ... ")
    print(binaryDataToString(decoded))
}

/*
Sample output:

> xcrun swift encrypter.swift msg.txt key.txt
key:       Four score and seven years ago
plaintext: MY SECRET IS REALLY REALLY SECRET
p:  [77, 89, 32, 83, 69, 67, 82, 69] ... 
c:  [234, 129, 174, 52, 199, 135, 21, 51] ... 
b:  ea 81 ae 34 c7 87 15 33 ...
d:   MY SECRET IS REALLY REALLY SECRETXXXXXXX
> xcrun swift encrypter.swift out.bin key.txt d
key:       Four score and seven years ago
b:  ["ea", "81", "ae", "34", "c7", "87", "15", "33"]
c:  [234, 129, 174, 52, 199, 135, 21, 51] ... 
d:  [77, 89, 32, 83, 69, 67, 82, 69] ... 
MY SECRET IS REALLY REALLY SECRETXXXXXXX
> hexdump out.bin
0000000 ea 81 ae 34 c7 87 15 33 a1 9a 66 22 87 a6 48 f2
0000010 9b 65 18 19 bf f4 96 8e 0a 0e 20 89 2b ae 11 7b
0000020 59 8f f7 42 9a 82 b2 72                        
0000028
>

*/


