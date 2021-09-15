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
        runScript(script: .openMainnetHiddenService, env: ["CHAIN":UserDefaults.standard.string(forKey: "chain")!], args: []) { _ in }
    }
    
    @IBAction func torAuthenticationClicked(_ sender: Any) {
        runScript(script: .openAuth, env: ["AUTH_DIR":"/usr/local/var/lib/tor/gordian/\(UserDefaults.standard.string(forKey: "chain")!)/authorized_clients/"], args: []) { _ in }
    }
    
    @IBAction func hiddenServiceDirClicked(_ sender: Any) {
        runScript(script: .openAuth, env: ["AUTH_DIR":"/usr/local/var/lib/tor/gordian/"], args: []) { _ in }
    }
    
    @IBAction func torCnfigClicked(_ sender: Any) {
        runScript(script: .openTorrc, env: ["":""], args: []) { _ in }
    }
    
    @IBAction func torLogClicked(_ sender: Any) {
        runScript(script: .showTorLog, env: ["":""], args: []) { _ in }
    }
    
    @IBAction func bitcoinCoreConfClicked(_ sender: Any) {
        let d = Defaults()
        let path = d.dataDir()
        let env = ["DATADIR":path]
        runScript(script: .showBitcoinConf, env: env, args: []) { _ in }
    }
    
    @IBAction func bitcoinCoreLogClicked(_ sender: Any) {
        let d = Defaults()
        let path = d.dataDir()
        let env = ["DATADIR":path]
        runScript(script: .showBitcoinLog, env: env, args: []) { _ in }
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
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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

}

