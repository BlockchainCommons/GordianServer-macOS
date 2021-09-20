//
//  Settings.swift
//  StandUp
//
//  Created by Peter on 08/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class Settings: NSViewController, NSTextFieldDelegate {
    
    var window: NSWindow?
    var filesList: [URL] = []
    var showInvisibles = false
    var selectedFolder:URL!
    var selectedItem:URL!
    let ud = UserDefaults.standard
    var seeLog = Bool()
    var standingDown = Bool()
    var args = [String]()
    var refreshing = Bool()
    
    @IBOutlet weak var pruneValueField: NSTextField!
    @IBOutlet var directoryLabel: NSTextField!
    @IBOutlet var walletDisabled: NSButton!
    @IBOutlet var txIndexOutlet: NSButton!
    @IBOutlet var goPrivateOutlet: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pruneValueField.delegate = self
        let d = Defaults()
        d.setDefaults() { [unowned vc = self] in
            vc.getSettings()
        }
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "Settings"
    }
    
    // MARK: User Actions
    
    @IBAction func goPrivate(_ sender: Any) {
        let value = goPrivateOutlet.state
        if value == .on {
            actionAlert(message: "Go private?", info: "This sets your proxy to the local host and tors control port, binds localhost address, and sets listen to true in your bitcoin.conf, in plain english this means your node will only accept connections over the Tor network, this can make initial block download very slow, it is recommended to go private once your node is fully synced.") { [unowned vc = self] (response) in
                if response {
                    vc.privateOn()
                } else {
                    vc.revert(outlet: vc.goPrivateOutlet)
                }
            }
        } else {
            actionAlert(message: "Disable?", info: "This will enable your node to connect to other nodes over the clearnet, not just over tor, it is recommended to disable this setting when your node is doing the initial block download.") { [unowned vc = self] (response) in
                if response {
                    vc.privateOff()
                } else {
                    vc.revert(outlet: vc.goPrivateOutlet)
                }
            }
        }
    }
    
    func privateOn() {
        var proxyExists = false
        var debugExists = false
        var bindExists = false
        var listenExists = false
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                var stringConf = conf!.joined(separator: "\n")
                for c in conf! {
                    if c.contains("=") {
                        let arr = c.components(separatedBy: "=")
                        let k = arr[0]
                        let existingValue = arr[1]
                        switch k {
                        case "#debug":
                            debugExists = true
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "debug=tor")
                            
                        case "#proxy":
                            proxyExists = true
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "proxy=127.0.0.1:9050")
                            
                        case "#listen":
                            listenExists = true
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "listen=1")
                            
                        case "#bindaddress":
                            bindExists = true
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "bindaddress=127.0.0.1")
                            
                        default:
                            break
                        }
                    }
                }
                if !debugExists {
                    stringConf = "debug=tor\n" + stringConf
                }
                if !proxyExists {
                    stringConf = "proxy=127.0.0.1:9050\n" + stringConf
                }
                if !listenExists {
                    stringConf = "listen=1\n" + stringConf
                }
                if !bindExists {
                    stringConf = "bindaddress=127.0.0.1\n" + stringConf
                }
                vc.setBitcoinConf(conf: stringConf, activeOutlet: vc.goPrivateOutlet, newValue: 3, key: "")
            } else {
                simpleAlert(message: "Error", info: "We had a problem getting your bitcoin.conf, please try again", buttonLabel: "OK")
            }
        }
    }
    
    func privateOff() {
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                var stringConf = conf!.joined(separator: "\n")
                for c in conf! {
                    if c.contains("=") {
                        let arr = c.components(separatedBy: "=")
                        let k = arr[0]
                        let existingValue = arr[1]
                        switch k {
                        case "debug", "#debug":
                            if existingValue == "tor" {
                                stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "#debug=\(existingValue)")
                            }
                            
                        case "proxy", "#proxy":
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "#proxy=\(existingValue)")
                            
                        case "listen", "#listen":
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "#listen=\(existingValue)")
                            
                        case "bindaddress", "#bindaddress":
                            stringConf = stringConf.replacingOccurrences(of: "\(k + "=" + existingValue)", with: "#bindaddress=\(existingValue)")
                            
                        default:
                            break
                        }
                    }
                }
                vc.setBitcoinConf(conf: stringConf, activeOutlet: vc.goPrivateOutlet, newValue: 3, key: "")
            } else {
                simpleAlert(message: "Error", info: "We had a problem getting your bitcoin.conf, please try again", buttonLabel: "OK")
            }
        }
    }
    
    @IBAction func removeBitcoinCore(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            destructiveActionAlert(message: "Danger! Master kill switch!", info: "This action PERMANENTLY, IMMEDIATELY and IRREVERSIBLY deletes ALL WALLETS, Bitcoin Core binaries, and Gordian Server Tor related files and directories!") { response in
                if response {
                    let d = Defaults()
                    let env = ["DATADIR":d.dataDir()]
                    vc.runScript(script: .removeBitcoin, env: env, args: []) { success in
                        if success {
                            simpleAlert(message: "Your system has been purged.", info: "", buttonLabel: "OK")
                        } else {
                           simpleAlert(message: "Error", info: "There was an issue deleting the directory", buttonLabel: "OK")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didSetWalletDisabled(_ sender: Any) {
        let value = walletDisabled.state.rawValue
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                vc.parseBitcoinConf(conf: conf!, keyToUpdate: .disablewallet, outlet: vc.walletDisabled, newValue: value)
            }
        }
    }
    
    @IBAction func didSetTxIndex(_ sender: Any) {
        let value = txIndexOutlet.state.rawValue
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                if conf!.count > 0 {
                    vc.parseBitcoinConf(conf: conf!, keyToUpdate: .txindex, outlet: vc.txIndexOutlet, newValue: value)
                }
            } else {
                vc.ud.set(value, forKey: "txindex")
                if value == 1 {
                    vc.ud.set(0, forKey: "prune")
                }
            }
        }
    }
    
    @IBAction func chooseDirectory(_ sender: Any) {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { [unowned vc = self] (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                vc.selectedFolder = panel.urls[0]
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.directoryLabel.stringValue = self.selectedFolder?.path ?? Defaults().blocksDir()
                    
                    self.getBitcoinConf { [unowned vc = self] (conf, error) in
                        if !error && conf != nil {
                            var stringConf = conf!.joined(separator: "\n")
                            if stringConf.contains("blocksdir=") {
                                for item in conf! {
                                    if item.hasPrefix("blocksdir=") {
                                        let existingValue = item.replacingOccurrences(of: "blocksdir=", with: "")
                                        stringConf = stringConf.replacingOccurrences(of: "blocksdir=\(existingValue)", with: "blocksdir=\(vc.directoryLabel.stringValue)")
                                        /// Remove appended newline before saving.
                                        stringConf.removeLast()
                                        self.setBlocksDir(conf: stringConf, newValue: vc.directoryLabel.stringValue)
                                        break
                                    }
                                }
                            } else {
                                stringConf = "blocksdir=\(vc.directoryLabel.stringValue)\n\(stringConf)"
                                stringConf.removeLast()
                                self.setBlocksDir(conf: stringConf, newValue: vc.directoryLabel.stringValue)
                            }
                        } else {
                            vc.ud.set(vc.directoryLabel.stringValue, forKey: "blocksDir")
                            vc.getSettings()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Action Logic
    
    func setLog(content: String) {
        Log.writeToLog(content: content)
    }
    
    func setBitcoinConf(conf: String, activeOutlet: NSButton?, newValue: Int, key: String) {
        let d = Defaults()
        let env = ["CONF":conf,"DATADIR":d.dataDir()]
        runScript(script: .updateBTCConf, env: env, args: args) { [unowned vc = self] success in
            if success {
                if newValue < 2 || key == "prune" {
                    vc.ud.set(newValue, forKey: key)
                }
                simpleAlert(message: "Success", info: "bitcoin.conf updated", buttonLabel: "OK")
            } else {
                simpleAlert(message: "Error Updating bitcoin.conf", info: "", buttonLabel: "OK")
            }
        }
    }
    
    func setBlocksDir(conf: String, newValue: String) {
        let d = Defaults()
        let env = ["CONF":conf,"DATADIR":d.dataDir()]
        runScript(script: .updateBTCConf, env: env, args: args) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.ud.set(newValue, forKey: "blocksDir")
                simpleAlert(message: "Success", info: "bitcoin.conf updated", buttonLabel: "OK")
            } else {
                simpleAlert(message: "Error Updating bitcoin.conf", info: "", buttonLabel: "OK")
            }
            self.getSettings()
        }
    }
    
    func revert(outlet: NSButton?) {
        DispatchQueue.main.async {
            outlet?.setNextState()
        }
    }
    
    func parseBitcoinConf(conf: [String], keyToUpdate: BTCCONF, outlet: NSButton?, newValue: Int) {
        
        func alertSettingNotForCurrentNetwork() {
            simpleAlert(message: "Error", info: "You are attempting to update a setting that is network specific. You must select the correct network first then update the setting.", buttonLabel: "OK")
        }
        
        for setting in conf {
            if setting.contains("=") {
                let arr = setting.components(separatedBy: "=")
                let key = arr[0]
                let value = arr[1]
                if keyToUpdate.rawValue == key {
                    actionAlert(message: "Update bitcoin.conf?", info: "You are attemtping to update \(key)=\(value) to \(key)=\(newValue).\n\nThis is a global setting and will apply to all networks.\n\nIn order for the changes to take effect you will need to restart Bitcoin Core.\n\nAre you sure you want to proceed?") { [unowned vc = self] response in
                        if response {
                            if let i = Int(value) {
                                vc.updateGlobalConfArray(conf: conf, oldValue: i, newValue: newValue, key: key, outlet: outlet)
                            } else {
                                simpleAlert(message: "Error", info: "We had an error updating your bitcoin.conf file", buttonLabel: "OK")
                            }
                        } else {
                            vc.revert(outlet: outlet)
                        }
                    }
                }
            }
        }
    }
    
    func updateGlobalConfArray(conf: [String], oldValue: Int, newValue: Int, key: String, outlet: NSButton?) {
        for c in conf {
            if c.contains("=") {
                let arr = c.components(separatedBy: "=")
                let k = arr[0]
                let existingValue = arr[1]
                if k.contains(key) {
                    if let ev = Int(existingValue) {
                        if oldValue == ev {
                            var stringConf = conf.joined(separator: "\n")
                            stringConf = stringConf.replacingOccurrences(of: "\(key + "=" + existingValue)", with: "\(key + "=")\(newValue)")
                            if key == "txindex" && newValue == 1 {
                                stringConf = stringConf.replacingOccurrences(of: "prune=1", with: "prune=0")
                            }
                            if key == "prune" && newValue > 0 {
                                stringConf = stringConf.replacingOccurrences(of: "txindex=1", with: "txindex=0")
                                setState(int: 0, outlet: txIndexOutlet)
                            }
                            /// Remove appended newline before saving.
                            stringConf.removeLast()
                            setBitcoinConf(conf: stringConf, activeOutlet: outlet, newValue: newValue, key: key)
                        }
                    }
                }
            }
        }
    }
    
    func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            print("can not get bitcoin.conf")
            return
        }

        let conf = bitcoinConf.components(separatedBy: "\n")
        completion((conf, false))
    }
        
    // MARK: Update User Interface
    
    func goBackAndRefresh() {
        DispatchQueue.main.async { [unowned vc = self] in
            if let presenter = vc.presentingViewController as? ViewController {
                presenter.isBitcoinOn()
            }
            vc.window?.performClose(nil)
        }
    }
    
    func setState(int: Int, outlet: NSButton) {
        if int == 1 {
            DispatchQueue.main.async {
                outlet.state = .on
            }
                        
        } else if int == 0 {
            DispatchQueue.main.async {
                outlet.state = .off
            }
        }
    }
    
    func getSettings() {
        let d = Defaults()
        let pruneValue = d.prune()
        setState(int: d.txindex(), outlet: txIndexOutlet)
        setState(int: d.walletdisabled(), outlet: walletDisabled)
        setState(int: d.isPrivate(), outlet: goPrivateOutlet)
        if ud.object(forKey: "dataDir") != nil {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.directoryLabel.stringValue = d.blocksDir()
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.pruneValueField.stringValue = "\(pruneValue)"
        }
    }
    
    func getSetting(key: BTCCONF, button: NSButton, def: Int) {
        if ud.object(forKey: key.rawValue) == nil {
            ud.set(def, forKey: key.rawValue)
        } else {
            let raw = ud.integer(forKey: key.rawValue)
            if raw == 0 {
                DispatchQueue.main.async {
                    button.state = .off
                }
            } else {
                DispatchQueue.main.async {
                    button.state = .on
                }
            }
        }
    }
    
    func setOutlet(outlet: NSButton, keyOn: BTCCONF) {
        let b = outlet.state.rawValue
        let key = keyOn.rawValue
        ud.set(b, forKey: key)
        if b == 0 {
            ud.set(1, forKey: key)
        }
    }
    
    private func runScript(script: SCRIPT, env: [String:String], args: [String], completion: @escaping ((Bool)) -> Void) {
        #if DEBUG
        print("script: \(script.rawValue)")
        #endif
        let resource = script.rawValue
        guard let path = Bundle.main.path(forResource: resource, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = env
        task.arguments = args
        task.standardOutput = stdOut
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        var result = ""
        if let output = String(data: data, encoding: .utf8) {
            #if DEBUG
            print("result: \(output)")
            #endif
            result += output
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if fieldEditor.string != "" {
            if let int = Int(fieldEditor.string) {
                if int > 549 {
                    updatePruneValue(amount: int)
                }
            }
        } else {
            updatePruneValue(amount: 0)
        }
        return true
    }
    
    private func updatePruneValue(amount: Int) {
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                vc.parseBitcoinConf(conf: conf!, keyToUpdate: .prune, outlet: nil, newValue: amount)
            } else {
                var info = "It looks like you do not have an existing bitcoin.conf. Updating this setting will change the prune setting to \(amount)MiB"
                if amount <= 1 {
                    info = "It looks like you do not have an existing bitcoin.conf. Updating this setting will change the prune setting to \(amount)"
                }
                actionAlert(message: "Update prune setting?", info: info) { (response) in
                    if response {
                        self.ud.set(amount, forKey: "prune")
                        simpleAlert(message: "Success ✅", info: "Prune setting updated", buttonLabel: "OK")
                    }
                }
            }
        }
    }
    
    // MARK: Miscellaneous
    
    func infoAbout(url: URL) -> String {
      return "No information available for \(url.path)"
    }
    
    func contentsOf(folder: URL) -> [URL] {
      return []
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "seeLog":
            if let vc = segue.destinationController as? Installer {
                vc.refreshing = refreshing
                vc.seeLog = seeLog
                vc.standingDown = standingDown
            }
            
        default:
            break
        }
    }
    
}
