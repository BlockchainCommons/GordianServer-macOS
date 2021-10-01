//
//  AppDelegate.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    public var isKilling = false
    
    @IBAction func connectLocalFNAction(_ sender: Any) {
        let chain = UserDefaults.standard.string(forKey: "chain")
        var port = ""
        switch chain {
        case "main":
            port = "8332"
        case "test":
            port = "18332"
        case "signet":
            port = "38332"
        case "regtest":
            port = "18443"
        default:
            break
        }
        
        guard let rpcuser = UserDefaults.standard.object(forKey: "rpcuser") as? String,
              let rpcpassword = UserDefaults.standard.object(forKey: "rpcpassword") as? String else {
            simpleAlert(message: "Missing credentials...", info: "Connecting locally to Fully Noded requires rpc credentials.", buttonLabel: "OK")
            return
        }
        
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: "/Applications")
            var exists = false
            
            for (i, filePath) in filePaths.enumerated() {
                if filePath == "FullyNoded.app" {
                    exists = true
                }
                if i + 1 == filePaths.count {
                    if exists {
                        DispatchQueue.main.async {
                            guard let url = URL(string: "btcrpc://\(rpcuser):\(rpcpassword)@127.0.0.1:\(port)/?Gordian%20Server") else { return }
                            NSWorkspace.shared.open(url)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Is Fully Noded installed?"
                            alert.informativeText = "We can't see Fully Noded in your ~/Applications directory, please add FullyNoded.app to your applications directory and try again to automatically connect it to Gordian Server. Or click Install. Once installed you try this action again."
                            alert.addButton(withTitle: "Install Fully Noded")
                            alert.addButton(withTitle: "Cancel")
                            alert.alertStyle = .informational
                            let modalResponse = alert.runModal()
                            if (modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {
                                DispatchQueue.main.async {
                                    guard let url = URL(string: "https://apps.apple.com/us/app/fully-noded-desktop/id1530816100?mt=12") else { return }
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            simpleAlert(message: "There was an issue accessing your installed applications.", info: "\(error.localizedDescription)\n\nPlease let us know about this bug.", buttonLabel: "OK")
        }
    }
    
    @IBAction func installHomebrewAction(_ sender: Any) {
        runScript(script: .installHomebrew, env: ["":""], args: []) { _ in }
    }
    
    @IBAction func installGpgAction(_ sender: Any) {
        DispatchQueue.main.async {
            guard let url = URL(string: "https://gpgtools.org") else { return }
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func gordianSeedToolClicked(_ sender: Any) {
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: "/Applications")
            var exists = false
            
            for (i, filePath) in filePaths.enumerated() {
                if filePath == "Gordian Seed Tool.app" {
                    exists = true
                }
                if i + 1 == filePaths.count {
                    if exists {
                        runScript(script: .openFile, env: ["FILE":"/Applications/Gordian Seed Tool.app"], args: []) { _ in }
                    } else {
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://apps.apple.com/us/app/gordian-seed-tool/id1545088229") else { return }
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        } catch {
            simpleAlert(message: "There was an issue accessing your installed applications.", info: "\(error.localizedDescription)\n\nPlease let us know about this bug.", buttonLabel: "OK")
        }
    }
    
    
    @IBAction func gordianQRToolClicked(_ sender: Any) {
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: "/Applications")
            var exists = false
            
            for (i, filePath) in filePaths.enumerated() {
                if filePath == "Gordian QR Tool.app" {
                    exists = true
                }
                if i + 1 == filePaths.count {
                    if exists {
                        runScript(script: .openFile, env: ["FILE":"/Applications/Gordian QR Tool.app"], args: []) { _ in }
                    } else {
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://apps.apple.com/us/app/gordian-qr-tool/id1506851070") else { return }
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        } catch {
            simpleAlert(message: "There was an issue accessing your installed applications.", info: "\(error.localizedDescription)\n\nPlease let us know about this bug.", buttonLabel: "OK")
        }
    }
    
    @IBAction func fullyNodedClicked(_ sender: Any) {
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: "/Applications")
            var exists = false
            
            for (i, filePath) in filePaths.enumerated() {
                print("file path: \(filePath)")
                if filePath == "FullyNoded.app" {
                    exists = true
                }
                if i + 1 == filePaths.count {
                    if exists {
                        runScript(script: .openFile, env: ["FILE":"/Applications/FullyNoded.app"], args: []) { _ in }
                    } else {
                        DispatchQueue.main.async {
                            guard let url = URL(string: "https://apps.apple.com/us/app/fully-noded-desktop/id1530816100?mt=12") else { return }
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        } catch {
            simpleAlert(message: "There was an issue accessing your installed applications.", info: "\(error.localizedDescription)\n\nPlease let us know about this bug.", buttonLabel: "OK")
        }
    }
    
    @IBAction func newWindowClicked(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let settingsController:NSWindowController = storyboard.instantiateController(withIdentifier: "MainWindow") as! NSWindowController
        settingsController.showWindow(settingsController)
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if !isKilling {
            let alert = NSAlert()
            alert.messageText = "Quit Bitcoin Core?"
            alert.informativeText = "Quitting the app does not stop Bitcoin Core automatically. Tor automatically quits so your node will not be remotely reachable.\n\nIf you opt to quit Bitcoin Core only the active network will be stopped, if you want to close all networks do that with the Stop button before quitting the app."
            alert.addButton(withTitle: "Quit Bitcoin Core")
            alert.addButton(withTitle: "Leave Running")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            let modalResponse = alert.runModal()
            if (modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {
                self.quitBitcoin()
                return .terminateLater
            } else if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
                TorClient.sharedInstance.resign()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    NSApplication.shared.reply(toApplicationShouldTerminate: true)
                }
                return .terminateLater
            } else {
                return .terminateCancel
            }
        } else {
            return .terminateNow
        }
    }
    
    func quitBitcoin() {
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        runScript(script: .stopBitcoin, env: ["CHAIN":chain, "PREFIX":Defaults.shared.existingPrefix], args: []) { _ in
            TorClient.sharedInstance.resign()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                NSApplication.shared.reply(toApplicationShouldTerminate: true)
            }
        }
    }
    
    @IBAction func gordianLogClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"/Users/\(NSUserName())/.gordian/gordian.log"], args: []) { _ in }
    }
    
    @IBAction func installStrapClicked(_ sender: Any) {
        var myWindow: NSWindow? = nil
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let installPrompt = storyboard.instantiateController(withIdentifier: "InstallerPrompt") as! InstallerPrompt
        installPrompt.headerText = "Setup Secure Development Environment"
        installPrompt.isHelp = false
        installPrompt.text = "This will run a script to setup a minimal macOS development system and also configures your Macintosh with enhanced security settings. To read more about it please visit https://github.com/MikeMcQuaid/strap"
        myWindow = NSWindow(contentViewController: installPrompt)
        NSApp.activate(ignoringOtherApps: true)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
    }
    

    @IBAction func settingsClicked(_ sender: Any) {
        var myWindow: NSWindow? = nil
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let settings = storyboard.instantiateController(withIdentifier: "Settings") as! Settings
        myWindow = NSWindow(contentViewController: settings)
        NSApp.activate(ignoringOtherApps: true)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
    }
    
    @IBAction func walletsClicked(_ sender: Any) {
        var myWindow: NSWindow? = nil
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let wallets = storyboard.instantiateController(withIdentifier: "Wallets") as! WalletsViewController
        myWindow = NSWindow(contentViewController: wallets)
        NSApp.activate(ignoringOtherApps: true)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
    }
    
    @IBAction func torHostClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(UserDefaults.standard.string(forKey: "chain")!)/hostname"], args: []) { _ in }
    }
    
    @IBAction func torAuthenticationClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(UserDefaults.standard.string(forKey: "chain")!)/authorized_clients/"], args: []) { _ in }
    }
    
    @IBAction func hiddenServiceDirClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(UserDefaults.standard.string(forKey: "chain")!)"], args: []) { _ in }
    }
    
    @IBAction func torCnfigClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"/Users/\(NSUserName())/.torrc"], args: []) { _ in }
    }
    
    @IBAction func torLogClicked(_ sender: Any) {
        runScript(script: .openFile, env: ["FILE":"/Users/\(NSUserName())/.gordian/tor/notices.log"], args: []) { _ in }
    }
    
    @IBAction func bitcoinCoreConfClicked(_ sender: Any) {
        let d = Defaults.shared
        let path = d.dataDir
        let env = ["FILE":"\(path)/bitcoin.conf"]
        runScript(script: .openFile, env: env, args: []) { _ in }
    }
    
    @IBAction func bitcoinCoreLogClicked(_ sender: Any) {
        let d = Defaults.shared
        let path = d.dataDir
        
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        
        switch chain {
        case "main":
            let env = ["FILE":"\(path)/debug.log"]
            runScript(script: .openFile, env: env, args: []) { _ in }
        case "test":
            let env = ["FILE":"\(path)/testnet3/debug.log"]
            runScript(script: .openFile, env: env, args: []) { _ in }
        case "regtest":
            let env = ["FILE":"\(path)/regtest/debug.log"]
            runScript(script: .openFile, env: env, args: []) { _ in }
        case "signet":
            let env = ["FILE":"\(path)/signet/debug.log"]
            runScript(script: .openFile, env: env, args: []) { _ in }
        default:
            break
        }        
    }
    
    @IBAction func quickConnectClicked(_ sender: Any) {
        var myWindow: NSWindow? = nil
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let quickconnect = storyboard.instantiateController(withIdentifier: "QuickConnect") as! QRDisplayer
        myWindow = NSWindow(contentViewController: quickconnect)
        NSApp.activate(ignoringOtherApps: true)
        myWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: myWindow)
        vc.showWindow(self)
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let mainConsole = storyboard.instantiateController(withIdentifier: "Console") as! ViewController
        mainConsole.autoRefreshTimer?.invalidate()
        mainConsole.autoRefreshTimer = nil
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
//        let storyboard = NSStoryboard(name: "Main", bundle: nil)
//        let mainConsole = storyboard.instantiateController(withIdentifier: "Console") as! ViewController
//        mainConsole.setAutoRefreshTimer()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func runScript(script: SCRIPT, env: [String:String], args: [String], completion: @escaping ((Bool)) -> Void) {
        #if DEBUG
        print("script: \(script.stringValue)")
        #endif
        let resource = script.stringValue
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

}

