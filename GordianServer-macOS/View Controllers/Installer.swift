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
    var installLightning = Bool()
    var standUpConf = ""
    var refreshing = Bool()
    var ignoreExistingBitcoin = Bool()
    var rpcuser = ""
    var rpcpassword = ""
    var lightningHostname = ""

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
            
        } else if installLightning {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.spinner.startAnimation(vc)
            }
            desc = "Installing Lightning..."
            //installLightningAction()
            checkExistingConf()
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
        var userExists = false
        var passwordExists = false
        var proxyExists = false
        var debugExists = false
        var bindExists = false
        var listenExists = false
        
        getBitcoinConf { [unowned vc = self] (conf, error) in
            if !error && conf != nil {
                if conf!.count > 0 {
                    for setting in conf! {
                        if setting.contains("=") {
                            let arr = setting.components(separatedBy: "=")
                            let k = arr[0]
                            let existingValue = arr[1]
                            
                            switch k {
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
                                
                            case "testnet", "regtest":
                                if existingValue != "" {
                                    simpleAlert(message: "Incompatible bitcoin.conf setting!", info: "GordianServer allows you to run multiple networks simultaneously, we do this by specifying which chain we want to launch as a command line argument. Specifying a network in your bitcoin.conf is not compatible with this approach, please remove the line in your conf file which specifies a network.", buttonLabel: "OK")
                                }
                                
                            case "proxy", "#proxy":
                                proxyExists = true
                                
                            case "listen", "#listen":
                                listenExists = true
                                
                            case "bindaddress", "#bindaddress":
                                bindExists = true
                                
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
                        vc.standUpConf = "#debug=tor\n" + vc.standUpConf
                    }
                    
                    if !proxyExists {
                        vc.standUpConf = "#proxy=127.0.0.1:9050\n" + vc.standUpConf
                    }
                    
                    if !listenExists {
                        vc.standUpConf = "#listen=1\n" + vc.standUpConf
                    }
                    
                    if !bindExists {
                        vc.standUpConf = "#bindaddress=127.0.0.1\n" + vc.standUpConf
                    }
                    
                    if !vc.installLightning {
                        vc.getURLs()
                    } else {
                        vc.installLightningAction()
                    }
                                        
                } else {
                    if !vc.installLightning {
                        vc.setDefaultBitcoinConf()
                    }
                }
            } else {
                if !vc.installLightning {
                    vc.setDefaultBitcoinConf()
                }
            }
        }
    }
    
    private func setDefaultBitcoinConf() {
        //no existing settings - use default
        let d = Defaults()
        let prune = d.prune()
        let txindex = d.txindex()
        let walletDisabled = d.walletdisabled()
        rpcpassword = randomString(length: 32)
        rpcuser = randomString(length: 10)
        standUpConf = """
        disablewallet=\(walletDisabled)
        rpcuser=\(rpcuser)
        rpcpassword=\(rpcpassword)
        server=1
        prune=\(prune)
        txindex=\(txindex)
        rpcallowip=127.0.0.1
        dbcache=\(optimumCache())
        maxconnections=20
        maxuploadtarget=500
        fallbackfee=0.00009
        blocksdir=\(d.blocksDir())
        #bindaddress=127.0.0.1
        #proxy=127.0.0.1:9050
        #listen=1
        #debug=tor
        [main]
        rpcport=8332
        rpcwhitelist=\(rpcuser):\(whitelistedRpc())
        [test]
        rpcport=18332
        [regtest]
        rpcport=18443
        """
        getURLs()
    }
    
    private func whitelistedRpc() -> String {
        return "getblockcount, abortrescan, listlockunspent, lockunspent, getbestblockhash, getaddressesbylabel, listlabels, decodescript, combinepsbt, utxoupdatepsbt, listaddressgroupings, converttopsbt, getaddressinfo, analyzepsbt, createpsbt, joinpsbts, getmempoolinfo, signrawtransactionwithkey, listwallets, unloadwallet, rescanblockchain, listwalletdir, loadwallet, createwallet, finalizepsbt, walletprocesspsbt, decodepsbt, walletcreatefundedpsbt, fundrawtransaction, uptime, importmulti, getdescriptorinfo, deriveaddresses, getrawtransaction, decoderawtransaction, getnewaddress, gettransaction, signrawtransactionwithwallet, createrawtransaction, getrawchangeaddress, getwalletinfo, getblockchaininfo, getbalance, getunconfirmedbalance, listtransactions, listunspent, bumpfee, importprivkey, abandontransaction, getpeerinfo, getnetworkinfo, getmininginfo, estimatesmartfee, sendrawtransaction, importaddress, signmessagewithprivkey, verifymessage, signmessage, encryptwallet, walletpassphrase, walletlock, walletpassphrasechange, gettxoutsetinfo, help, stop, gettxout, getblockhash"
    }
    
    private func optimumCache() -> Int {
        /// Converts devices ram to gb, divides it by two and converts that to mebibytes. That way we use half the RAM for IBD cache as a reasonable default.
        return Int(((Double(ProcessInfo.processInfo.physicalMemory) / 1073741824.0) / 2.0) * 954.0)
    }
    
    func standDown() {
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .standDown, env: ["":""]) { log in
                DispatchQueue.main.async { [weak self] in
                    self?.hideSpinner()
                    simpleAlert(message: "Success", info: "You have stood down", buttonLabel: "OK")
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
        let env = ["BINARY_NAME":binaryName, "MACOS_URL":macosURL, "SHA_URL":shaURL, "VERSION":version, "PREFIX":prefix, "CONF":standUpConf, "DATADIR":d.dataDir(), "IGNORE_EXISTING_BITCOIN":ignore, "SIGS_URL": sigsUrl]
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
        print("getExisistingRPCCreds")
        
        var user = ""
        var password = ""
        let d = Defaults()
        guard let path = Bundle.main.path(forResource: SCRIPT.getRPCCredentials.rawValue, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = ["DATADIR":d.dataDir()]
        task.standardOutput = stdOut
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let conf = output.components(separatedBy: "\n")
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
        } else {
            completion((user: "", password: ""))
        }
        
    }
    
    func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let d = Defaults()
        guard let path = Bundle.main.path(forResource: SCRIPT.getRPCCredentials.rawValue, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = ["DATADIR":d.dataDir()]
        task.standardOutput = stdOut
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            if output != "" {
                let conf = output.components(separatedBy: "\n")
                completion((conf, false))
            } else {
                completion((nil, false))
            }
        } else {
            completion((nil, true))
        }
    }
    
    private func installLightningAction() {
        print("installLightningAction")
        showLog = true
        let d = Defaults()
        let env = ["RPC_PASSWORD":rpcpassword, "RPC_USER":rpcuser, "HTTP_PASS":randomString(length: 32), "PREFIX": d.existingPrefix(), "DATA_DIR": d.dataDir(), "USER":NSUserName()]
        #if DEBUG
        print("env: \(env)")
        #endif
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            self?.run(script: .installLightning, env: env) { log in
                
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        self?.setLog(content: log)
                    }
                    NotificationCenter.default.post(name: .refresh, object: nil, userInfo: nil)
                    self?.goBack()
                }
            }
        }
        
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
