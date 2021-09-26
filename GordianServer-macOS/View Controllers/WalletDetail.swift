//
//  WalletDetail.swift
//  GordianServer-macOS
//
//  Created by Peter on 9/6/20.
//  Copyright © 2020 Peter. All rights reserved.
//

import Cocoa

class WalletDetail: NSViewController {
    
    var env = [String:String]()
    var d = Defaults()
    var name = ""
    var window: NSWindow?

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var amountLabel: NSTextField!
    @IBOutlet weak var loadOutlet: NSButton!
    @IBOutlet weak var unloadOutlet: NSButton!
    @IBOutlet weak var showBalanceOutlet: NSButton!
    @IBOutlet weak var deleteOutlet: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.stringValue = name
        amountLabel.stringValue = ""
        loadOutlet.isEnabled = false
        unloadOutlet.isEnabled = false
        showBalanceOutlet.isEnabled = false
        deleteOutlet.isEnabled = true
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = name
    }
    
    func setEnv() {
        env = ["BINARY_NAME":d.existingBinary,"VERSION":d.existingPrefix,"PREFIX":d.existingPrefix,"DATADIR":d.dataDir, "WALLET":name]
        #if DEBUG
        print("env = \(env)")
        #endif
    }
    
    @IBAction func loadAction(_ sender: Any) {
    }
    
    @IBAction func unloadAction(_ sender: Any) {
    }
    
    @IBAction func showBalanceAction(_ sender: Any) {
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if name != "Default wallet" {
            destructiveActionAlert(message: "⚠️ Delete wallet?", info: "Are you absolutely sure? It will be gone FOREVER! You will never get access to it again. You really should never delete a wallet as there is no benefit, only potential loss.\n\nTapping \"Yes\" will permanently and immediately delete this wallet, it will *not* go to the trashcan, it will *not* be recoverable!") { [weak self] (deleteNow) in
                if deleteNow {
                    self?.deleteWallet()
                }
            }
        } else {
            simpleAlert(message: "Action not permitted", info: "Sorry, you can not delete the default wallet, you need to do that manually", buttonLabel: "OK")
        }
        
    }
    
    private func deleteWallet() {
        setEnv()
        runScript(script: .deleteWallet, env: env, args: []) { (result) in
            if result {
                simpleAlert(message: "Wallet deleted ✓", info: "", buttonLabel: "OK")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .reloadWallets, object: nil, userInfo: nil)
                }
            }
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
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = env
        task.arguments = args
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errorData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var errorMessage = ""
        if let errorOutput = String(data: errorData, encoding: .utf8) {
            if errorOutput != "" {
                errorMessage += errorOutput
                simpleAlert(message: "Error", info: errorMessage, buttonLabel: "OK")
                completion((false))
            }
        }
        
        if let _ = String(data: data, encoding: .utf8) {
            completion((true))
        }
    }
}
