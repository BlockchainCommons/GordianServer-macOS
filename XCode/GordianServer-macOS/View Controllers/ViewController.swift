//
//  ViewController.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var installLightningOutlet: NSButton!
    @IBOutlet weak var lightningWindow: NSView!
    @IBOutlet weak var mainnetIncomingImage: NSImageView!
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
    @IBOutlet weak var bitcoinSettingsOutlet: NSButton!
    @IBOutlet var settingsOutlet: NSButton!
    @IBOutlet var verifyOutlet: NSButton!
    @IBOutlet var updateOutlet: NSButton!
    @IBOutlet var icon: NSImageView!
    @IBOutlet var torRunningImage: NSImageView!
    @IBOutlet weak var mainnetSyncedView: NSView!
    @IBOutlet weak var mainnetSyncedLabel: NSTextField!
    @IBOutlet weak var mainnetPeersView: NSView!
    @IBOutlet weak var mainnetIncomingPeersLabel: NSTextField!
    @IBOutlet weak var mainnetOutgoingPeersLabel: NSTextField!
    @IBOutlet weak var testnetSyncedView: NSView!
    @IBOutlet weak var testnetSyncedLabel: NSTextField!
    @IBOutlet weak var testnetPeersView: NSView!
    @IBOutlet weak var testnetPeersIncomingLabel: NSTextField!
    @IBOutlet weak var testnetPeersOutgoingLabel: NSTextField!
    @IBOutlet weak var regtestSyncedView: NSView!
    @IBOutlet weak var regtestSyncedLabel: NSTextField!
    @IBOutlet weak var regtestPeersView: NSView!
    @IBOutlet weak var regtestPeersIncomingLabel: NSTextField!
    @IBOutlet weak var regtestPeersOutgoingLabel: NSTextField!
    @IBOutlet weak var bitcoinIsOnHeaderImage: NSImageView!
    @IBOutlet weak var mainWalletOutlet: NSButton!
    @IBOutlet weak var testWalletsOutlet: NSButton!
    @IBOutlet weak var regWalletsOutlet: NSButton!


    var installingLightning = Bool()
    var timer: Timer?
    var chain = ""
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
    var lightningHostname = ""
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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNow), name: .refresh, object: nil)
        setScene()
    }

    override func viewWillAppear() {
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 710, height: 658)
    }

    override func viewDidAppear() {
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 710, height: 658)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
        refresh()
    }

    @objc func refreshNow() {
        refresh()
    }

    private func refresh() {
        d.setDefaults { [unowned vc = self] in
            vc.getLatestVersion { [unowned vc = self] (success, errorMessage) in
                if success {
                    vc.setEnv()
                } else {
                    vc.showAlertMessage(message: "Network request error", info: errorMessage ?? "We had an issue getting a response from the Bitcoin Core repo on GitHub, we do this to check for new releases, you can ignore this error but we thought you should know something is up, please check your internet connection.")
                    vc.setEnv()
                }
            }
        }
    }

    //MARK: User Action

    @IBAction func installLightningAction(_ sender: Any) {
        installingLightning = true
        standingUp = false
        upgrading = false
        strapping = false
        runScript(script: .getLightningHostname)
        
    }


    @IBAction func openMainnetAuthAction(_ sender: Any) {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir(), "AUTH_DIR":"/usr/local/var/lib/tor/standup/main/authorized_clients/"]
        runScript(script: .openAuth)
    }

    @IBAction func openTestnetAuthAction(_ sender: Any) {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir(), "AUTH_DIR":"/usr/local/var/lib/tor/standup/test/authorized_clients/"]
        runScript(script: .openAuth)
    }

    @IBAction func openRegAuthAction(_ sender: Any) {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir(), "AUTH_DIR":"/usr/local/var/lib/tor/standup/reg/authorized_clients/"]
        runScript(script: .openAuth)
    }


    @IBAction func showMainWallets(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.chain = "main"
            self?.performSegue(withIdentifier: "segueToWallets", sender: self)
        }
    }

    @IBAction func showTestWallets(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.chain = "test"
            self?.performSegue(withIdentifier: "segueToWallets", sender: self)
        }
    }

    @IBAction func showRegWallets(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.chain = "regtest"
            self?.performSegue(withIdentifier: "segueToWallets", sender: self)
        }
    }


    @IBAction func refreshAction(_ sender: Any) {
        taskDescription.stringValue = "checking system..."
        spinner.startAnimation(self)
        spinner.alphaValue = 1
        taskDescription.alphaValue = 1
        refresh()
    }

    @IBAction func removeAuthAction(_ sender: Any) {
        actionAlert(message: "Warning!", info: "Removing your authentication keys means anyone who gets your hidden service url will have access to it. Are you sure you want to remove all authentication keys?") { [unowned vc = self] response in
            if response {
                vc.runScript(script: .removeAuth)
                vc.showAlertMessage(message: "Success", info: "Authorized clients directories removed, your rpc hidden services are no longer authenticated!")
            }
        }
    }

    private func addAuth() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.performSegue(withIdentifier: "addAuth", sender: vc)
        }
    }

    @IBAction func addAuthAction(_ sender: Any) {
        addAuth()
    }

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
        showAlertMessage(message: "Bitcoin Core Help", info: "GordianServer allows you to run multiple networks simultaneously which can be useful for development and testing purposes. Each network has a dedicated hidden service which gives you the ability to remotely connect to all 3 networks remotely. Just tap the QuickConnect button for whichever network you want to remotely connect to and scan the QR with supporting apps such as Gordian Wallet and Fully Noded. Mainnet is the main network where you can spend real Bitcoins, Testnet is a test network where you can connect to other nodes on the testnet3 network, which is useful for testing new features of Bitcoin Core that you may not be familiar with. Regtest is meant for developers who want to run a local network, it essentially gives you access to your own local Bitcoin blockchain, you can mine blocks easily and instantly and add multiple nodes all from your local dev environment. The verify button allows you to check the sha256 hash of the Bitcoin Core binary against what we expect it to be as per LaanWJ Vlaadmirs pgp signature. The install/update button will either setup GordianServer completely or update Bitcoin Core if there is a newer version available.")
    }

    @IBAction func torWindowHelp(_ sender: Any) {
        showAlertMessage(message: "Tor Help", info: "This window gives you direct access to the three hidden service directories by tapping the forward button for each network. This is useful if you want to use your node's onion addresses for other apps. It is also useful if you want to refresh your hidden service which can be accomplished by deleting the hidden service directory altogether.  You may add and remove Tor v3 authenticaction keys from the \"add\" and \"remove\" button. You may add up to 330 auth keys to each hidden service. GordianServer by default adds the auth key to all three hidden services, if you tap \"remove\" it will remove auth from all three hidden services so use it with caution. The start/stop button allows you to start and stop tor. If Tor is stopped your node will not be reachable remotely. You may use the install/update button to install GordianServer or to update Tor.")
    }

    @IBAction func torSettingsAction(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.settingsOutlet.isHighlighted = false
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
                FetchLatestRelease.get { (dict, err) in
                    if err != nil {
                        setSimpleAlert(message: "Error", info: "Error fetching latest release: \(err ?? "unknown error")", buttonLabel: "OK")
                    } else {
                        let version = dict!["version"] as! String
                        actionAlert(message: "Upgrade to Bitcoin Core \(version)?", info: "") { (response) in
                            if response {
                                DispatchQueue.main.async { [unowned vc = self] in
                                    vc.upgrading = true
                                    vc.timer?.invalidate()
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
        FetchLatestRelease.get { [unowned vc = self] (dict, error) in

            if error != nil {
                vc.hideSpinner()
                setSimpleAlert(message: "Error", info: error ?? "We had an error fetching the latest version of Bitcoin Core, please check your internet connection and try again", buttonLabel: "OK")

            } else {
                vc.hideSpinner()
                let version = dict!["version"] as! String

                // Installing from scratch, however user may have gone into settings and changed some things so we need to check for that.
                func standup() {
                    let pruned = vc.d.prune()
                    let txindex = vc.d.txindex()
                    let directory = vc.d.dataDir()
                    let pruneInGb = Double(pruned) / 954.0
                    let rounded = Double(round(100 * pruneInGb) / 100)

                    var info = """
                    GordianServer will by default install and configure a pruned Bitcoin Core v\(version) node and Tor v0.4.3.6

                    You can always edit the pruning size in settings. By default we prune the blockchain to half your available disc space which is currently \(rounded)gb.

                    If you would like to install a different node go to \"Settings\" for pruning, mainnet, data directory and tor related options, you can always adjust the settings and restart your node for the changes to take effect.

                    GordianServer will create the following directory: /Users/\(NSUserName())/.standup

                    By default it will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                    """

                    if pruned == 0 || pruned == 1 {
                        info = """
                        GordianServer will install and configure Bitcoin Core v\(version) node and Tor v0.4.3.6

                        You have set pruning to \(pruned), you can always edit the pruning amount in settings.

                        If you would like to install a different node go to \"Settings\" for pruning, mainnet, data directory and tor related options, you can always adjust the settings and restart your node for the changes to take effect.

                        GordianServer will create the following directory: /Users/\(NSUserName())/.standup

                        By default it will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                        """
                    }

                    if txindex == 1 {
                        info = """
                        GordianServer will install and configure a fully indexed Bitcoin Core v\(version) node and Tor v0.4.3.6

                        You can always edit the pruning size in settings.

                        If you would like to install a different node go to \"Settings\" for pruning, mainnet, data directory and tor related options, you can always adjust the settings and restart your node for the changes to take effect.

                        GordianServer will create the following directory: /Users/\(NSUserName())/.standup

                        By default it will create or add missing rpc credentials to the bitcoin.conf in \(directory).
                        """
                    }

                    vc.showstandUpAlert(message: "Ready to Standup?", info: info)
                }

                // Bitcoind and possibly tor are already installed
                if vc.bitcoinInstalled {

                    var message = "Install Bitcoin Core v\(version) and Tor with GordianServer?"

                    var infoMessage = """
                    You have an existing version of Bitcoin Core installed.

                    Selecting yes will tell GordianServer to download, verify and install a fresh Bitcoin Core v\(version) installation in ~/.standup/BitcoinCore, GordianServer will not overwrite your existing node.

                    Your existing bitcoin.conf file will be checked for rpc username and password, if none exist GordianServer will create them for you, all other bitcoin.conf settings will remain in place.

                    GordianServer will also install Tor v0.4.3.6 and configure hidden services for your nodes rpcport so that you may easily and securely connect to your node remotely.
                    """

                    if vc.torInstalled {
                        message = "Verify and install Bitcoin Core v\(version) with GordianServer?"

                        infoMessage = """
                        You have an existing version of Bitcoin Core and Tor installed.

                        Selecting yes will tell GordianServer to download, verify and install a fresh Bitcoin Core v\(version) installation in ~/.standup/BitcoinCore. This will **not** overwrite your existing node.

                        Your existing bitcoin.conf file will be checked for rpc username and password, if none exist GordianServer will create them for you, all other bitcoin.conf settings will remain in place.

                        We do this so that we may verify the singatures of the binaries ourself and only use the binary we verified.

                        Looks like you also already have Tor installed, GordianServer will always check to see if Tor has already been configured properly, if you have not already created Hidden Services for your nodes rpcport it will create them for you.
                        """
                    }

                    actionAlert(message: message, info: infoMessage) { response in

                        if response {
                            DispatchQueue.main.async { [unowned vc = self] in
                                vc.standingUp = true
                                vc.ignoreExistingBitcoin = true
                                vc.timer?.invalidate()
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

    private func checkForAuth() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.taskDescription.stringValue = "checking for auth..."
            vc.runScript(script: .checkForAuth)
        }
    }

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
            vc.taskDescription.stringValue = "checking for ~/.standup directory..."
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

        case .checkForAuth:
            parseAuthCheck(result: result)

        case .checkForOldHost:
            parseOldHostResponse(result: result)
            
        case .getLightningHostname:
            DispatchQueue.main.async { [weak self] in
                self?.lightningHostname = result
                self?.timer?.invalidate()
                self?.performSegue(withIdentifier: "goInstall", sender: self)
            }

        default: break
        }
    }

    private func parseOldHostResponse(result: String) {
        if result.contains("Exists") {
            actionAlert(message: "You have an outdated version of GordianServer", info: "You need to run through the installation script again to configure your new Tor hidden services and to be able to run more then one network at a time, GordianServer may not function properly otherwise.") { [unowned vc = self] response in
                if response {
                    vc.runScript(script: .removeOldHost)
                    vc.installNow()
                }
            }
        } else {
            checkForAuth()
        }
    }

    private func parseAuthCheck(result: String) {
        if result.contains("Unauthenticated") && torConfigured && bitcoinConfigured {
            let ud = UserDefaults.standard
            if ud.object(forKey: "doNotAskForAuthAgain") == nil {
               addAuth()
            }
        }
    }

    private func mainnetIsOff() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.mainOn = false
            vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startMainnetOutlet.title = "Start"
            vc.startMainnetOutlet.isEnabled = true
            vc.mainWalletOutlet.isEnabled = false
        }
    }

    private func testnetIsOff() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.testOn = false
            vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startTestnetOutlet.title = "Start"
            vc.startTestnetOutlet.isEnabled = true
            vc.testWalletsOutlet.isEnabled = false
        }
    }

    private func regtestIsOff() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.regTestOn = false
            vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
            vc.startRegtestOutlet.title = "Start"
            vc.startRegtestOutlet.isEnabled = true
            vc.regWalletsOutlet.isEnabled = false
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
            showAlertMessage(message: "Dependencies missing", info: "You do not appear to have XCode command line tools installed, GordianServer.app relies on XCode command line tools for installing Bitcoin Core, therefore in order to continue please select \"Install Dependencies\".")
        } else {
            installNow()
        }
    }

    private func parseHomebrewResult(result: String) {
        if result.contains("Homebrew not installed") {
            hideSpinner()
            actionAlert(message: "Install dependencies?", info: "You do not appear to have Homebrew installed, GordianServer.app relies on homebrew for installing Tor. We use a well known open source script called Strap to setup your mac for best security and privacy practices, it also installs Homebrew and few other very useful tools. You can read more about Strap here: \"https://github.com/MikeMcQuaid/strap\". This will launch a terminal session and prompt you for your password to run through the process, once complete you can quit and open GordianServer to continue." ) { [unowned vc = self] response in
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
            runScript(script: .checkForOldHost)
            //checkForAuth()
        }
    }

    private func convertStringToDictionary(json: String) -> [String: AnyObject]? {
        if let data = json.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.mutableLeaves, .allowFragments]) as? [String: AnyObject]
                return json
            } catch {
                return nil
            }
        }
        return nil
    }

    private func progress(dict: [String:AnyObject]) -> String {
        if let verificationprogress = dict["verificationprogress"] as? Double {
            if verificationprogress >= 0.99 {
                return "fully synced"
            } else {
                return "\(Int(verificationprogress*100))% synced"
            }
        } else {
            return ""
        }
    }

    private func parseIsMainOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            mainnetIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {

            if result.contains("chain") {
                if let dict = convertStringToDictionary(json: result) {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.mainnetSyncedLabel.stringValue = vc.progress(dict: dict)
                    }
                }
            } else if result.contains("Loading block index...") {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.mainnetSyncedLabel.stringValue = "Loading blocks..."
                }
            }

            DispatchQueue.main.async { [unowned vc = self] in
                vc.mainOn = true
                vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startMainnetOutlet.title = "Stop"
                vc.startMainnetOutlet.isEnabled = true
                vc.mainWalletOutlet.isEnabled = true
                vc.setTimer()
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.mainOn = false
                vc.mainnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startMainnetOutlet.title = "Start"
                vc.mainWalletOutlet.isEnabled = false
                vc.startMainnetOutlet.isEnabled = false
            }
        }
        runScript(script: .isTestOn)
    }

    private func parseIsTestOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            testnetIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {

            if result.contains("chain") {
                if let dict = convertStringToDictionary(json: result) {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.testnetSyncedLabel.stringValue = vc.progress(dict: dict)
                    }
                }
            } else if result.contains("Loading block index...") {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.testnetSyncedLabel.stringValue = "Loading blocks..."
                }
            }

            DispatchQueue.main.async { [unowned vc = self] in
                vc.testOn = true
                vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startTestnetOutlet.title = "Stop"
                vc.startTestnetOutlet.isEnabled = true
                vc.testWalletsOutlet.isEnabled = true
                vc.setTimer()
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.testOn = false
                vc.testnetIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startTestnetOutlet.title = "Start"
                vc.testWalletsOutlet.isEnabled = false
                vc.startTestnetOutlet.isEnabled = false
            }
        }
        runScript(script: .isRegOn)
    }

    private func parseIsRegtestOn(result: String) {
        if result.contains("Could not connect to the server 127.0.0.1") {
            regtestIsOff()
        } else if result.contains("chain") || result.contains("Loading block index...") {

            if result.contains("chain") {
                if let dict = convertStringToDictionary(json: result) {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.regtestSyncedLabel.stringValue = vc.progress(dict: dict)
                    }
                }
            } else if result.contains("Loading block index...") {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.regtestSyncedLabel.stringValue = "Loading blocks..."
                }
            }

            DispatchQueue.main.async { [unowned vc = self] in
                vc.regTestOn = true
                vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusAvailable")
                vc.startRegtestOutlet.title = "Stop"
                vc.startRegtestOutlet.isEnabled = true
                vc.regWalletsOutlet.isEnabled = true
                vc.setTimer()
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.regTestOn = false
                vc.regtestIsOnImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
                vc.startRegtestOutlet.title = "Start"
                vc.startRegtestOutlet.isEnabled = false
                vc.regWalletsOutlet.isEnabled = false
            }
        }
        if isLoading {
            checkBitcoindVersion()
        }
    }

    private func command(chain: String, command: String, completion: @escaping ((Any?)) -> Void) {
        let rpc = MakeRpcCall.shared
        var port:String!
        switch chain {
        case "main":
            port = "8332"
        case "test":
            port = "18332"
        case "regtest":
            port = "18443"
        default:
            break
        }
        rpc.command(method: command, port: port, user: rpcuser, password: rpcpassword) { response in
            completion((response))
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
            torInstalled = true
            var version = (result.replacingOccurrences(of: "Tor version ", with: ""))
            if version.count == 8 {
                version = String(version.dropLast())
            }
            DispatchQueue.main.async { [unowned vc = self] in
                vc.torVersionOutlet.stringValue = "v\(version)"
                vc.installTorOutlet.title = "Start"
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
            if item.contains("testnet=1") || item.contains("testnet=0") || item.contains("regtest=1") || item.contains("regtest=0") {
                setSimpleAlert(message: "Incompatible bitcoin.conf setting! Standup will not function properly.", info: "GordianServer allows you to run multiple networks simultaneously, we do this by specifying which chain we want to launch as a command line argument. Specifying a network in your bitcoin.conf is incompatible with this approach, please remove the line in your conf file which specifies a network to use GordianServer.", buttonLabel: "OK")
            }
        }
        if rpcpassword != "" && rpcuser != "" {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.bitcoinConfigured = true
            }
            getPeerInfo()
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.bitcoinConfigured = false
            }
        }
        getTorrcFile()
    }

    private func getPeerInfo() {
        command(chain: "test", command: "getpeerinfo") { response in
            if let peerInfoArray = response as? NSArray {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.testnetPeersIncomingLabel.stringValue = vc.peerInfo(peerInfoArray).in
                    vc.testnetPeersOutgoingLabel.stringValue = vc.peerInfo(peerInfoArray).out
                }
            }
        }
        command(chain: "main", command: "getpeerinfo") { response in
            if let peerInfoArray = response as? NSArray {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.mainnetIncomingPeersLabel.stringValue = vc.peerInfo(peerInfoArray).in
                    vc.mainnetOutgoingPeersLabel.stringValue = vc.peerInfo(peerInfoArray).out
                }
            }
        }
        command(chain: "regtest", command: "getpeerinfo") { response in
            if let peerInfoArray = response as? NSArray {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.regtestPeersIncomingLabel.stringValue = vc.peerInfo(peerInfoArray).in
                    vc.regtestPeersOutgoingLabel.stringValue = vc.peerInfo(peerInfoArray).out
                }
            }
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
                vc.installLightningOutlet.isEnabled = true
                if currentVersion.contains(vc.newestVersion) {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.updateOutlet.isEnabled = false
                        vc.updateOutlet.title = "Update"
                        vc.verifyOutlet.isEnabled = true
                    }
                } else {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.updateOutlet.title = "Update"
                        vc.updateOutlet.isEnabled = true
                        vc.verifyOutlet.isEnabled = true
                        actionAlert(message: "A newer version of Bitcoin Core has been released. Upgrade to Bitcoin Core \(vc.newestVersion)?", info: "") { (response) in
                            if response {
                                DispatchQueue.main.async { [unowned vc = self] in
                                    vc.upgrading = true
                                    vc.timer?.invalidate()
                                    vc.performSegue(withIdentifier: "goInstall", sender: vc)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.updateOutlet.title = "Install"
                vc.updateOutlet.isEnabled = true
                vc.bitcoinInstalled = false
                vc.verifyOutlet.isEnabled = false
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
                    vc.torMainnetPathOutlet.isEnabled = true
                    vc.torTestnetPathOutlet.isEnabled = true
                    vc.torRegtestPathOutlet.isEnabled = true
                }
            } else {
                DispatchQueue.main.async { [unowned vc = self] in
                    vc.connectMainnetOutlet.isEnabled = false
                    vc.connectTestnetOutlet.isEnabled = false
                    vc.connectRegtestOutlet.isEnabled = false
                    vc.torMainnetPathOutlet.isEnabled = false
                    vc.torTestnetPathOutlet.isEnabled = false
                    vc.torRegtestPathOutlet.isEnabled = false
                }
            }

        } else {
            DispatchQueue.main.async { [unowned vc = self] in
                vc.connectMainnetOutlet.isEnabled = false
                vc.connectTestnetOutlet.isEnabled = false
                vc.connectRegtestOutlet.isEnabled = false
                vc.torMainnetPathOutlet.isEnabled = false
                vc.torTestnetPathOutlet.isEnabled = false
                vc.torRegtestPathOutlet.isEnabled = false
            }
        }
        isTorOn()
    }

    func parseVerifyResult(result: String) {
        let binaryName = env["BINARY_NAME"] ?? ""
        if result.contains("\(binaryName): OK") {
            showAlertMessage(message: "Success", info: "Wladimir J. van der Laan signatures for \(binaryName) and SHA256SUMS.asc match")
        } else if result.contains("No ~/.standup/BitcoinCore directory") {
            showAlertMessage(message: "Error", info: "You are using a version of Bitcoin Core which was not installed by GordianServer, we are not yet able to verify Bitcoin Core instances not installed by GordianServer.")
        } else {
            showAlertMessage(message: "DANGER!!! Invalid signatures...", info: "Please delete the ~/.standup folder and app and report an issue on the github, PGP signatures are not valid")
        }
    }

    //MARK: User Inteface

    private func setTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(automaticRefresh), userInfo: nil, repeats: true)
    }

    @objc func automaticRefresh() {
        refresh()
    }

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
        view.backgroundColor = .controlDarkShadowColor
        taskDescription.stringValue = "checking system..."
        spinner.startAnimation(self)
        icon.wantsLayer = true
        icon.layer?.cornerRadius = icon.frame.width / 2
        icon.layer?.masksToBounds = true
        isLoading = true
        bitcoinIsOnHeaderImage.image = NSImage(imageLiteralResourceName: "NSStatusUnavailable")
        settingsOutlet.isHighlighted = false
        bitcoinSettingsOutlet.isHighlighted = false
        bitcoinSettingsOutlet.focusRingType = .none
        installLightningOutlet.isEnabled = false
        updateOutlet.isEnabled = false
        bitcoinCoreVersionOutlet.stringValue = ""
        installTorOutlet.isEnabled = false
        verifyOutlet.isEnabled = false
        mainWalletOutlet.isEnabled = false
        testWalletsOutlet.isEnabled = false
        regWalletsOutlet.isEnabled = false
        torRunningImage.alphaValue = 0
        bitcoinCoreWindow.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        torWindow.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        lightningWindow.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        bitcoinMainnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinTestnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinRegtestWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torMainnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torTestnetWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torRegtestWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        torAuthWindow.backgroundColor = #colorLiteral(red: 0.2548701465, green: 0.2549202442, blue: 0.2548669279, alpha: 1)
        bitcoinCoreWindow.wantsLayer = true
        torWindow.wantsLayer = true
        lightningWindow.wantsLayer = true
        bitcoinMainnetWindow.wantsLayer = true
        bitcoinTestnetWindow.wantsLayer = true
        bitcoinRegtestWindow.wantsLayer = true
        torMainnetWindow.wantsLayer = true
        torTestnetWindow.wantsLayer = true
        torAuthWindow.wantsLayer = true
        torRegtestWindow.wantsLayer = true
        mainnetSyncedView.wantsLayer = true
        mainnetPeersView.wantsLayer = true
        testnetSyncedView.wantsLayer = true
        testnetPeersView.wantsLayer = true
        regtestSyncedView.wantsLayer = true
        regtestPeersView.wantsLayer = true
        lightningWindow.layer?.borderWidth = 0.75
        lightningWindow.layer?.cornerRadius = 8
        mainnetSyncedView.layer?.borderWidth = 0.75
        mainnetSyncedView.layer?.cornerRadius = 5
        testnetSyncedView.layer?.borderWidth = 0.75
        testnetSyncedView.layer?.cornerRadius = 5
        regtestSyncedView.layer?.borderWidth = 0.75
        regtestSyncedView.layer?.cornerRadius = 5
        mainnetPeersView.layer?.borderWidth = 0.75
        mainnetPeersView.layer?.cornerRadius = 5
        testnetPeersView.layer?.borderWidth = 0.75
        testnetPeersView.layer?.cornerRadius = 5
        regtestPeersView.layer?.borderWidth = 0.75
        regtestPeersView.layer?.cornerRadius = 5
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
        lightningWindow.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        mainnetSyncedView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        mainnetPeersView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        testnetSyncedView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        testnetPeersView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        regtestSyncedView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        regtestPeersView.layer?.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
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
        mainnetSyncedLabel.stringValue = "synced ?"
        testnetSyncedLabel.stringValue = "synced ?"
        regtestSyncedLabel.stringValue = "synced ?"
        mainnetIncomingPeersLabel.stringValue = "?"
        mainnetOutgoingPeersLabel.stringValue = "?"
        testnetPeersIncomingLabel.stringValue = "?"
        testnetPeersOutgoingLabel.stringValue = "?"
        regtestPeersIncomingLabel.stringValue = "?"
        regtestPeersOutgoingLabel.stringValue = "?"
    }

    func showstandUpAlert(message: String, info: String) {
        DispatchQueue.main.async {
            actionAlert(message: message, info: info) { (response) in
                if response {
                    DispatchQueue.main.async { [unowned vc = self] in
                        vc.standingUp = true
                        vc.timer?.invalidate()
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

    private func getLatestVersion(completion: @escaping ((success: Bool, errorMessage: String?)) -> Void) {
        print("getLatestVersion")
        FetchLatestRelease.get { [unowned vc = self] (dict, error) in
            if dict != nil {
                if let version = dict!["version"] as? String,
                    let binaryName = dict!["macosBinary"] as? String,
                    let prefix = dict!["binaryPrefix"] as? String {
                    vc.newestPrefix = prefix
                    vc.newestVersion = version
                    vc.newestBinaryName = binaryName
                    completion((true, nil))
                } else {
                    completion((false, error))
                }
            } else {
                completion((false, error))
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
                vc.installLightning = installingLightning
                vc.standingUp = standingUp
                vc.upgrading = upgrading
                vc.ignoreExistingBitcoin = ignoreExistingBitcoin
                vc.strapping = strapping
                vc.lightningHostname = lightningHostname
            }

        case "segueToWallets":
            if let vc = segue.destinationController as? WalletsViewController {
                vc.chain = chain
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
