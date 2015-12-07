import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var plainTextField: NSTextField!
    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var dataTextField: NSTextField!
    @IBOutlet weak var decodedTextField: NSTextField!
    
    let defaultText = "MY SECRET IS REALLY REALLY SECRET"
    let defaultKey = "Four score and seven years ago"
    var currentData = BinaryData()
    let lineLength = 40

    override func windowDidLoad() {
        super.windowDidLoad()
        self.plainTextField.stringValue = defaultText
        self.keyTextField.stringValue = defaultKey
    }
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    func displayCurrentData() {
        let s = binaryFormat(currentData, limit: 16)
        dataTextField.stringValue = s + " ..."
    }
    
    func displayDecodedData(decodedData: BinaryData) {
        let s = binaryDataToString(decodedData)
        displayText(decodedTextField, s)
    }
    
    func getEncoder() -> Encoder {
        let k = keyTextField.stringValue
        return Encoder(k)
    }
    
    @IBAction func encode(sender: AnyObject) {
        let p = plainTextField.stringValue
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
        tf.stringValue = s.insertSeparator("\n",
            every: lineLength)
    }
    
    @IBAction func loadData(sender: AnyObject) {
        let data = loadDataFileHandler()
        if nil == data { return }
        currentData = data!
        displayCurrentData()
        decodedTextField.stringValue = ""
        keyTextField.stringValue = ""
        plainTextField.stringValue = ""
    }
    
    @IBAction func loadText(sender: AnyObject) {
        let s = loadTextFileHandler()
        if nil == s { return }
        decodedTextField.stringValue = ""
        keyTextField.stringValue = ""
        displayText(plainTextField, s!)
    }
}
