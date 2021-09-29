//
//  ViewController.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak private var rpcAuthenticated: NSTextField!
    @IBOutlet weak private var bitcoinCoreModeOutlet: NSTextField!
    @IBOutlet weak private var rpcHostOutlet: NSTextField!
    @IBOutlet weak private var p2pHostOutlet: NSTextField!
    @IBOutlet weak private var torRemoveAuthOutlet: NSButton!
    @IBOutlet weak private var torAddAuthOutlet: NSButton!
    @IBOutlet weak private var peerDetailsButton: NSButton!
    @IBOutlet weak private var startTorOutlet: NSButton!
    @IBOutlet weak private var mainnetIncomingImage: NSImageView!
    @IBOutlet weak private var bitcoinCoreWindow: NSView!
    @IBOutlet weak private var torWindow: NSView!
    @IBOutlet weak private var torAuthWindow: NSView!
    @IBOutlet weak private var startMainnetOutlet: NSButton!
    @IBOutlet weak private var bitcoinCoreHeaderOutlet: NSTextField!
    @IBOutlet weak private var bitcoinCoreVersionOutlet: NSTextField!
    @IBOutlet weak private var torVersionOutlet: NSTextField!
    @IBOutlet weak private var torAuthLockImage: NSImageView!
    @IBOutlet weak private var torAuthRemoveOutlet: NSButton!
    @IBOutlet weak private var taskDescription: NSTextField!
    @IBOutlet weak private var spinner: NSProgressIndicator!
    @IBOutlet weak private var verifyOutlet: NSButton!
    @IBOutlet weak private var updateOutlet: NSButton!
    @IBOutlet weak private var icon: NSImageView!
    @IBOutlet weak private var torRunningImage: NSImageView!
    @IBOutlet weak private var mainnetSyncedLabel: NSTextField!
    @IBOutlet weak private var mainnetIncomingPeersLabel: NSTextField!
    @IBOutlet weak private var mainnetOutgoingPeersLabel: NSTextField!
    @IBOutlet weak private var bitcoinIsOnHeaderImage: NSImageView!
    @IBOutlet weak private var networkButton: NSPopUpButton!
    @IBOutlet weak private var bitcoinCoreLogOutlet: NSTextField!
    
    @IBOutlet weak private var blocksOutlet: NSTextField!
    @IBOutlet weak private var hashrateOutlet: NSTextField!
    @IBOutlet weak private var pruningOutlet: NSTextField!
    @IBOutlet weak private var uptimeOutlet: NSTextField!
    @IBOutlet weak private var mempoolOutlet: NSTextField!
    @IBOutlet weak private var difficultyOutlet: NSTextField!
    @IBOutlet weak private var sizeOutlet: NSTextField!
    
    weak var mgr = TorClient.sharedInstance
    var autoRefreshTimer: Timer?
    var shutDownTimer: Timer?
    var startTimer: Timer?
    var chain = UserDefaults.standard.object(forKey: "chain") as? String ?? "main"
    var rpcpassword = ""
    var rpcuser = ""
    var network = ""
    var rpcport = ""
    var newestVersion = ""
    var newestBinaryName = ""
    var newestPrefix = ""
    var standingUp = false
    var bitcoinInstalled = false
    var torIsOn = false
    var bitcoinRunning = false
    var upgrading = false
    var isLoading = false
    var bitcoinConfigured = false
    var ignoreExistingBitcoin = false
    var isVerifying = false
    var env = [String:String]()
    let d = Defaults.shared
    var infoMessage = ""
    var headerText = ""
    var installingXcode = false
    var currentVersion = ""
    var peerInfo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
        peerDetailsButton.alphaValue = 0
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNow), name: .refresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authAdded), name: .authAdded, object: nil)
        
        d.setDefaults { [weak self] in
            guard let self = self else { return }
            
            self.setEnv()
            self.setScene()
        }
    }

    override func viewWillAppear() {
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 544, height: 568)
    }
    
    override func viewWillDisappear() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    override func viewDidAppear() {
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 544, height: 568)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
        
        d.setDefaults {}
        
        if isLoading {
            if self.mgr?.state != .started && self.mgr?.state != .connected  {
                self.mgr?.start(delegate: self)
            }
            
            if self.mgr?.state == .connected {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.torIsOn = true
                    self.torVersionOutlet.stringValue = "v0.4.4.6"
                    self.startTorOutlet.title = "Stop"
                    self.startTorOutlet.isEnabled = true
                    self.updateTorStatus(isOn: true)
                    self.checkForGordian()
                }
            }
        }        
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Quit Tor and Bitcoin Core?"
        alert.informativeText = "Closing this window does not automatically quit Tor or Bitcoin Core."
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Leave Running")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        let modalResponse = alert.runModal()
        if (modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {
            self.runScript(script: .stopBitcoin)
            self.mgr?.resign()
            isLoading = true
            return true
        } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
            isLoading = true
            return true
        } else {
            return false
        }
    }
    
    @IBAction func peerDetailAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "showInfo", sender: self)
        }
    }
    
    @IBAction func showSettingsAction(_ sender: Any) {
        var myWindow: NSWindow? = nil
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let settings = storyboard.instantiateController(withIdentifier: "Settings") as! Settings
        myWindow = NSWindow(contentViewController: settings)
        NSApp.activate(ignoringOtherApps: true)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
    }
    
    @IBAction func showQuickConnectAction(_ sender: Any) {
        if torIsOn {
            var myWindow: NSWindow? = nil
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let quickconnect = storyboard.instantiateController(withIdentifier: "QuickConnect") as! QRDisplayer
            myWindow = NSWindow(contentViewController: quickconnect)
            NSApp.activate(ignoringOtherApps: true)
            myWindow?.makeKeyAndOrderFront(self)
            let vc = NSWindowController(window: myWindow)
            vc.showWindow(self)
        } else {
            simpleAlert(message: "Tor not running...", info: "In order to connect to your node remotely you need to start Tor first.", buttonLabel: "OK")
        }
    }    

    @objc func refreshNow() {
        d.setDefaults { [weak self] in
            guard let self = self else { return }
            
            self.checkForGordian()
        }
    }

    private func checkForBitcoinUpdate() {
        d.setDefaults { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            self.getLatestVersion { [weak self] (success, errorMessage) in
                guard let self = self else { return }
                
                if success {
                    self.setEnv()
                    if self.currentVersion.contains(self.d.existingVersion) {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.updateOutlet.isEnabled = false
                            self.updateOutlet.title = "Update"
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.updateOutlet.title = "Update"
                            self.updateOutlet.isEnabled = true
                            
                            actionAlert(message: "A newer version of Bitcoin Core has been released. Upgrade to Bitcoin Core \(self.newestVersion)?", info: "") { (response) in
                                if response {
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }
                                        
                                        self.upgrading = true
                                        self.autoRefreshTimer?.invalidate()
                                        self.performSegue(withIdentifier: "goInstall", sender: self)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    simpleAlert(message: "Network request error", info: errorMessage ?? "We had an issue getting a response from the Bitcoin Core repo on GitHub, we do this to check for new releases, you can ignore this error but we thought you should know something is up, please check your internet connection.", buttonLabel: "OK")
                    self.setEnv()
                }
            }
        }
    }

    //MARK: User Action
    
    @IBAction func userSelectedMainnet(_ sender: Any) {
        UserDefaults.standard.setValue("main", forKey: "chain")
        chain = "main"
        updateTorInfo()
        setEnv()
        resetOutlets()
        checkSystem()
    }
    
    @IBAction func userSelectedTestnet(_ sender: Any) {
        UserDefaults.standard.setValue("test", forKey: "chain")
        chain = "test"
        updateTorInfo()
        setEnv()
        resetOutlets()
        checkSystem()
    }
    
    @IBAction func userSelectedRegtest(_ sender: Any) {
        UserDefaults.standard.setValue("regtest", forKey: "chain")
        chain = "regtest"
        updateTorInfo()
        setEnv()
        resetOutlets()
        checkSystem()
    }
    
    @IBAction func userSelectedSignet(_ sender: Any) {
        UserDefaults.standard.setValue("signet", forKey: "chain")
        chain = "signet"
        updateTorInfo()
        setEnv()
        resetOutlets()
        checkSystem()
    }

    @IBAction func refreshAction(_ sender: Any) {
        checkSystem()
    }
    
    private func addSpinnerDesc(_ description: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = description
            self.spinner.startAnimation(self)
            self.spinner.alphaValue = 1
            self.taskDescription.alphaValue = 1
        }
    }
    
    private func checkSystem() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking system..."
            self.spinner.startAnimation(self)
            self.spinner.alphaValue = 1
            self.taskDescription.alphaValue = 1
        }
        
        checkForGordian()
    }

    @IBAction func removeAuthAction(_ sender: Any) {
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        
        actionAlert(message: "Remove \(chain) network authentication keys?", info: "Removing your authentication keys means anyone who gets your quick connect QR will be able to access your \(chain) network Bitcoin Core wallets. Are you sure you want to remove all authentication keys?") { response in
            if response {
                let path = "\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(chain)/authorized_clients/"
                
                do {
                    let filePaths = try FileManager.default.contentsOfDirectory(atPath: path)
                    for (i, filePath) in filePaths.enumerated() {
                        try FileManager.default.removeItem(atPath: path + filePath)
                        
                        if i + 1 == filePaths.count {
                            self.mgr?.resign()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.mgr?.start(delegate: self)
                            }
                            simpleAlert(message: "Success", info: "Authorized clients files removed, your \(chain) network Bitcoin Core rpc hidden services are no longer authenticated!", buttonLabel: "OK")
                        }
                    }
                } catch {
                    simpleAlert(message: "There was an issue deleting your auth keys...", info: "\(error.localizedDescription)\n\nPlease let us know about this bug.", buttonLabel: "OK")
                }
            }
        }
    }

    private func addAuth() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "addAuth", sender: self)
        }
    }

    @IBAction func addAuthAction(_ sender: Any) {
        addAuth()
    }

    @IBAction func startMainnetAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.autoRefreshTimer?.invalidate()
            self.autoRefreshTimer = nil
            self.startMainnetOutlet.isEnabled = false
            self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusPartiallyAvailable")
            self.networkButton.isEnabled = false
            self.verifyOutlet.isEnabled = false
        }
        
        if !bitcoinRunning {
            addSpinnerDesc("starting \(chain)...")
            runScript(script: .startBitcoin)
        } else {
            addSpinnerDesc("stopping \(chain)...")
            runScript(script: .stopBitcoin)
        }
    }

    @IBAction func bitcoinWindowHelp(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.headerText = "Bitcoin Core"
            self.infoMessage = "Gordian Server creates a ~./gordian directory where it installs Bitcoin Core. Gordian Server works with the default Bitcoin directory at /Users/\(NSUserName())/Library/Application Support/Bitcoin. Specify a custom blocksdir for storing the blockchain via File > Settings (or the settings button). Run multiple networks (main, test, regtest, signet) simultaneously, useful for development and testing purposes. Click the QR button to remotely connect to your node. Click Go To for more tools. Bitcoin is run in the background, even if you quit Gordian Server Bitcoin Core will continue running unless you stop it."
            self.performSegue(withIdentifier: "segueToHelp", sender: self)
        }
    }

    @IBAction func torWindowHelp(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.headerText = "Tor"
            self.infoMessage = "Gordian Server integrates Tor to make connecting to your node easy, secure and private. You must leave Gordian Server running in order to connect to your node remotely as quitting the app will also quit Tor. If you run Tor elsewhere on your computer Gordian Server will not interfere with it. You may start/stop Tor and add/remove Tor authentication keys with Gordian Server. Click the Go To menu item to see additonal Tor related tools."
            self.performSegue(withIdentifier: "segueToHelp", sender: self)
        }
    }

    @IBAction func updateBitcoin(_ sender: Any) {
        if !bitcoinInstalled {
            installNow()
        } else {
            DispatchQueue.main.async {
                FetchLatestRelease.get { (dict, err) in
                    if err != nil {
                        simpleAlert(message: "Error", info: "Error fetching latest release: \(err ?? "unknown error")", buttonLabel: "OK")
                    } else {
                        let version = dict!["version"] as! String
                        actionAlert(message: "Upgrade to Bitcoin Core \(version)?", info: "") { (response) in
                            if response {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    
                                    self.upgrading = true
                                    self.autoRefreshTimer?.invalidate()
                                    self.performSegue(withIdentifier: "goInstall", sender: self)
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isVerifying = true
            self.performSegue(withIdentifier: "goInstall", sender: self)
        }
    }

    private func installNow() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.autoRefreshTimer?.invalidate()
            self.autoRefreshTimer = nil
        }
        
        startSpinner(description: "Fetching latest Bitcoin Core version...")
        FetchLatestRelease.get { [weak self] (dict, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.hideSpinner()
                simpleAlert(message: "Error", info: error ?? "We had an error fetching the latest version of Bitcoin Core, please check your internet connection and try again", buttonLabel: "OK")

            } else {
                self.hideSpinner()
                let version = dict!["version"] as! String

                // Installing from scratch, however user may have gone into settings and changed some things so we need to check for that.
                func standup() {
                    let pruned = self.d.prune
                    let txindex = self.d.txindex
                    let directory = self.d.dataDir
                    let pruneInGb = Double(pruned) / 954.0
                    let rounded = Double(round(100 * pruneInGb) / 100)

                    self.infoMessage = """
                    Gordian Server will install and configure a pruned (\(rounded)gb) Bitcoin Core node.

                    You can always edit settings via File > Settings.

                    If your node is already running you will need to restart it for the new settings to take effect.

                    Gordian Server will create the following directory: /Users/\(NSUserName())/.gordian/BitcoinCore

                    It will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                    """

                    if pruned == 0 || pruned == 1 {
                        self.infoMessage = """
                        GordianServer will install and configure Bitcoin Core node.

                        You have set pruning to \(pruned), you can always edit the pruning amount in settings.

                        You can always edit settings via File > Settings.

                        GordianServer will create the following directory: /Users/\(NSUserName())/.gordian/BitcoinCore

                        It will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                        """
                    }

                    if txindex == 1 {
                        self.infoMessage = """
                        Gordian Server will install and configure a fully indexed Bitcoin Core node.

                        You can always edit settings via File > Settings.

                        Gordian Server will create the following directory: /Users/\(NSUserName())/.gordian/BitcoinCore

                        It will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                        """
                    }
                    
                    self.headerText = "Install Bitcoin Core v\(version)?"
                    self.ignoreExistingBitcoin = false
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.performSegue(withIdentifier: "segueToInstallPrompt", sender: self)
                    }
                }

                // Bitcoind and possibly tor are already installed
                if self.bitcoinInstalled {

                    self.headerText = "Install Bitcoin Core v\(version)?"

                    self.infoMessage = """
                    Selecting yes will tell Gordian Server to download, verify and install a fresh Bitcoin Core v\(version) installation in ~/.gordian/BitcoinCore, Gordian Server will not overwrite your existing node.

                    Your existing bitcoin.conf file will be checked for rpc username and password, if none exist Gordian Server will create them for you, all other bitcoin.conf settings will remain in place.
                    """
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.ignoreExistingBitcoin = true
                        self.performSegue(withIdentifier: "segueToInstallPrompt", sender: self)
                    }
                } else {
                    standup()
                }
            }
        }
    }
    
    @IBAction func torAuthHelpAction(_ sender: Any) {
        DispatchQueue.main.async {
            guard let url = URL(string: "https://community.torproject.org/onion-services/advanced/client-auth/") else { return }
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func standUp(_ sender: Any) {
        installNow()
    }
    
    @IBAction func startTorAction(_ sender: Any) {
        if !torIsOn {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.startSpinner(description: "starting tor...")
                self.startTorOutlet.isEnabled = false
                self.mgr?.start(delegate: self)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.startTorOutlet.isEnabled = false
                self.mgr?.resign()
                self.updateTorStatus(isOn: false)
            }
        }
    }
    
    // MARK: Script Methods

    func checkForXcodeSelect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking for xcode select..."
            self.runScript(script: .checkXcodeSelect)
        }
    }

    func isBitcoinOn() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking if bitcoin core is running..."
        }
        
        runScript(script: .isBitcoindRunning)
    }

    func checkBitcoindVersion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking if bitcoin core is installed..."
            self.runScript(script: .checkForBitcoin)
        }
    }

    func checkBitcoinConfForRPCCredentials() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking for default Bitcoin data directory..."
            
            let path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
            
            guard let conf = try? String(contentsOf: path, encoding: .utf8) else {
                actionAlert(message: "Missing bitcoin.conf file.",
                            info: "You need a bitcoin.conf file for Gordian Server to function. Would you like to add the default bitcoin.conf?") { [weak self] response in
                    guard let self = self else { return }
                    
                    if response {
                        self.setDefaultBitcoinConf()
                    }
                }
                return
            }
            self.checkForRPCCredentials(response: conf)
        }
    }
    
    private func setDefaultBitcoinConf() {
        let bitcoinPath = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin", isDirectory: true).path
        
        do {
            try FileManager.default.createDirectory(atPath: bitcoinPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: [FileAttributeKey.posixPermissions: 0o700])
        } catch {
            print("Bitcoin directory previously created.")
        }
        
        
        let bitcoinConfUrl = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
        
        guard let bitcoinConf = BitcoinConf.bitcoinConf().data(using: .utf8) else { return }
        
        do {
            try bitcoinConf.write(to: bitcoinConfUrl)
            simpleAlert(message: "bitcoin.conf created ✓", info: "", buttonLabel: "OK")
        } catch {
            simpleAlert(message: "There was an issue...", info: "Unable to create the bitcoin.conf, please let us know about this bug.", buttonLabel: "OK")
        }
    }

    func checkForGordian() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "checking for ~/.gordian/BitcoinCore directory..."
            self.runScript(script: .checkForGordian)
        }
    }

    private func runScript(script: SCRIPT) {
        #if DEBUG
        print("script: \(script.stringValue)")
        #endif
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            let resource = script.stringValue
            guard let path = Bundle.main.path(forResource: resource, ofType: "command") else { return }
            let stdOut = Pipe()
            let stdErr = Pipe()
            let task = Process()
            task.launchPath = path
            task.environment = self?.env
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
                if errorOutput != "" && !errorOutput.contains("Pruning blockstore") && !errorOutput.contains("not connect to the server") && !errorOutput.contains("block") && !errorOutput.contains("Loading P2P addresses")  {
                    if errorOutput.contains("Cannot obtain a lock on data directory") {
                        simpleAlert(message: "Shutdown in progress...", info: "Please be patient while Bitcoin Core shuts down, you will see \"Shutdown: done\" in the log output below when it has completely stopped.", buttonLabel: "OK")
                    } else {
                        simpleAlert(message: "Error", info: errorOutput, buttonLabel: "OK")
                    }
                    
                }
                
                #endif
                result += errorOutput
            }
            
            self?.parseScriptResult(script: script, result: result)
        }
    }
    
    private func showBitcoinLog() {
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        var path:URL?
        
        switch chain {
        case "main":
            path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/debug.log")
        case "test":
            path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/testnet3/debug.log")
        case "regtest":
            path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/regtest/debug.log")
        case "signet":
            path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/signet/debug.log")
        default:
            break
        }
        
        guard let path = path, let log = try? String(contentsOf: path, encoding: .utf8) else {
            print("can not get \(chain) debug.log")
            return
        }
        
        let logItems = log.components(separatedBy: "\n")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if logItems.count > 2 {
                self.bitcoinCoreLogOutlet.stringValue = "\(logItems[logItems.count - 2])"
                
                if "\(logItems[logItems.count - 2])".contains("Shutdown: done") {
                    self.hideSpinner()
                    self.bitcoinIsOff()
                }
            }
        }
    }

    //MARK: Script Result Filters

    func parseScriptResult(script: SCRIPT, result: String) {
        switch script {
        case .checkForGordian:
            checkGordianParser(result: result)
            
        case .stopBitcoin:
            showBitcoinLog()
            stopBitcoinParse(result: result)
            
        case .startBitcoin:
            showBitcoinLog()
            startBitcoinParse(result: result)

        case .checkForBitcoin:
            parseBitcoindVersionResponse(result: result)

        case .checkXcodeSelect:
            parseXcodeSelectResult(result: result)
            
        case .hasBitcoinShutdownCompleted:
            parseHasBitcoinShutdownCompleted(result: result)
            
        case .isBitcoindRunning:
            parseIsBitcoindRunning(result: result)
            
        case .didBitcoindStart:
            parseDidBitcoinStart(result: result)

        default:
            break
        }
    }

     private func bitcoinIsOff() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            self.bitcoinRunning = false
            self.startMainnetOutlet.title = "Start"
            self.startMainnetOutlet.isEnabled = true
            self.networkButton.isEnabled = true
            self.verifyOutlet.isEnabled = true
            self.resetOutlets()
        }
    }

    //MARK: Script Result Parsers
    
    private func parseIsBitcoindRunning(result: String) {
        if result.contains("Stopped") {
            hideSpinner()
            bitcoinIsOff()
            if d.autoStart && isLoading {
                self.addSpinnerDesc("starting \(self.chain)...")
                self.runScript(script: .startBitcoin)
            }
        } else {
            bitcoinRunning = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusPartiallyAvailable")
            }
            getBlockchainInfo()
        }
    }
    
    private func stopBitcoinParse(result: String) {
        if result.contains("Bitcoin Core stopping") {
            DispatchQueue.main.async() { [weak self] in
                guard let self = self else { return }
                
                self.shutDownTimer?.invalidate()
                self.shutDownTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.queryShutDownStatus), userInfo: nil, repeats: true)
            }
        } else {
            simpleAlert(message: "Error turning off mainnet", info: result, buttonLabel: "OK")
        }
    }
    
    private func parseHasBitcoinShutdownCompleted(result: String) {
        if result.contains("Stopped") {
            shutDownTimer?.invalidate()
            shutDownTimer = nil
            hideSpinner()
            bitcoinIsOff()
        }
    }
    
    @objc func queryShutDownStatus() {
        showBitcoinLog()
        runScript(script: .hasBitcoinShutdownCompleted)
    }
    
    @objc func queryStartStatus() {
        showBitcoinLog()
        isBitcoinOn()
    }

    private func startBitcoinParse(result: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.runScript(script: .didBitcoindStart)
        }
    }
    
    private func parseDidBitcoinStart(result: String) {
        if !result.contains("Stopped") {
            isBitcoinOn()
        }
    }

    private func parseXcodeSelectResult(result: String) {
        hideSpinner()
        if result.contains("XCode select not installed") {
            self.headerText = "Xcode command line tools is not installed."
            self.infoMessage = "Gordian Server relies on Xcode command line tools for installing Bitcoin Core. It uses about 2.7gb of space and includes a bunch of useful tools to do Bitcoin and Lightning related tasks. Clicking \"Install\" will launch a terminal which starts the installation process for you, please follow any prompts and wait for the installation to complete."
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.performSegue(withIdentifier: "segueToInstallXcode", sender: self)
            }
        } else {
            installNow()
        }
    }

    func checkGordianParser(result: String) {
        if result.contains("False") {
            checkForXcodeSelect()
        } else {
            checkBitcoinConfForRPCCredentials()
        }
    }

    private func command(command: String, completion: @escaping ((Any?)) -> Void) {
        let rpc = MakeRpcCall.shared
        var port:String!
        switch chain {
        case "main":
            port = "8332"
        case "test":
            port = "18332"
        case "regtest":
            port = "18443"
        case "signet":
            port = "38332"
        default:
            break
        }
        rpc.command(method: command, port: port, user: rpcuser, password: rpcpassword) { [weak self] (response, error) in
            guard let self = self else { return }
            
            if error == nil {
                DispatchQueue.main.async {
                    self.startTimer?.invalidate()
                    self.startTimer = nil
                }
                
                completion((response))
                
            } else if let error = error {
                
                switch error {
                case _ where error.contains("Loading block index"),
                     _ where error.contains("Verifying blocks"),
                     _ where error.contains("Loading P2P addresses…"),
                     _ where error.contains("Pruning"),
                     _ where error.contains("Rewinding"),
                     _ where error.contains("Rescanning"),
                     _ where error.contains("Loading wallet"):
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.mainnetSyncedLabel.stringValue = "Loading..."
                        self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusPartiallyAvailable")
                        self.startMainnetOutlet.title = "Stop"
                        self.startMainnetOutlet.isEnabled = false
                        self.startTimer?.invalidate()
                        self.startTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.queryStartStatus), userInfo: nil, repeats: true)
                    }
                    
                case _ where error.contains("Could not connect to the server"):
                    self.hideSpinner()
                    self.bitcoinIsOff()
                
                default:
                    self.hideSpinner()
                    simpleAlert(message: "Bitcoin Core Message", info: error, buttonLabel: "OK")
                }
            }
        }
    }

    func updateTorStatus(isOn: Bool) {
        torIsOn = isOn
        if isOn {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.torRunningImage.alphaValue = 1
                self.torRunningImage.image = NSImage.init(imageLiteralResourceName: "NSStatusAvailable")
                self.startTorOutlet.isEnabled = true
                self.startTorOutlet.title = "Stop"
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.torRunningImage.alphaValue = 1
                self.torRunningImage.image = NSImage.init(imageLiteralResourceName: "NSStatusUnavailable")
                self.startTorOutlet.isEnabled = true
                self.startTorOutlet.title = "Start"
            }
        }
    }

    func checkForRPCCredentials(response: String) {
        let bitcoinConf = response.components(separatedBy: "\n")
        for item in bitcoinConf {
            if item.contains("rpcuser") {
                let arr = item.components(separatedBy: "rpcuser=")
                rpcuser = arr[1]
                UserDefaults.standard.setValue(rpcuser, forKey: "rpcuser")
            }
            if item.contains("rpcpassword") {
                let arr = item.components(separatedBy: "rpcpassword=")
                rpcpassword = arr[1]
                UserDefaults.standard.setValue(rpcpassword, forKey: "rpcpassword")
            }
            if item.contains("testnet=1") || item.contains("testnet=0") || item.contains("regtest=1") || item.contains("regtest=0") || item.contains("signet=1") || item.contains("signet=0") {
                simpleAlert(message: "Incompatible bitcoin.conf setting! Standup will not function properly.", info: "GordianServer allows you to run multiple networks simultaneously, we do this by specifying which chain we want to launch as a command line argument. Specifying a network in your bitcoin.conf is incompatible with this approach, please remove the line in your conf file which specifies a network to use GordianServer.", buttonLabel: "OK")
            }
        }
        if rpcpassword != "" && rpcuser != "" {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.bitcoinConfigured = true
            }
            checkBitcoindVersion()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.hideSpinner()
                self.bitcoinConfigured = false
            }
        }
    }
    
    private func getBlockchainInfo() {
        command(command: "getblockchaininfo") { [weak self] response in
            guard let self = self else { return }
            
            self.showBitcoinLog()
            
            guard let response = response as? [String:Any] else {
                return
            }
            
            self.setAutoRefreshTimer()
                        
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.bitcoinRunning = true
                let blockchainInfo = BlockchainInfo(response)
                self.blocksOutlet.stringValue = "\(blockchainInfo.blocks)"
                self.difficultyOutlet.stringValue = "\(blockchainInfo.difficulty.diffString)"
                self.pruningOutlet.stringValue = "\(blockchainInfo.pruned)"
                self.sizeOutlet.stringValue = "\(blockchainInfo.size_on_disk.size)"
                self.mainnetSyncedLabel.stringValue = blockchainInfo.verificationprogress.bitcoinCoreSyncStatus
                self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                self.startMainnetOutlet.title = "Stop"
                self.startMainnetOutlet.isEnabled = true
                self.verifyOutlet.isEnabled = true
                self.networkButton.isEnabled = true
                self.getPeerInfo()
            }
        }
    }

    private func getPeerInfo() {
        command(command: "getpeerinfo") { [weak self] response in
            guard let self = self else { return }
            
            if let peerInfoArray = response as? NSArray {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.mainnetIncomingPeersLabel.stringValue = self.peerInfo(peerInfoArray).in
                    self.mainnetOutgoingPeersLabel.stringValue = self.peerInfo(peerInfoArray).out
                    self.peerInfo = peerInfoArray.description
                    self.peerDetailsButton.alphaValue = 1
                }
            }
            self.getUpTime()
        }
    }
    
    private func getUpTime() {
        command(command: "uptime") { [weak self] response in
            guard let self = self else { return }
            
            if let uptime = response as? Double {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.uptimeOutlet.stringValue = uptime.uptime
                }
            }
            self.getMempool()
        }
    }
    
    private func getMempool() {
        command(command: "getmempoolinfo") { [weak self] response in
            guard let self = self else { return }
            
            if let response = response as? [String:Any] {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let mempoolInfo = MempoolInfo(response)
                    self.mempoolOutlet.stringValue = "\(mempoolInfo.size) txs"
                }
            }
            self.getMiningInfo()
        }
    }
    
    private func getMiningInfo() {
        command(command: "getmininginfo") { [weak self] response in
            guard let self = self else { return }
            
            if let response = response as? [String:Any] {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let miningInfo = MiningInfo(response)
                    self.hashrateOutlet.stringValue = "\(miningInfo.hashrate)"
                }
            }
            self.checkForBitcoinUpdate()
            self.hideSpinner()
        }
    }

    private func peerInfo(_ peerArray: NSArray) -> (in: String, out: String) {
        var incomingCount = 0
        var outgoingCount = 0
        for peer in peerArray {
            if let peerDict = peer as? NSDictionary {
                if let incoming = peerDict["inbound"] as? Bool {
                    if incoming {
                        incomingCount += 1
                    } else {
                        outgoingCount += 1
                    }
                }
            }
        }
        return ("\(incomingCount)", "\(outgoingCount)")
    }

    func parseBitcoindVersionResponse(result: String) {
        if result.contains("Bitcoin Core Daemon version") || result.contains("Bitcoin Core version") {
            let arr = result.components(separatedBy: "Copyright (C)")
            currentVersion = (arr[0]).replacingOccurrences(of: "Bitcoin Core Daemon version ", with: "")
            currentVersion = currentVersion.replacingOccurrences(of: "Bitcoin Core version ", with: "")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.verifyOutlet.isEnabled = true
                self.networkButton.isEnabled = true
                self.bitcoinCoreVersionOutlet.stringValue = self.currentVersion
                self.bitcoinInstalled = true
            }
            isBitcoinOn()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.updateOutlet.title = "Install"
                self.updateOutlet.isEnabled = true
                self.bitcoinInstalled = false
                self.verifyOutlet.isEnabled = false
            }
        }
    }

    //MARK: User Inteface

    func setAutoRefreshTimer() {
        if d.autoRefresh {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.autoRefreshTimer?.invalidate()
                self.autoRefreshTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.automaticRefresh), userInfo: nil, repeats: true)
            }
        } else {
            self.autoRefreshTimer?.invalidate()
            self.autoRefreshTimer = nil
        }
    }

    @objc func automaticRefresh() {
        checkSystem()
    }

    func setEnv() {
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        env = ["BINARY_NAME":d.existingBinary,"VERSION":d.existingPrefix,"PREFIX":d.existingPrefix,"DATADIR":d.dataDir, "CHAIN": chain]
        #if DEBUG
        print("env = \(env)")
        #endif
    }

    func startSpinner(description: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.spinner.startAnimation(self)
            self.taskDescription.stringValue = description
            self.spinner.alphaValue = 1
            self.taskDescription.alphaValue = 1
        }
    }

    func hideSpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = ""
            self.spinner.stopAnimation(self)
            self.spinner.alphaValue = 0
            self.taskDescription.alphaValue = 0
        }
    }

    func setScene() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.view.backgroundColor = .controlDarkShadowColor
            let chain = UserDefaults.standard.object(forKey: "chain") as? String ?? "main"
            switch chain {
            case "main":
                self.networkButton.selectItem(at: 0)
            case "test":
                self.networkButton.selectItem(at: 1)
            case "regtest":
                self.networkButton.selectItem(at: 2)
            case "signet":
                self.networkButton.selectItem(at: 3)
            default:
                break
            }
            self.taskDescription.stringValue = "checking system..."
            self.spinner.startAnimation(self)
            self.icon.wantsLayer = true
            self.icon.layer?.cornerRadius = self.icon.frame.width / 2
            self.icon.layer?.masksToBounds = true
            self.isLoading = true
            self.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusNone")
            self.updateOutlet.isEnabled = false
            self.bitcoinCoreVersionOutlet.stringValue = ""
            self.torVersionOutlet.stringValue = ""
            self.startTorOutlet.isEnabled = false
            self.verifyOutlet.isEnabled = false
            self.networkButton.isEnabled = false
            self.startMainnetOutlet.isEnabled = false
            self.torRemoveAuthOutlet.isEnabled = false
            self.torAddAuthOutlet.isEnabled = false
            //self.torRunningImage.alphaValue = 0
            self.bitcoinCoreWindow.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
            self.torWindow.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
            self.torAuthWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
            self.bitcoinCoreWindow.wantsLayer = true
            self.torWindow.wantsLayer = true
            self.torAuthWindow.wantsLayer = true
            self.bitcoinCoreWindow.layer?.borderWidth = 0.75
            self.bitcoinCoreWindow.layer?.cornerRadius = 8
           
            self.torWindow.layer?.borderWidth = 0.75
            self.torWindow.layer?.cornerRadius = 8
            self.torAuthWindow.layer?.borderWidth = 0.75
            self.torAuthWindow.layer?.cornerRadius = 8
            self.bitcoinCoreWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            self.torWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            self.torAuthWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            self.mainnetSyncedLabel.stringValue = ""
            self.mainnetIncomingPeersLabel.stringValue = ""
            self.mainnetOutgoingPeersLabel.stringValue = ""
        }
    }
    
    private func resetOutlets() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.mainnetSyncedLabel.stringValue = ""
            self.mainnetIncomingPeersLabel.stringValue = ""
            self.mainnetOutgoingPeersLabel.stringValue = ""
            self.hashrateOutlet.stringValue = ""
            self.mempoolOutlet.stringValue = ""
            self.uptimeOutlet.stringValue = ""
            self.difficultyOutlet.stringValue = ""
            self.blocksOutlet.stringValue = ""
            self.pruningOutlet.stringValue = ""
            self.sizeOutlet.stringValue = ""
        }
    }

    func showstandUpAlert(message: String, info: String) {
        DispatchQueue.main.async {
            actionAlert(message: message, info: info) { (response) in
                if response {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.standingUp = true
                        self.autoRefreshTimer?.invalidate()
                        self.performSegue(withIdentifier: "goInstall", sender: self)
                    }
                }
            }
        }
    }

    func setLog(content: String) {
        Log.writeToLog(content: content)
    }

    private func getLatestVersion(completion: @escaping ((success: Bool, errorMessage: String?)) -> Void) {
        FetchLatestRelease.get { [weak self] (dict, error) in
            guard let self = self else { return }
            
            if dict != nil {
                if let version = dict!["version"] as? String,
                    let binaryName = dict!["macosBinary"] as? String,
                    let prefix = dict!["binaryPrefix"] as? String {
                    self.newestPrefix = prefix
                    self.newestVersion = version
                    self.newestBinaryName = binaryName
                    completion((true, nil))
                } else {
                    completion((false, error))
                }
            } else {
                completion((false, error))
            }
        }
    }

    private func installXcodeCLTools() {
        runScript(script: .installXcode)
    }
    
    @objc func authAdded() {
        updateTorInfo()
    }
    
    private func updateTorInfo() {
        guard let rpchostname = mgr?.rpcHostname() else {
            return
        }
        
        guard let p2phostname = mgr?.p2pHostname(chain: UserDefaults.standard.object(forKey: "chain") as? String ?? "main") else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.p2pHostOutlet.stringValue = p2phostname
            self.rpcHostOutlet.stringValue = rpchostname
            if Defaults.shared.isPrivate == 1 {
                self.bitcoinCoreModeOutlet.stringValue = "onion only"
            } else {
                self.bitcoinCoreModeOutlet.stringValue = "onion & clearnet"
            }
            
            let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
            let path = "\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(chain)/authorized_clients/"
            
            do {
                let filePaths = try FileManager.default.contentsOfDirectory(atPath: path)
                if filePaths.count > 0 {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.rpcAuthenticated.stringValue = "\(filePaths.count) authenticated rpc clients"
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.rpcAuthenticated.stringValue = "rpc host unauthenticated"
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.rpcAuthenticated.stringValue = "rpc host unauthenticated"
                }
            }
        }
    }

    // MARK: Segue Prep

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showInfo":
            if let vc = segue.destinationController as? Installer {
                vc.peerInfo = self.peerInfo
            }
            
        case "segueToHelp":
            if let vc = segue.destinationController as? InstallerPrompt {
                vc.text = infoMessage
                vc.headerText = headerText
                vc.isHelp = true
            }
            
        case "segueToInstallXcode":
            if let vc = segue.destinationController as? InstallerPrompt {
                vc.text = infoMessage
                vc.headerText = headerText
                vc.isHelp = false
                
                vc.doneBlock = { response in
                    if response {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.autoRefreshTimer?.invalidate()
                            self.installXcodeCLTools()
                        }
                    }
                }
            }
            
        case "showPairingCode":
            if let vc = segue.destinationController as? QRDisplayer {
                vc.rpcport = rpcport
                vc.network = network
                vc.rpcpassword = rpcpassword
                vc.rpcuser = rpcuser
            }

        case "goInstall":
            if let vc = segue.destinationController as? Installer {
                vc.isVerifying = self.isVerifying
                vc.standingUp = standingUp
                vc.upgrading = upgrading
                vc.ignoreExistingBitcoin = ignoreExistingBitcoin
                if !isVerifying {
                    autoRefreshTimer?.invalidate()
                    autoRefreshTimer = nil
                }
            }

        case "segueToWallets":
            if let vc = segue.destinationController as? WalletsViewController {
                vc.chain = chain
            }
            
        case "segueToInstallPrompt":
            if let vc = segue.destinationController as? InstallerPrompt {
                vc.text = infoMessage
                vc.headerText = headerText
                
                vc.doneBlock = { response in
                    if response {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.standingUp = true
                            self.autoRefreshTimer?.invalidate()
                            self.performSegue(withIdentifier: "goInstall", sender: vc)
                        }
                    }
                }
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

extension ViewController: OnionManagerDelegate {
    
    func torConnProgress(_ progress: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.taskDescription.stringValue = "Tor bootstrapping \(progress)% complete..."
            self.torRunningImage.image = NSImage.init(imageLiteralResourceName: "NSStatusPartiallyAvailable")
        }
    }
    
    func torConnFinished() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.torIsOn = true
            self.torVersionOutlet.stringValue = "v0.4.4.6"
            self.startTorOutlet.title = "Stop"
            self.startTorOutlet.isEnabled = true
            self.torRemoveAuthOutlet.isEnabled = true
            self.torAddAuthOutlet.isEnabled = true
            self.updateTorStatus(isOn: true)
            self.checkForGordian()
        }
        
        updateTorInfo()
    }
    
    func torConnDifficulties() {
        self.hideSpinner()
        simpleAlert(message: "Tor connection issue.", info: "We are having trouble starting Tor, your node will not be remotely reachable.", buttonLabel: "OK")
        self.checkForGordian()
    }
}
