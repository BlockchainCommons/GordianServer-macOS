//
//  Installer.swift
//  StandUp
//
//  Created by Peter on 07/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class Installer: NSViewController {
    
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var spinnerDescription: NSTextField!
    @IBOutlet var consoleOutput: NSTextView!
    
    var window: NSWindow?
    let ud = UserDefaults.standard
    var seeLog = Bool()
    var standingUp = Bool()
    var strapping = Bool()
    var standingDown = Bool()
    var upgrading = Bool()
    var showLog = Bool()
    var standUpConf = ""
    var refreshing = Bool()
    var ignoreExistingBitcoin = Bool()
    var rpcuser = ""
    var rpcpassword = ""
    var isVerifying = false
    var peerInfo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setScene()
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "Console"
        filterAction()
    }
    
    func showSpinner(description: String) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.alphaValue = 1
            vc.spinnerDescription.stringValue = description
            vc.spinner.startAnimation(vc)
            vc.spinnerDescription.alphaValue = 1
        }
    }
    
    func getURLs() {
        showSpinner(description: "Fetching latest Bitcoin Core version and URL's...")
        FetchLatestRelease.get { (dict, error) in
            
            if error != nil {
                self.hideSpinner()
                simpleAlert(message: "Error", info: "There was an error fetching the latest Bitcoin Core version number and related URL's, please check your internet connection and try again", buttonLabel: "OK")
                
            } else {
                let binaryName = dict!["macosBinary"] as! String
                let macosURL = dict!["macosURL"] as! String
                let shaURL = dict!["shaURL"] as! String
                let version = dict!["version"] as! String
                let prefix = dict!["binaryPrefix"] as! String
                let signatures = dict!["shasumsSignedUrl"] as! String
                self.showSpinner(description: "Setting Up...")
                
                if self.upgrading {
                    self.upgradeBitcoinCore(binaryName: binaryName, macosURL: macosURL, shaURL: shaURL, version: version, prefix: prefix, sigsUrl: signatures)
                } else {
                    self.standUp(binaryName: binaryName, macosURL: macosURL, shaURL: shaURL, version: version, prefix: prefix, sigsUrl: signatures)
                }
            }
        }
    }
    
    func filterAction() {
        var desc = ""
        if seeLog {
            spinner.alphaValue = 0
            seeLog = false
            getLog { (log) in
                guard let log = log else { return }
                
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.consoleOutput.string = log
                }
            }
            
        } else if peerInfo != "" {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.consoleOutput.string = self.peerInfo
                self.window?.title = "Peer Info"
                self.hideSpinner()
            }
            
        } else if isVerifying {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.spinner.startAnimation(vc)
            }
            desc = "Verifying Bitcoin Core signatures..."
            verify()
            
        } else if standingUp {
            standingUp = false
            checkExistingConf()

        } else if standingDown {
            standingDown = false
            DispatchQueue.main.async { [unowned vc = self] in
                vc.spinner.startAnimation(vc)
            }
            desc = "Standing Down..."
            standDown()

        } else if upgrading {
            getURLs()
            
        }
            
