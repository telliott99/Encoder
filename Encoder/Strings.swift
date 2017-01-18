import Foundation

func chunks(_ s: String, _ size: Int) -> [String] {
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

extension String {
    func divideStringIntoChunks(chunkSize n: Int) -> [String] {
        var ret = [String]()
        var current = self
        while true {
            let m = current.characters.count
            if m == 0 {
                break
            }
            if m < n {
                ret.append(current)
                break
            }
            let i = current.characters.index(current.startIndex, offsetBy: n)
            let front = current.substring(to: i)
            ret.append(front)
            current = current.substring(from: i)
        }
        return ret
    }
    
    /*
    func insertSeparator(sep: String, every n: Int) -> String {
        let ret = self.divideStringIntoChunks(chunkSize: n)
        return ret.joinWithSeparator(sep)
    }
    */
    
    func stripOccurrencesOfCharactersInList(_ cL: CharacterView) -> String {
        /*
        get the CharacterView, like an [Character]
        split to chunks on newlines, takes a closure
        
        the results are not Strings which joinWithSeparator requires,
        so do the conversion for each one with map
        */
        
        var a = [Character]()
        for c in self.characters {
            if cL.contains(c) {
                continue
            }
            a.append(c)
        }
        return a.map{String($0)}.joined(separator: "")
    }
    
    func stripNewlines() -> String {
        let cL = "\n".characters
        return self.stripOccurrencesOfCharactersInList(cL)
    }
}

/*
break a string into words
form the words into lines of a max length
do this by looking ahead to see if we go over length
if so, flush the buffer
*/

func formatForScreen(_ s: String, length n: Int = 50) -> String {
    func countEm(_ a: [String]) -> Int {
        var count = 0
        for s in a {
            count += s.characters.count + 1
        }
        return count
    }
    var sa = s.characters.split{$0 == " "}.map { String($0) }
    var result: [[String]] = []
    var buffer: [String] = []
    
    // assumes no string is > n in length
    while true {
        if sa.count == 0 {
            result.append(buffer)
            break
        }
        
        let next = sa.removeFirst()
        // Swift.print(next)
        
        if countEm(buffer) + next.characters.count >= n {
            // Swift.print("appending \(buffer)")
            result.append(buffer)
            buffer = []
        }
        buffer.append(next)
    }
    
    let ret = result.map { $0.joined(separator: " ") }
    return ret.joined(separator: "\n")
}
