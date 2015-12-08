import Cocoa

func loadDataFileHandler() -> BinaryData? {
    let op = NSOpenPanel()
    op.prompt = "Open Data File:"
    op.allowsMultipleSelection = false
    // op.canChooseDirectories = true  // default
    op.resolvesAliases = true
    op.allowedFileTypes = ["bin"]
    
    let home = NSHomeDirectory()
    let d = home.stringByAppendingString("/Desktop/")
    op.directoryURL = NSURL(string: d)
    op.runModal()
    if op.URL == nil {
        return nil
    }
    
    let data = NSData(contentsOfURL:op.URL!)
    if nil == data { return nil }
    
    /*
    let stringBytes = chunks(String(data!),2)
    // Swift.print(stringBytes)
    
    // we convert "a3" to 163, etc.
    // not how this should be done!!

    let D = dictionaryBytesToInts()
    let bytes = stringBytes.map { UInt8(D[$0]!) }
    
    // Swift.print(bytes)
    */
    
    let bytes = dataToBinaryData(data!)
    return bytes
}

func loadTextFileHandler() -> String? {
    let op = NSOpenPanel()
    op.prompt = "Open Text File:"
    op.allowsMultipleSelection = false
    // op.canChooseDirectories = true  // default
    op.resolvesAliases = true
    op.allowedFileTypes = ["txt"]
    
    let home = NSHomeDirectory()
    let d = home.stringByAppendingString("/Desktop/")
    op.directoryURL = NSURL(string: d)
    op.runModal()
    if op.URL == nil {
        return nil
    }
    var s: String = ""
    do {
        s = try String(contentsOfURL:op.URL!, encoding: NSUTF8StringEncoding)
    }
    catch {
        return nil
    }
    return s
}

func saveFileHandler(currentData: BinaryData) -> Bool {
    let sp = NSSavePanel()
    sp.prompt = "Save Data To File:"
    // op.canChooseDirectories = true  // default
    sp.allowedFileTypes = ["bin"]
    
    let home = NSHomeDirectory()
    let d = home.stringByAppendingString("/Desktop/")
    sp.directoryURL = NSURL(string: d)
    sp.runModal()
    if sp.URL == nil {
        return false
    }
    
    let data = NSData(bytes: currentData,
        length: currentData.count)
    data.writeToURL(sp.URL!, atomically: true)
    
    return true
}
