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
            let log = URL(fileURLWithPath: "/Users/\(NSUserName())/.gordian/gordian.log")
            do {
                let text = try String(contentsOf: log, encoding: .utf8)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.consoleOutput.string = text
                }
            } catch {
                simpleAlert(message: "Log does not exist.", info: "We were unable to fetch the log.", buttonLabel: "OK")
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
        //var userExists = false
        //var passwordExists = false
        var proxyExists = false
        var onlynetExists = false
        var discoverExists = false
        var listenExists = false
        var externalIpExists = false
        
        getBitcoinConf { [weak self] (conf, error) in
            guard let self = self else { return }
            
            guard let conf = conf, !error, conf.count > 0 else {
                self.setDefaultBitcoinConf()
                return
            }
            
            for setting in conf {
                if setting.contains("=") {
                    let arr = setting.components(separatedBy: "=")
                    let k = arr[0]
                    let existingValue = arr[1]
                    
                    switch k {
                    case "onlynet", "#onlynet":
                        onlynetExists = true
                        
                    case "externalip":
                        externalIpExists = true
                        
                    case "discover", "#discover":
                        discoverExists = true
                        
                    case "blocksdir":
                        UserDefaults.standard.setValue(existingValue, forKey: "blockDir")
                        
                    case "testnet", "regtest", "signet":
                        if existingValue != "" {
                            simpleAlert(message: "Incompatible bitcoin.conf setting!", info: "GordianServer allows you to run multiple networks simultaneously, we do this by specifying which chain we want to launch as a command line argument. Specifying a network in your bitcoin.conf is not compatible with this approach, please remove the line in your conf file which specifies a network.", buttonLabel: "OK")
                        }
                        
                    case "proxy", "#proxy":
                        proxyExists = true
                        
                    case "listen", "#listen":
                        listenExists = true
                        
                    default:
                        break
                    }
                }
            }
            
            self.standUpConf = conf.joined(separator: "\n")
            
            let rpcAuthCreds = RPCAuth.generateRpcAuth(user: "GordianServer")
            
            guard let rpcauth = rpcAuthCreds.rpcauth, let rpcpassword = rpcAuthCreds.rpcpassword else {
                simpleAlert(message: "Error", info: "Unable to create rpcauth credentials.", buttonLabel: "OK")
                return
            }
            
            UserDefaults.setValue(rpcpassword, forKey: "rpcpassword")
            UserDefaults.setValue("GordianServer", forKey: "rpcuser")
            
            self.standUpConf = rpcauth + "\n" + "rpcwhitelist=GordianServer:\(rpcWhiteList)" + conf.joined(separator: "\n")
            
            if !proxyExists {
                self.standUpConf = "proxy=127.0.0.1:19050\n" + conf.joined(separator: "\n")
            }
            
            if !listenExists {
                self.standUpConf = "listen=1\n" + conf.joined(separator: "\n")
            }
            
            if !discoverExists {
                self.standUpConf = "discover=1\n" + conf.joined(separator: "\n")
            }
            
            if !onlynetExists {
                self.standUpConf = "#onlynet=onion\n" + conf.joined(separator: "\n")
            }
            
            if !externalIpExists {
                self.standUpConf = "externalip=\(TorClient.sharedInstance.p2pHostname(chain: "main") ?? "")\n" + conf.joined(separator: "\n")
            }
            
            self.getURLs()
        }
    }
    
    private func setDefaultBitcoinConf() {
        guard let defaultConf = BitcoinConf.bitcoinConf() else {
            simpleAlert(message: "Error", info: "Unable to create the default bitcoin.conf", buttonLabel: "OK")
            return
        }
        
        standUpConf = defaultConf
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
        let d = Defaults.shared
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
    
    func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let path = URL(fileURLWithPath: "\(Defaults.shared.dataDir)/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            completion((nil, false))
            return
        }
        
        let conf = bitcoinConf.components(separatedBy: "\n")
        completion((conf, false))
    }
        
    private func run(script: SCRIPT, env: [String:String], completion: @escaping ((String)) -> Void) {
        #if DEBUG
        print("script: \(script.stringValue)")
        #endif
        var logOutput = ""
        let resource = script.stringValue
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let prevOutput = vc.consoleOutput.string
                    let nextOutput = prevOutput + output
                    self.consoleOutput.string = nextOutput
                    logOutput = nextOutput
                    self.consoleOutput.scrollToEndOfDocument(vc)
                }
            }
            
        }
        stdErr.fileHandleForReading.readabilityHandler = handler
        stdOut.fileHandleForReading.readabilityHandler = handler
        task.launch()
        task.waitUntilExit()
    }
    
}
