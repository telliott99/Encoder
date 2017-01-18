import Foundation

/*
The basic data type is
typealias BinaryData = [UInt8]

Conversions from that type are for display only
*/

typealias BinaryData = [UInt8]

/*
binaryFormat
BinaryData -> String
called by:  displayCurrentData
format data for display on screeen as ae 01 ff ...
*/

func binaryFormat(_ input: BinaryData, limit: Int) -> String {
    // added length check here, but same problem
    // cannot subscript [String] ...  which I don't understand
    
    var ia = input
    let tooLong = ia.count > limit
    if tooLong {
        ia = []
        for i in 0..<limit {
            ia.append(input[i])
        }
    }
    
    let sa = ia.map { NSString(format: "%x", $0) as String }
    
    // couldn't figure this one out as map
    func pad(_ s: String) -> String {
        if s.characters.count == 2 { return s }
        return "0" + s
    }
    
    // crashed here on short messages
    // however, adding a check for length runs into
    // cannot subscript Array<String> !!
    
    //let ret = sa.map(pad)[0..<limit]
    
    var s = sa.map(pad).joined(separator: " ")
    if tooLong { s += " ..." }
    
    return s
}

/*
binaryDataToString
BinaryData -> String
called by:  displayDecodedData
convert decoded data back to String
*/

func binaryDataToString(_ input: BinaryData) -> String {
    let ret = input.map { String(Character(UnicodeScalar(UInt32($0))!)) }
    return ret.joined(separator: "")
}

/*
plaintextStringToIntArray
String -> BinaryData
called by:  displayDecodedData
*/

func plaintextStringToIntArray(_ s: String) -> BinaryData {
    return s.utf8.map{ UInt8($0) }
}

/*
dataToBinaryData
NSData -> BinaryData [UInt8]
called by:  loadDataFileHandler
*/


func dataToBinaryData(_ data: Data) -> [UInt8] {
    let stream = InputStream(data: data)
    stream.open()
    
    // having loaded data from a file
    // how to know how large a buffer we will need?
    // data knows its length !!
    let n = data.count
    
    var buffer = Array<UInt8>(
        repeating: 0,
        count: n * MemoryLayout<UInt8>.size)
    
    stream.read(&buffer, maxLength: n)
    return buffer
}


