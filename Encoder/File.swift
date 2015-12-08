import Cocoa

func runOpenPanel(allowedFileTypes: String,
                  prompt: String) -> NSURL? {
    let op = NSOpenPanel()
    op.prompt = prompt
    op.allowsMultipleSelection = false
    // op.canChooseDirectories = true  // default
    op.resolvesAliases = true
    op.allowedFileTypes = [allowedFileTypes]
    let home = NSHomeDirectory()
    let d = home.stringByAppendingString("/Desktop/")
    op.directoryURL = NSURL(string: d)
    op.runModal()
    return op.URL
}

func loadDataFileHandler() -> BinaryData? {
    let url = runOpenPanel("bin", prompt: "Open Data File:")
    if url == nil {
        return nil
    }
    let data = NSData(contentsOfURL:url!)
    if nil == data {
        return nil
    }
    let bytes = dataToBinaryData(data!)
    return bytes
}

func loadTextFileHandler() -> String? {
    let url = runOpenPanel("txt", prompt: "Open Text File:")
    if url == nil {
        return nil
    }
    var s: String = ""
    do {
        s = try String(
            contentsOfURL:url!,
            encoding: NSUTF8StringEncoding)
    }
    catch {
        return nil
    }
    return s
}

func runSavePanel(allowedFileTypes: String,
    prompt: String) -> NSURL? {
    let sp = NSSavePanel()
    sp.prompt = prompt
    // op.canChooseDirectories = true  // default
    sp.allowedFileTypes = [allowedFileTypes]
    let home = NSHomeDirectory()
    let d = home.stringByAppendingString("/Desktop/")
    sp.directoryURL = NSURL(string: d)
    sp.runModal()
    return sp.URL
}

func saveFileHandler(currentData: BinaryData) -> Bool {
    let url = runSavePanel("bin", prompt: "Save Data To File:")
    if url == nil {
        return false
    }
    let data = NSData(bytes: currentData,
        length: currentData.count)
    data.writeToURL(url!, atomically: true)
    
    return true
}

func saveDecodedTextFileHandler(decodedText: String) -> Bool {
    let url = runSavePanel("txt",
              prompt: "Save Decoded Text: ")
    if url == nil {
        return false
    }
    do {
            try decodedText.writeToURL(
            url!,
            atomically: true,
            encoding: NSUTF8StringEncoding)
    }
    catch {
        return false
    }
    return true
}

