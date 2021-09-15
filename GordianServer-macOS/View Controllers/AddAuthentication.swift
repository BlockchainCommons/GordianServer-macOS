//
//  AddAuthentication.swift
//  StandUp
//
//  Created by Peter on 03/06/20.
//  Copyright © 2020 Peter. All rights reserved.
//

import Cocoa

class AddAuthentication: NSViewController, NSWindowDelegate {
    
    var window: NSWindow?
    @IBOutlet weak var textInput: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 484, height: 256)
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        var frame = self.view.window!.frame
        let initialSize = NSSize(width: 484, height: 256)
        frame.size = initialSize
        self.view.window?.setFrame(frame, display: true)
        self.view.window?.title = "Tor V3 Authentication"
    }
    
    @IBAction func addAction(_ sender: Any) {
        if textInput.stringValue != "" {
            let descriptor = textInput.stringValue.replacingOccurrences(of: " ", with: "")
            if descriptor.hasPrefix("descriptor:x25519:") {
                DispatchQueue.main.async { [unowned vc = self] in
                    actionAlert(message: "Add Tor V3 authentication key?", info: descriptor) { (response) in
                        if response {
                            vc.authenticate()
                        }
                    }
                }
            } else {
                simpleAlert(message: "Error", info: "Incorrect format, the correct format is:\n\ndescriptor:x25519:<public key here>", buttonLabel: "OK")
            }
        } else {
            simpleAlert(message: "Fill out a public key first", info: "", buttonLabel: "OK")
        }
    }
    
    @IBAction func doNotAskAgainAction(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            let ud = UserDefaults.standard
            ud.set(true, forKey: "doNotAskForAuthAgain")
            vc.window?.performClose(nil)
        }
    }
    
    private func authenticate() {
        let filename = randomString(length: 10)
        let pubkey = self.textInput.stringValue
        runScript(script: .authenticate, env: ["":""], args: [pubkey,filename]) { success in
            if success {
                DispatchQueue.main.async { [unowned vc = self] in
                    simpleAlert(message: "Successfully added auth key", info: "Tor is now restarting.", buttonLabel: "OK")
                    vc.textInput.stringValue = ""
                    vc.textInput.resignFirstResponder()
                }
            } else {
                simpleAlert(message: "Error", info: "error authenticating", buttonLabel: "OK")
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
