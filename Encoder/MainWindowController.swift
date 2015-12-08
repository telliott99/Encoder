import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var plainTextField: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var dataTextField: NSTextField!
    @IBOutlet weak var decodedTextField: NSTextField!
    
    let defaultText = "MY SECRET IS REALLY REALLY SECRET"
    let defaultKey = "Four score and seven years ago"
    var currentData = BinaryData()
    var decodedText = ""

    override func windowDidLoad() {
        super.windowDidLoad()
        self.plainTextField.stringValue = defaultText
        self.keyTextField.stringValue = defaultKey
    }
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    func displayCurrentData() {
        let s = binaryFormat(currentData, limit: 8)
        let fs = formatForScreen(s)
        dataTextField.stringValue = fs
    }
    
    func displayDecodedData(decodedData: BinaryData) {
        decodedText = binaryDataToString(decodedData)
        // s.stripNewlines()
        // let fs = formatForScreen(s)
        displayText(decodedTextField, decodedText)
    }
    
    func getEncoder() -> Encoder {
        let k = keyTextField.stringValue
        return Encoder(k)
    }
    
    @IBAction func encode(sender: AnyObject) {
        let p = plainTextField.stringValue
        // Swift.print(p)
        p.stripNewlines()
        let data = plaintextStringToIntArray(p)
        
        let encoder = getEncoder()
        currentData = encoder.encode(data)
        displayCurrentData()
        decodedTextField.stringValue = ""
    }
    
    @IBAction func decode(sender: AnyObject) {
        let decoder = getEncoder()
        let decodedData = decoder.decode(currentData)
        displayDecodedData(decodedData)
    }
    
    @IBAction func saveData(sender: AnyObject) {
        let _ = saveFileHandler(currentData)
    }
    
    func displayText(tf: NSTextField, _ s: String) {
        let fs = formatForScreen(s)
        tf.stringValue = fs
    }
    
    func resetAllTextFields() {
        decodedTextField.stringValue = ""
        keyTextField.stringValue = ""
        plainTextField.stringValue = ""
    }
    
    @IBAction func loadData(sender: AnyObject) {
        let data = loadDataFileHandler()
        if nil == data { return }
        currentData = data!
        displayCurrentData()
        resetAllTextFields()
    }
    
    @IBAction func loadText(sender: AnyObject) {
        let s = loadTextFileHandler()
        if nil == s { return }
        decodedTextField.stringValue = ""
        keyTextField.stringValue = ""
        displayText(plainTextField, s!)
    }
    
    @IBAction func saveDecodedText(sender: AnyObject) {
        saveDecodedTextFileHandler(decodedText)
    }
}
