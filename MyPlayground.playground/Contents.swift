import Foundation

let key = "my secret"
var n = Int(key.hashValue)
if n < 0 { n *= -1 }
let maxI = Int(UInt32.max)
n = n % maxI
let i = UInt32(n)
srand(i)


let a: [UInt8] = Array(0..<4) + [255]
let data = NSData(bytes: a, length: 5)
let s = String(data)
print(s)  // s is equal to:  "<00010203ff>"


