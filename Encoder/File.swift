import Cocoa

func runOpenPanel(_ allowedFileTypes: String,
                  prompt: String) -> URL? {
    let op = NSOpenPanel()
    op.prompt = prompt
    op.allowsMultipleSelection = false
    // op.canChooseDirectories = true  // default
    op.resolvesAliases = true
    op.allowedFileTypes = [allowedFileTypes]
    let home = NSHomeDirectory()
    let d = home + "/Desktop/"
    op.directoryURL = URL(string: d)
    op.runModal()
    return op.url
}

func loadDataFileHandler() -> BinaryData? {
    let url = runOpenPanel("bin", prompt: "Open Data File:")
    if url == nil {
        return nil
    }
    let data = try? Data(contentsOf: url!)
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
            contentsOf:url!,
            encoding: String.Encoding.utf8)
    }
    catch {
        return nil
    }
    return s
}

func runSavePanel(_ allowedFileTypes: String,
    prompt: String) -> URL? {
    let sp = NSSavePanel()
    sp.prompt = prompt
    // op.canChooseDirectories = true  // default
    sp.allowedFileTypes = [allowedFileTypes]
    let home = NSHomeDirectory()
    let d = home + "/Desktop/"
    sp.directoryURL = URL(string: d)
    sp.runModal()
    return sp.url
}

func saveFileHandler(_ currentData: BinaryData) -> Bool {
    let url = runSavePanel("bin", prompt: "Save Data To File:")
    if url == nil {
        return false
    }
    let data = Data(bytes: UnsafePointer<UInt8>(currentData),
        count: currentData.count)
    try? data.write(to: url!, options: [.atomic])
    
    return true
}

func saveDecodedTextFileHandler(_ decodedText: String) -> Bool {
    let url = runSavePanel("txt",
              prompt: "Save Decoded Text: ")
    if url == nil {
        return false
    }
    do {
            try decodedText.write(
            to: url!,
            atomically: true,
            encoding: String.Encoding.utf8)
    }
    catch {
        return false
    }
    return true
}

