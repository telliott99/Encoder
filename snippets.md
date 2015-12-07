```swift
  var n = Int(key.hashValue)
  if n < 0 { n *= -1 }
  let maxI = Int(UInt32.max)
  if n >= maxI { n = n % maxI }
  i = UInt32(n)
  srand(i)

```