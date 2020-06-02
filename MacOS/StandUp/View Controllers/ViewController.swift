//
//  ViewController.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var bitcoinCoreWindow: NSView!
    @IBOutlet weak var torWindow: NSView!
    @IBOutlet weak var bitcoinMainnetWindow: NSView!
    @IBOutlet weak var bitcoinTestnetWindow: NSView!
    @IBOutlet weak var bitcoinRegtestWindow: NSView!
    @IBOutlet weak var torMainnetWindow: NSView!
    @IBOutlet weak var torTestnetWindow: NSView!
    @IBOutlet weak var torRegtestWindow: NSView!
    @IBOutlet weak var torAuthWindow: NSView!
    @IBOutlet weak var mainnetIsOnImage: NSImageView!
    @IBOutlet weak var testnetIsOnImage: NSImageView!
    @IBOutlet weak var regtestIsOnImage: NSImageView!
    @IBOutlet weak var startMainnetOutlet: NSButton!
    @IBOutlet weak var connectMainnetOutlet: NSButton!
    @IBOutlet weak var startTestnetOutlet: NSButton!
    @IBOutlet weak var connectTestnetOutlet: NSButton!
    @IBOutlet weak var startRegtestOutlet: NSButton!
    @IBOutlet weak var connectRegtestOutlet: NSButton!
    @IBOutlet weak var bitcoinCoreHeaderOutlet: NSTextField!
    @IBOutlet weak var bitcoinCoreVersionOutlet: NSTextField!
    @IBOutlet weak var torVersionOutlet: NSTextField!
    @IBOutlet weak var torMainnetPathOutlet: NSPathControl!
    @IBOutlet weak var torTestnetPathOutlet: NSPathControl!
    @IBOutlet weak var torRegtestPathOutlet: NSPathControl!
    @IBOutlet weak var torAuthLockImage: NSImageView!
    @IBOutlet weak var torAuthRemoveOutlet: NSButton!
    @IBOutlet var taskDescription: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var installTorOutlet: NSButton!
    @IBOutlet var seeLogOutlet: NSButton!
    @IBOutlet var settingsOutlet: NSButton!
    @IBOutlet var standUpOutlet: NSButton!
    @IBOutlet var verifyOutlet: NSButton!
    @IBOutlet var updateOutlet: NSButton!
    @IBOutlet var icon: NSImageView!
    @IBOutlet var torRunningImage: NSImageView!
    
    var rpcpassword = ""
    var rpcuser = ""
    var torHostname = ""
    var mainHostname = ""
    var testHostname = ""
    var regHostname = ""
    var network = ""
    var rpcport = ""
    var newestVersion = ""
    var newestBinaryName = ""
    var newestPrefix = ""
    var strapping = Bool()
    var standingUp = Bool()
    var bitcoinInstalled = Bool()
    var torInstalled = Bool()
    var torIsOn = Bool()
    var bitcoinRunning = Bool()
    var upgrading = Bool()
    var isLoading = Bool()
    var torConfigured = Bool()
    var bitcoinConfigured = Bool()
    var ignoreExistingBitcoin = Bool()
    var regTestOn = Bool()
    var mainOn = Bool()
    var testOn = Bool()
    var env = [String:String]()
    let d = Defaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScene()
    }
    
    override func viewDidAppear() {
        print("viewDidAppear")
        d.setDefaults { [unowned vc = self] in
            vc.getLatestVersion { [unowned vc = self] success in
                if success {
                    vc.setEnv()
                } else {
                    vc.showAlertMessage(message: "Network request error", info: "We had an issue getting a response from github, we use github to check to see if your current version of Bitcoin Core is out of date, please let us know about this so we can fix it.")
                }
            }
        }
    }
    
    //MARK: User Action Segues
    
    @IBAction func showMainConnect(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.rpcport = "1309"
            vc.network = "main"
            vc.torHostname = vc.mainHostname
            vc.performSegue(withIdentifier: "showPairingCode", sender: vc)
        }
    }
    
    @IBAction func showTestConnect(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.rpcport = "1310"
            vc.network = "test"
            vc.torHostname = vc.testHostname
            vc.performSegue(withIdentifier: "showPairingCode", sender: vc)
        }
    }
    
    @IBAction func showRegConnect(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.rpcport = "1311"
            vc.network = "regtest"
            vc.torHostname = vc.regHostname
            vc.performSegue(withIdentifier: "showPairingCode", sender: vc)
        }
    }
    
    @IBAction func startMainnetAction(_ sender: Any) {
        startMainnetOutlet.isEnabled = false
        if !mainOn {
            runScript(script: .startMain)
        } else {
            runScript(script: .stopMain)
        }
    }
        
    @IBAction func startTestnetAction(_ sender: Any) {
        startTestnetOutlet.isEnabled = false
        if !testOn {
            runScript(script: .startTestd)
        } else {
            runScript(script: .stopTest)
        }
    }
    
    @IBAction func startRegtestAction(_ sender: Any) {
        startRegtestOutlet.isEnabled = false
        if !regTestOn {
            runScript(script: .startRegtest)
        } else {
            runScript(script: .stopReg)
        }
    }
    
    @IBAction func showMainnetHiddenService(_ sender: Any) {
        runScript(script: .openMainnetHiddenService)
    }
    
    @IBAction func showTestnetHiddenService(_ sender: Any) {
        runScript(script: .openTestnetHiddenService)
    }
    
    @IBAction func showRegtestHiddenService(_ sender: Any) {
        runScript(script: .openRegtestHiddenService)
    }
    
    @IBAction func bitcoinWindowHelp(_ sender: Any) {
        showAlertMessage(message: "Bitcoin Core Help", info: "Standup allows you to run multiple networks simultaneously which can be useful for development and testing purposes. Each network has a dedicated hidden service which gives you the ability to remotely connect to all 3 networks via FullyNoded. Just tap the QuickConnect button for whichever network you want to remotely connect to and scan the QR with FullyNoded. Mainnet is the main network where you can spend real Bitcoins, Testnet is a test network where you can connect to other nodes on the testnet3 network, which is useful for testing new features of Bitcoin Core that you may not be familiar with. Regtest is meant for developers who want to run a local network, it essentially gives you access to your own local Bitcoin blockchain, you can mine blocks easily and instantly and add multiple nodes all from your local dev environment. The verify button allows you to check the sha256 hash of the Bitcoin Core binary against what we expect it to be as per LaanWJ Vlaadmirs pgp signature. The install/update button will either setup Standup completely or update Bitcoin Core if there is a newer version available.")
    }
    
    @IBAction func torWindowHelp(_ sender: Any) {
        showAlertMessage(message: "Tor Help", info: "This window gives you direct access to the three hidden service directories by tapping the forward button for each network. This is useful if you want to use your node's onion addresses for other apps. It is also useful if you want to refresh your hidden service which can be accomplished by deleting the hidden service directory altogether.  You may add and remove Tor v3 authenticaction keys from the \"add\" and \"remove\" button. You may add up to 330 auth keys to each hidden service. Standup by default adds the auth key to all three hidden services, if you tap \"remove\" it will remove auth from all three hidden services so use it with caution. The start/stop button allows you to start and stop tor. If Tor is stopped your node will not be reachable remotely. You may use the install/update button to install Standup or to update Tor.")
    }
    
    @IBAction func torSettingsAction(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.performSegue(withIdentifier: "goToSettings", sender: vc)
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.performSegue(withIdentifier: "goToSettings", sender: vc)
        }
    }
    
    @IBAction func updateBitcoin(_ sender: Any) {
        if !bitcoinInstalled {
            installNow()
            
        } else {
            DispatchQueue.main.async {
                let request = FetchJSON()
                request.getRequest { (dict, err) in
                    if err != "" {
                        setSimpleAlert(message: "Error", info: "Error fetching json values: \(err ?? "unknown error")", buttonLabel: "OK")
                        
                    } else {
                        let version = dict!["version"] as! String
                        actionAlert(message: "Upgrade to Bitcoin Core \(version)?", info: "Are you sure?") { (response) in
                            if response {
                                DispatchQueue.main.async { [unowned vc = self] in
                                    vc.upgrading = true
                                    vc.performSegue(withIdentifier: "goInstall", sender: vc)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: User Action Installers, Starters and Configurators
    
    @IBAction func verifyAction(_ sender: Any) {
        runScript(script: .verifyBitcoin)
    }
    
    private func installNow() {
        startSpinner(description: "Fetching latest Bitcoin Core version...")
        let request = FetchJSON()
        request.getRequest { [unowned vc = self] (dict, error) in
            
            if error != "" {
                vc.hideSpinner()
                setSimpleAlert(message: "Error", info: "We had an error fetching the latest version of Bitcoin Core, please check your internet connection and try again", buttonLabel: "OK")
                
            } else {
                vc.hideSpinner()
                let version = dict!["version"] as! String
                
                func standup() {
                    let pruned = vc.d.prune()
                    let txindex = vc.d.txindex()
                    let directory = vc.d.dataDir()
                    var type = ""
                    if pruned == 1 {
                        type = "pruned"
                    }
                    
                    if txindex == 1 {
                        type = "fully indexed"
                    }
                    
                    vc.showstandUpAlert(message: "Ready to StandUp?", info: "StandUp will install and configure a \(type) Bitcoin Core v\(version) node and Tor v0.4.3.5\n\n~30gb of space needed for testnet and ~300gb for mainnet\n\nIf you would like to install a different node go to \"Settings\" for pruning, mainnet, data directory and tor related options, you can always adjust the settings and restart your node for the changes to take effect.\n\nStandUp will create the following directory: /Users/\(NSUserName())/StandUp\n\nBy default it will create or if one exists add any missing rpc credentials to the bitcoin.conf in \(directory).")
                }
                
                if vc.torConfigured && vc.bitcoinConfigured {
                    
                    actionAlert(message: "Install Bitcoin Core with StandUp?", info: "You have an exisiting version of Bitcoin Core installed.\n\nSelecting yes will tell StandUp to download, verify and install a fresh Bitcoin Core installation in ~/StandUp/BitcoinCore and will only ever work with that instance of Bitcoin Core.") { (response) in
                        
                        if response {
                            DispatchQueue.main.async { [unowned vc = self] in
                                vc.standingUp = true
                                vc.ignoreExistingBitcoin = true
                                vc.performSegue(withIdentifier: "goInstall", sender: vc)
                            }
                        }
                        
                    }
                } else {
                    standup()
                }
            }
        }
    }
    
    @IBAction func standUp(_ sender: Any) {
        installNow()
    }
    
    @IBAction func installTorAction(_ sender: Any) {
        if !torIsOn {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.startSpinner(description: "starting tor...")
                vc.installTorOutlet.isEnabled = false
            }
            runScript(script: .startTor)
        } else {
            
            DispatchQueue.main.async { [unowned vc = self] in
                vc.startSpinner(description: "stopping tor...")
                vc.installTorOutlet.isEnabled = false
            }
            runScript(script: .stopTor)
        }
    }
    
    // MARK: Script Methods
    
    func checkForXcodeSelect() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking for xcode select..."
            vc.runScript(script: .checkXcodeSelect)
        }
    }
    
    func checkForHomebrew() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking for homebrew..."
            vc.runScript(script: .checkHomebrew)
        }
    }
    
    func isBitcoinOn() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking if bitcoin core is running..."
            vc.runScript(script: .isMainOn)
        }
    }
    
    func checkSigs() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "verifying pgp signatures..."
            vc.runScript(script: .verifyBitcoin)
            vc.hideSpinner()
        }
    }
    
    func checkBitcoindVersion() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking if bitcoin core is installed..."
            vc.runScript(script: .checkForBitcoin)
        }
    }
    
    func checkTorVersion() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking if tor is installed..."
            vc.runScript(script: .checkForTor)
        }
    }
    
    func getTorrcFile() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "fetching torrc file..."
            vc.runScript(script: .getTorrc)
        }
    }
    
    func checkBitcoinConfForRPCCredentials() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "getting rpc credentials..."
            vc.runScript(script: .getRPCCredentials)
        }
    }
    
    func checkForStandUp() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking for StandUp directory..."
            vc.runScript(script: .checkStandUp)
        }
    }
    
    func getTorHostName() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "getting tor hostname..."
            vc.runScript(script: .getTorHostname)
        }
    }
    
    func isTorOn() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking tor status..."
            vc.runScript(script: .torStatus)
        }
    }
    
    private func runScript(script: SCRIPT) {
        #if DEBUG
        print("script: \(script.rawValue)")
        #endif
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
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var result = ""
        if let output = String(data: data, encoding: .utf8) {
            #if DEBUG
            print("output: \(output)")
            #endif
            result += output
        }
        if let errorOutput = String(data: errData, encoding: .utf8) {
            #if DEBUG
            print("error: \(errorOutput)")
            #endif
            result += errorOutput
        }
        parseScriptResult(script: script, result: result)
    }
    
    //MARK: Script Result Filters
    
    func parseScriptResult(script: SCRIPT, result: String) {
        switch script {
        case .stopMain:
            stopMainParse(result: result)
            
        case .stopTest:
            stopTestParse(result: result)
            
        case .stopReg:
            stopRegParse(result: result)
            
        case .startMain:
            startMainParse(result: result)
            
        case .startTestd:
            startTestParse(result: result)
            
        case .startRegtest:
            startRegtestParse(result: result)
            
        case .checkStandUp:
            checkStandUpParser(result: result)
            
        case .isMainOn:
            parseIsMainOn(result: result)
            
        case .isTestOn:
            parseIsTestOn(result: result)
            
        case .isRegOn:
            parseIsRegtestOn(result: result)
            
        case .checkForBitcoin:
            parseBitcoindResponse(result: result)
            
        case .checkForTor:
            parseTorResult(result: result)
            
        case .getRPCCredentials:
            checkForRPCCredentials(response: result)
            
        case .getTorrc:
            checkIfTorIsConfigured(response: result)
            
        case .getTorHostname:
            parseHostname(response: result)
            
        case .torStatus:
            parseTorStatus(result: result)
            
        case .verifyBitcoin:
            parseVerifyResult(result: result)
            
        case .startTor, .stopTor:
            torStarted(result: result)
            
        case .checkHomebrew:
            parseHomebrewResult(result: result)
            
        case .checkXcodeSelect:
            parseXcodeSelectResult(result: result)
            
        default: break
        }
    }
    
    private func mainnetIsOff() {
        print("mainnet is off")
        DispatchQueue.main.async { [unowned vc = self] in
            vc.mainOn = false
            vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startMainnetOutlet.title = "Start"
            vc.startMainnetOutlet.isEnabled = true
        }
    }
    
    private func testnetIsOff() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.testOn = false
            vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startTestnetOutlet.title = "Start"
            vc.startTestnetOutlet.isEnabled = true
        }
    }
    
    private func regtestIsOff() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.regTestOn = false
            vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startRegtestOutlet.title = "Start"
            vc.startRegtestOutlet.isEnabled = true
        }
    }
    
    //MARK: Script Result Parsers
    
    private func stopMainParse(result: String) {
        if result.contains("Bitcoin Core stopping") {
            mainnetIsOff()
        } else {
            showAlertMessage(message: "Error turning off mainnet", info: result)
        }
    }
    
    private func stopTestParse(result: String) {
        if result.contains("Bitcoin Core stopping") {
            testnetIsOff()
        } else {
            showAlertMessage(message: "Error turning off testnet", info: result)
        }
    }
    
    private func stopRegParse(result: String) {
        if result.contains("Bitcoin Core stopping") {
            regtestIsOff()
        } else {
            showAlertMessage(message: "Error turning off regtest", info: result)
        }
    }
    
    private func startTestParse(result: String) {
        startSpinner(description: "turning on testnet")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [unowned vc = self] in
            vc.runScript(script: .isTestOn)
            vc.hideSpinner()
        }
    }
    
    private func startMainParse(result: String) {
        startSpinner(description: "turning on mainnet")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [unowned vc = self] in
            vc.runScript(script: .isMainOn)
            vc.hideSpinner()
        }
    }
    
    private func startRegtestParse(result: String) {
        startSpinner(description: "turning on regtest")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [unowned vc = self] in
            vc.runScript(script: .isRegOn)
            vc.hideSpinner()
        }
    }
    
    private func parseXcodeSelectResult(result: String) {
        hideSpinner()
        if result.contains("XCode select not installed") {
            showAlertMessage(message: "Dependencies missing", info: "You do not appear to have XCode command line tools installed, StandUp.app relies on XCode command line tools for installing Bitcoin Core, therefore in order to continue please select \"Install Dependencies\".")
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.standUpOutlet.isEnabled = true
            }
        }
    }
    
    private func parseHomebrewResult(result: String) {
        if result.contains("Homebrew not installed") {
            hideSpinner()
            actionAlert(message: "Install dependencies?", info: "You do not appear to have Homebrew installed, StandUp.app relies on homebrew for installing Tor. We use a well known open source script called Strap to setup your mac for best security and privacy practices, it also installs Homebrew and few other very useful tools. You can read more about Strap here: \"https://github.com/MikeMcQuaid/strap\". This will launch a terminal session and prompt you for your password to run through the process, once complete you can quit and open StandUp to continue." ) { [unowned vc = self] response in
                if response {
                    vc.strap()
                }
            }
        } else {
            checkForXcodeSelect()
        }
    }
    
    func checkStandUpParser(result: String) {
        if result.contains("False") {
            checkForHomebrew()
        } else {
            hideSpinner()
        }
    }
    
    private func parseIsMainOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            mainnetIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.mainOn = true
                vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startMainnetOutlet.title = "Stop"
                vc.startMainnetOutlet.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.mainOn = false
                vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startMainnetOutlet.title = "Start"
                vc.startMainnetOutlet.isEnabled = false
            }
        }
        runScript(script: .isTestOn)
    }
    
    private func parseIsTestOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            testnetIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.testOn = true
                vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startTestnetOutlet.title = "Stop"
                vc.startTestnetOutlet.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.testOn = false
                vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startTestnetOutlet.title = "Start"
                vc.startTestnetOutlet.isEnabled = false
            }
        }
        runScript(script: .isRegOn)
    }
    
    private func parseIsRegtestOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            regtestIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.regTestOn = true
                vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startRegtestOutlet.title = "Stop"
                vc.startRegtestOutlet.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.regTestOn = false
                vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startRegtestOutlet.title = "Start"
                vc.startRegtestOutlet.isEnabled = false
            }
        }
        if isLoading {
            checkBitcoindVersion()
        }
    }
    
    func parseTorStatus(result: String) {
        if result.contains("started") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torIsOn = true
                vc.installTorOutlet.title = "Stop"
                vc.installTorOutlet.isEnabled = true
                vc.updateTorStatus(isOn: true)
            }
        } else if result.contains("stopped") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torIsOn = false
                vc.installTorOutlet.title = "Start"
                vc.installTorOutlet.isEnabled = true
                vc.updateTorStatus(isOn: false)
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torIsOn = false
                vc.installTorOutlet.title = "Start Tor"
                vc.installTorOutlet.isEnabled = false
                vc.updateTorStatus(isOn: false)
            }
        }
        checkForStandUp()
    }
    
    func torStarted(result: String) {
        var title = ""
        if result.contains("Successfully started") {
            torIsOn = true
            title = "Stop Tor"
            updateTorStatus(isOn: true)
        } else if result.contains("Successfully stopped") {
            torIsOn = false
            title = "Start Tor"
            updateTorStatus(isOn: false)
        } else if result.contains("already started") {
            torIsOn = true
            title = "Stop Tor"
            updateTorStatus(isOn: true)
        }
        DispatchQueue.main.async { [unowned vc = self] in
            vc.hideSpinner()
            vc.installTorOutlet.title = title
            vc.installTorOutlet.isEnabled = true
        }
    }
    
    func updateTorStatus(isOn: Bool) {
        if isOn {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torRunningImage.alphaValue = 1
                vc.torRunningImage.image = NSImage.init(imageLiteralResourceName: "NSStatusAvailable")
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torRunningImage.alphaValue = 1
                vc.torRunningImage.image = NSImage.init(imageLiteralResourceName: "NSStatusUnavailable")
            }
        }
    }
    
    func parseTorResult(result: String) {
        if result.contains("Tor version") {
            var version = (result.replacingOccurrences(of: "Tor version ", with: ""))
            if version.count == 8 {
                version = String(version.dropLast())
            }
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torVersionOutlet.stringValue = "v\(version)"
                vc.installTorOutlet.title = "Start"
                vc.standUpOutlet.isEnabled = false
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.standUpOutlet.stringValue = "Install"
                vc.standUpOutlet.isEnabled = true
            }
        }
        checkBitcoinConfForRPCCredentials()
    }
    
    func checkForRPCCredentials(response: String) {
        let bitcoinConf = response.components(separatedBy: "\n")
        for item in bitcoinConf {
            if item.contains("rpcuser") {
                let arr = item.components(separatedBy: "rpcuser=")
                rpcuser = arr[1]
            }
            if item.contains("rpcpassword") {
                let arr = item.components(separatedBy: "rpcpassword=")
                rpcpassword = arr[1]
            }
        }
        if rpcpassword != "" && rpcuser != "" {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.bitcoinConfigured = true
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.bitcoinConfigured = false
            }
        }
        getTorrcFile()
    }
    
    func checkIfTorIsConfigured(response: String) {
        if response.contains("HiddenServiceDir /usr/local/var/lib/tor/standup/") {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torConfigured = true
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torConfigured = false
            }
        }
        getTorHostName()
    }
    
    func parseBitcoindResponse(result: String) {
        #if DEBUG
        print("parsebitcoindresponse")
        print("result = \(result)")
        #endif
        
        if result.contains("Bitcoin Core Daemon version") || result.contains("Bitcoin Core version") {
            let arr = result.components(separatedBy: "Copyright (C)")
            var currentVersion = (arr[0]).replacingOccurrences(of: "Bitcoin Core Daemon version ", with: "")
            currentVersion = currentVersion.replacingOccurrences(of: "Bitcoin Core version ", with: "")
            DispatchQueue.main.async { [unowned vc = self] in
                vc.verifyOutlet.isEnabled = true
                vc.bitcoinCoreVersionOutlet.stringValue = currentVersion
                vc.bitcoinInstalled = true
                if currentVersion.contains(vc.newestVersion) {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.updateOutlet.isEnabled = false
                        vc.updateOutlet.title = "Update"
                    }
                } else {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.updateOutlet.title = "Update"
                        vc.updateOutlet.isEnabled = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.updateOutlet.title = "Install"
                vc.updateOutlet.isEnabled = true
                vc.bitcoinInstalled = false
            }
        }
        checkTorVersion()
    }
    
    func parseHostname(response: String) {
        if !response.contains("No such file or directory") {
            let hostnames = response.split(separator: "\n")
            if hostnames.count == 3 {
                mainHostname = "\(hostnames[0])"
                testHostname = "\(hostnames[1])"
                regHostname = "\(hostnames[2])"
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.connectMainnetOutlet.isEnabled = true
                    vc.connectTestnetOutlet.isEnabled = true
                    vc.connectRegtestOutlet.isEnabled = true
                }
            } else {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.connectMainnetOutlet.isEnabled = false
                    vc.connectTestnetOutlet.isEnabled = false
                    vc.connectRegtestOutlet.isEnabled = false
                }
            }
            
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.standUpOutlet.stringValue = "Install"
                vc.standUpOutlet.isEnabled = true
                vc.connectMainnetOutlet.isEnabled = false
                vc.connectTestnetOutlet.isEnabled = false
                vc.connectRegtestOutlet.isEnabled = false
            }
        }
        isTorOn()
    }
    
    func parseVerifyResult(result: String) {
        let binaryName = env["BINARY_NAME"] ?? ""
        if result.contains("\(binaryName): OK") {
            showAlertMessage(message: "Success", info: "Wladimir J. van der Laan signatures for \(binaryName) and SHA256SUMS.asc match")
        } else if result.contains("No ~/StandUp/BitcoinCore directory") {
            showAlertMessage(message: "Error", info: "You are using a version of Bitcoin Core which was not installed by StandUp, we are not yet able to verify Bitcoin Core instances not installed by StandUp.")
        } else {
            showAlertMessage(message: "DANGER!!! Invalid signatures...", info: "Please delete the ~/StandUp folder and app and report an issue on the github, PGP signatures are not valid")
        }
    }
    
    //MARK: User Inteface
    
    func setEnv() {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir()]
        #if DEBUG
        print("env = \(env)")
        #endif
        isBitcoinOn()
    }
    
    func showAlertMessage(message: String, info: String) {
        setSimpleAlert(message: message, info: info, buttonLabel: "OK")
    }
    
    func startSpinner(description: String) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.startAnimation(vc)
            vc.taskDescription.stringValue = description
            vc.spinner.alphaValue = 1
            vc.taskDescription.alphaValue = 1
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = ""
            vc.spinner.stopAnimation(vc)
            vc.spinner.alphaValue = 0
            vc.taskDescription.alphaValue = 0
        }
    }
    
    func setScene() {
        taskDescription.stringValue = "checking system..."
        spinner.startAnimation(self)
        icon.wantsLayer = true
        icon.layer?.cornerRadius = icon.frame.width / 2
        icon.layer?.masksToBounds = true
        isLoading = true
        updateOutlet.isEnabled = false
        bitcoinCoreVersionOutlet.stringValue = ""
        installTorOutlet.isEnabled = false
        standUpOutlet.isEnabled = false
        verifyOutlet.isEnabled = false
        torRunningImage.alphaValue = 0
        bitcoinCoreWindow.backgroundColor = #colorLiteral(red: 0.2313431799, green: 0.2313894629, blue: 0.2313401997, alpha: 1)
        torWindow.backgroundColor = #colorLiteral(red: 0.2313431799, green: 0.2313894629, blue: 0.2313401997, alpha: 1)
        bitcoinMainnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinTestnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinRegtestWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torMainnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torTestnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torRegtestWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torAuthWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinCoreWindow.wantsLayer = true
        torWindow.wantsLayer = true
        bitcoinMainnetWindow.wantsLayer = true
        bitcoinTestnetWindow.wantsLayer = true
        bitcoinRegtestWindow.wantsLayer = true
        torMainnetWindow.wantsLayer = true
        torTestnetWindow.wantsLayer = true
        torAuthWindow.wantsLayer = true
        torRegtestWindow.wantsLayer = true
        bitcoinCoreWindow.layer?.borderWidth = 0.75
        bitcoinCoreWindow.layer?.cornerRadius = 8
        bitcoinMainnetWindow.layer?.borderWidth = 0.75
        bitcoinMainnetWindow.layer?.cornerRadius = 8
        torWindow.layer?.borderWidth = 0.75
        torWindow.layer?.cornerRadius = 8
        bitcoinRegtestWindow.layer?.borderWidth = 0.75
        bitcoinRegtestWindow.layer?.cornerRadius = 8
        bitcoinTestnetWindow.layer?.borderWidth = 0.75
        bitcoinTestnetWindow.layer?.cornerRadius = 8
        torMainnetWindow.layer?.borderWidth = 0.75
        torMainnetWindow.layer?.cornerRadius = 8
        torTestnetWindow.layer?.borderWidth = 0.75
        torTestnetWindow.layer?.cornerRadius = 8
        torRegtestWindow.layer?.borderWidth = 0.75
        torRegtestWindow.layer?.cornerRadius = 8
        torAuthWindow.layer?.borderWidth = 0.75
        torAuthWindow.layer?.cornerRadius = 8
        bitcoinCoreWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        bitcoinMainnetWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        bitcoinTestnetWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        bitcoinRegtestWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torMainnetWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torTestnetWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torRegtestWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torAuthWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        torMainnetPathOutlet.url = URL(fileURLWithPath: "/usr/local/var/lib/tor/standup/main")
        torTestnetPathOutlet.url = URL(fileURLWithPath: "/usr/local/var/lib/tor/standup/test")
        torRegtestPathOutlet.url = URL(fileURLWithPath: "/usr/local/var/lib/tor/standup/reg")
    }
    
    func showstandUpAlert(message: String, info: String) {
        DispatchQueue.main.async {
            actionAlert(message: message, info: info) { (response) in
                if response {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.standingUp = true
                        vc.performSegue(withIdentifier: "goInstall", sender: vc)
                    }
                }
            }
        }
    }
    
    func setLog(content: String) {
        let lg = Log()
        lg.writeToLog(content: content)
    }
    
    private func getLatestVersion(completion: @escaping ((Bool)) -> Void) {
        print("getLatestVersion")
        let fetchJson = FetchJSON()
        fetchJson.getRequest { [unowned vc = self] (dict, error) in
            if dict != nil {
                if let version = dict!["version"] as? String,
                    let binaryName = dict!["macosBinary"] as? String,
                    let prefix = dict!["binaryPrefix"] as? String {
                    vc.newestPrefix = prefix
                    vc.newestVersion = version
                    vc.newestBinaryName = binaryName
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func strap() {
        runScript(script: .launchStrap)
    }
            
    // MARK: Segue Prep
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPairingCode":
            if let vc = segue.destinationController as? QRDisplayer {
                vc.rpcport = rpcport
                vc.network = network
                vc.rpcpassword = rpcpassword
                vc.rpcuser = rpcuser
                vc.torHostname = torHostname
            }
            
        case "goInstall":
            if let vc = segue.destinationController as? Installer {
                vc.standingUp = standingUp
                vc.upgrading = upgrading
                vc.ignoreExistingBitcoin = ignoreExistingBitcoin
                vc.strapping = strapping
            }
            
        default:
            break
        }
    }
}

extension NSView {
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}
