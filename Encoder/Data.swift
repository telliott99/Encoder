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

func plaintextStringToIntArray(s: String) -> BinaryData {
    return s.utf8.map{ UInt8($0) }
}