//        } else if installLightning {
//            DispatchQueue.main.async { [unowned vc = self] in
//                vc.spinner.startAnimation(vc)
//            }
//            desc = "Installing Lightning..."
//            //installLightningAction()
//            checkExistingConf()
//        }
        
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinnerDescription.stringValue = desc
        }
    }
    
    func goBack() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.hideSpinner()
            if let presenter = vc.presentingViewController as? ViewController {
                presenter.standingUp = false
                presenter.isBitcoinOn()
            }
            DispatchQueue.main.async { [unowned vc = self] in
                vc.window?.performClose(nil)
            }
        }
    }
    
    func checkExistingConf() {
        var userExists = false
        var passwordExists = false
        var proxyExists = false
        var debugExists = false
        var discoverExists = false
        var listenExists = false
        var externalIpExists = false
        
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                if conf!.count > 0 {
                    for setting in conf! {
                        if setting.contains("=") {
                            let arr = setting.components(separatedBy: "=")
                            let k = arr[0]
                            let existingValue = arr[1]
                            
                            switch k {
                            case "externalip":
                                externalIpExists = true
                                
                            case "discover", "#discover":
                                discoverExists = true
                                
                            case "blocksdir":
                                UserDefaults.standard.setValue(existingValue, forKey: "blockDir")
                                
                            case "rpcuser":
                                if existingValue != "" {
                                    userExists = true
                                    vc.rpcuser = existingValue
                                }
                                
                            case "rpcpassword":
                                if existingValue != "" {
                                    passwordExists = true
                                    vc.rpcpassword = existingValue
                                }
                                
                            case "testnet", "regtest", "signet":
                                if existingValue != "" {
                                    simpleAlert(message: "Incompatible bitcoin.conf setting!", info: "GordianServer allows you to run multiple networks simultaneously, we do this by specifying which chain we want to launch as a command line argument. Specifying a network in your bitcoin.conf is not compatible with this approach, please remove the line in your conf file which specifies a network.", buttonLabel: "OK")
                                }
                                
                            case "proxy", "#proxy":
                                proxyExists = true
                                
                            case "listen", "#listen":
                                listenExists = true
                                
                            case "debug", "#debug":
                                debugExists = true
                                
                            default:
                                break
                            }
                        }
                    }
                    
                    if userExists && passwordExists {
                        // just use exisiting conf as is
                        vc.standUpConf = conf!.joined(separator: "\n")
                        
                    } else if userExists && !passwordExists {
                        vc.standUpConf = "rpcpassword=\(randomString(length: 32))\n" + conf!.joined(separator: "\n")
                        
                    } else if passwordExists && !userExists {
                        vc.standUpConf = "rpcuser=\(randomString(length: 10))\n" + conf!.joined(separator: "\n")
                        
                    } else {
                        // add rpcuser and rpcpassword
                        vc.standUpConf = "rpcuser=\(randomString(length: 10))\nrpcpassword=\(randomString(length: 32))\n" + conf!.joined(separator: "\n")
                    }
                    
                    if !debugExists {
                        vc.standUpConf = "debug=tor\n" + vc.standUpConf
                    }
                    
                    if !proxyExists {
                        vc.standUpConf = "proxy=127.0.0.1:19050\n" + vc.standUpConf
                    }
                    
                    if !listenExists {
                        vc.standUpConf = "listen=1\n" + vc.standUpConf
                    }
                    
                    if !discoverExists {
                        vc.standUpConf = "discover=1" + vc.standUpConf
                    }
                    
                    if !externalIpExists {
                        vc.standUpConf = "externalip=\(TorClient.sharedInstance.p2pHostname(chain: "main") ?? "")"
                    }
                    
                    vc.getURLs()
                                        
                } else {
                    vc.setDefaultBitcoinConf()
                }
            } else {
                vc.setDefaultBitcoinConf()
            }
        }
    }
    
    private func setDefaultBitcoinConf() {
        //no existing settings - use default
        standUpConf = BitcoinConf.bitcoinConf()
        getURLs()
    }
    
    func standDown() {
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .standDown, env: ["":""]) { log in
                DispatchQueue.main.async { [weak self] in
                    self?.hideSpinner()
                    simpleAlert(message: "Success", info: "You have uninstalled Tor, removed Bitcoin Core and ~/.gordian.", buttonLabel: "OK")
                    self?.goBack()
                }
            }
        }
    }
    
    func standUp(binaryName: String, macosURL: String, shaURL: String, version: String, prefix: String, sigsUrl: String) {
        var ignore = "NO"
        if ignoreExistingBitcoin {
            ignore = "YES"
        }
        let d = Defaults()
        showLog = true
        let env = ["BINARY_NAME":binaryName, "MACOS_URL":macosURL, "SHA_URL":shaURL, "VERSION":version, "PREFIX":prefix, "CONF":standUpConf, "DATADIR":d.dataDir, "IGNORE_EXISTING_BITCOIN":ignore, "SIGS_URL": sigsUrl]
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .standUp, env: env) { log in
                
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        self?.setLog(content: log)
                    }
                    let ud = UserDefaults.standard
                    ud.set(prefix, forKey: "binaryPrefix")
                    ud.set(binaryName, forKey: "macosBinary")
                    ud.set(version, forKey: "version")
                    NotificationCenter.default.post(name: .refresh, object: nil, userInfo: nil)
                    self?.goBack()
                }
            }
        }
    }
    
    func verify() {
        showLog = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .verifyBitcoin, env: ["":""]) { log in
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        self?.hideSpinner()
                        self?.setLog(content: log)
                    }
                }
            }
        }
    }
    
    func upgradeBitcoinCore(binaryName: String, macosURL: String, shaURL: String, version: String, prefix: String, sigsUrl: String) {
        upgrading = false
        let env = ["BINARY_NAME":binaryName, "MACOS_URL":macosURL, "SHA_URL":shaURL, "VERSION":version, "SIGS_URL": sigsUrl]
        showLog = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .upgradeBitcoin, env: env) { log in
                
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        self?.setLog(content: log)
                    }
                    let ud = UserDefaults.standard
                    ud.set(prefix, forKey: "binaryPrefix")
                    ud.set(version, forKey: "version")
                    ud.set(binaryName, forKey: "macosBinary")
                    NotificationCenter.default.post(name: .refresh, object: nil, userInfo: nil)
                    self?.goBack()
                }
            }
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.alphaValue = 0
            vc.spinnerDescription.stringValue = ""
            vc.spinner.stopAnimation(vc)
        }
    }
    
    func setScene() {
        window?.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.textColor = NSColor.green
        consoleOutput.isEditable = false
        consoleOutput.isSelectable = true
        spinnerDescription.stringValue = ""
    }
    
    func setLog(content: String) {
        Log.writeToLog(content: content)
    }
    
    func getLog(completion: @escaping (String?) -> Void) {
        Log.getLog(completion: completion)
    }
    
    func getExisistingRPCCreds(completion: @escaping ((user: String, password: String)) -> Void) {
        var user = ""
        var password = ""
        
        let path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            print("can not get bitcoin.conf")
            completion(("", ""))
            return
        }
        
        let conf = bitcoinConf.components(separatedBy: "\n")
        for item in conf {
            if item.contains("rpcuser") {
                let arr = item.components(separatedBy: "rpcuser=")
                user = arr[1]
            }
            if item.contains("rpcpassword") {
                let arr = item.components(separatedBy: "rpcpassword=")
                password = arr[1]
            }
            completion((user: user, password: password))
        }
    }
    
    func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            print("can not get bitcoin.conf")
            completion((nil, false))
            return
        }
        
        let conf = bitcoinConf.components(separatedBy: "\n")
        completion((conf, false))
    }
        
    private func run(script: SCRIPT, env: [String:String], completion: @escaping ((String)) -> Void) {
        #if DEBUG
        print("script: \(script.rawValue)")
        #endif
        var logOutput = ""
        let resource = script.rawValue
        guard let path = Bundle.main.path(forResource: resource, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = env
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.terminationHandler = { _ in
            completion((logOutput))
        }
        let handler = { [unowned vc = self] (file: FileHandle!) -> Void in
            let data = file.availableData
            guard let output = String(data: data, encoding: .utf8) else { return }
                        
            if vc.showLog {
                DispatchQueue.main.async { [unowned vc = self] in
                    let prevOutput = vc.consoleOutput.string
                    let nextOutput = prevOutput + output
                    vc.consoleOutput.string = nextOutput
                    logOutput = nextOutput
                    vc.consoleOutput.scrollToEndOfDocument(vc)
                }
            }
            
        }
        stdErr.fileHandleForReading.readabilityHandler = handler
        stdOut.fileHandleForReading.readabilityHandler = handler
        task.launch()
        task.waitUntilExit()
    }
    
}
