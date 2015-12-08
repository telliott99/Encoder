import Foundation

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
            let i = current.startIndex.advancedBy(n)
            let front = current.substringToIndex(i)
            ret.append(front)
            current = current.substringFromIndex(i)
        }
        return ret
    }
    
    /*
    func insertSeparator(sep: String, every n: Int) -> String {
        let ret = self.divideStringIntoChunks(chunkSize: n)
        return ret.joinWithSeparator(sep)
    }
    */
    
    func stripOccurrencesOfCharactersInList(cL: CharacterView) -> String {
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
        return a.map{String($0)}.joinWithSeparator("")
    }
    
    func stripNewlines() -> String {
        let cL = "\n".characters
        return self.stripOccurrencesOfCharactersInList(cL)
    }
}

func formatForScreen(s: String, length n: Int = 50) -> String {
    func countEm(a: [String]) -> Int {
        var count = 0
        for s in a {
            count += s.characters.count + 1
        }
        return count
    }
    var sa = s.characters.split{$0 == " "}.map { String($0) }
    var result: [[String]] = []
    var tmp: [String] = []
    
    // assumes no string is > n in length
    while true {
        if sa.count == 0 {
            result.append(tmp)
            break
        }
        
        let next = sa.removeFirst()
        Swift.print(next)
        
        if countEm(tmp) + next.characters.count >= n {
            Swift.print("appending \(tmp)")
            result.append(tmp)
            tmp = []
        }
        tmp.append(next)
    }
    
    let ret = result.map { $0.joinWithSeparator(" ") }
    return ret.joinWithSeparator("\n")
}
