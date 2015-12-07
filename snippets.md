```swift
var n = Int(key.hashValue)
if n < 0 { n *= -1 }
let maxI = Int(UInt32.max)
if n >= maxI { n = n % maxI }
i = UInt32(n)
srand(i)
```

Dictionary to go from "ff" to 255, and so on.

```swift
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
    return D
}
````