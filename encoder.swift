import Foundation
import RandFW

/*
The basic data type is [UInt8], or BinaryData
Conversions from that type are for display only
*/

typealias BinaryData = [UInt8]

func binaryFormat(_ input: BinaryData, limit: Int) -> String {
    let sa = input.map { NSString(format: "%x", $0) as String }
    // couldn't figure this one out as map
    func pad(s: String) -> String { 
        if s.characters.count == 2 { return s }
        return "0" + s
    }
    let ret = sa.map(pad)[0..<limit]
    return ret.joined(separator: " ")
}

func binaryDataToString(_ input: BinaryData) -> String {
    let ret = input.map { String(Character(UnicodeScalar(UInt32($0))!)) }
    return ret.joined()
}

func stringToIntArray(_ s: String) -> BinaryData {
    return s.utf8.map{ UInt8($0) }
}

func chunks(_ s: String, _ size: Int) -> [String] {
    var ret: [String] = []
    var current = ""
    var i = 0
    for c in s.characters {
        let wl = "0123456789abcdef".characters
        if !wl.contains(c) { continue }
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
    let cL = "0123456789abcdef".characters
    let chars = cL.map { String($0) }
    for k1 in chars {
        for k2 in chars {
            let i = chars.index(of: k1)!
            let j = chars.index(of: k2)!
            D[k1+k2] = UInt8(i*16 + j)
        }
    }
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
        srand2(Int32(i))
    }
    func next() -> UInt8 {
        return UInt8( Int(rand2()) % 256 )
    }
    
    func keyStream(length: Int) -> BinaryData {
        var arr: BinaryData = []
        for _ in 0..<length {
            arr.append(self.next())
        }
    return arr
    }
    
    func xor(_ a1: BinaryData, _ a2: BinaryData) -> BinaryData {
        return zip(a1,a2).map { $0^$1 }
    }
    
    func encode(_ u: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(length: u.count)
        return xor(u,ks)
    }

    func decode(_ a: BinaryData) -> BinaryData {
        self.seed()
        let ks = self.keyStream(length: a.count)
        return xor(a,ks)
    }
}

func loadText(_ tfn: String) -> String {
    var plaintext: String
    do {
        plaintext = try String(contentsOfFile:tfn, 
        encoding: String.Encoding.utf8)
    }
    catch {
        print("could not read message file")
        exit(0)
    }
    return plaintext
}

func loadBinaryData(_ bfn: String) -> NSData? {
    var data: NSData
    data = NSData(contentsOfFile:bfn)!
    return data
}


func loadArgs() -> [String] {
    let args = CommandLine.arguments
    
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
    let pad = String(repeating: "X", count: n)
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
                             
    // data.writeToFile("out.bin", atomically: true)
    
    // must have:  "file://"
    let home =  NSHomeDirectory()
    let d = "file://" + home + "/Desktop/"
    let path = NSURL(string: d + "out.bin") as URL?
    
    do { try data.write(to: path!, options: .atomic) }
    catch { print("Oops.  Error info: \(error)") }

    
} else {  // decoding
    let cipher = loadBinaryData(ifn)
    if (nil == cipher) {
        print("could not load encrypted data file")
        exit(0)
    }
    
    // this is not how you are supposed to do it, but 
    // I couldn't figure it out using NSData!!
    
    let D = dictionaryBytesToInts()
    let stringBytes = chunks(String.init(describing: cipher!),2)
    print("b:  \(stringBytes[0..<8])")
    
    // we convert "a3" to 163, etc.
    let bytes = stringBytes.map { UInt8(D[$0]!) }
    print("c:  \(bytes[0..<sz]) ... ")
    
    let decoded = enc.decode(bytes)
    print("d:  \(decoded[0..<sz]) ... ")
    print(binaryDataToString(decoded))
}

/*
Updated to Swift3 01-18-2017:

**requires my framework that wraps srand and rand**

> xcrun swiftc encoder.swift -o prog -F ~/Library/Frameworks -sdk $(xcrun --show-sdk-path --sdk macosx) 
> ./prog msg.txt key.txt 
key:       Four score and seven years ago
plaintext: MY SECRET IS REALLY REALLY SECRET
p:  [77, 89, 32, 83, 69, 67, 82, 69] ... 
c:  [122, 151, 198, 17, 241, 46, 39, 109] ... 
b:  7a 97 c6 11 f1 2e 27 6d ...
d:   MY SECRET IS REALLY REALLY SECRETXXXXXXX
> ./prog out.bin key.txt dec
key:       Four score and seven years ago
b:  ["7a", "97", "c6", "11", "f1", "2e", "27", "6d"]
c:  [122, 151, 198, 17, 241, 46, 39, 109] ... 
d:  [77, 89, 32, 83, 69, 67, 82, 69] ... 
MY SECRET IS REALLY REALLY SECRETXXXXXXX
>

> hexdump out.bin
0000000 7a 97 c6 11 f1 2e 27 6d d5 5c a3 0a 91 83 17 df
0000010 03 d1 b8 3c 9e 9e ec bc 5d 5d 68 92 99 93 5b 69
0000020 68 a9 2e 76 2e 39 8f f3                        
0000028
>

*/
