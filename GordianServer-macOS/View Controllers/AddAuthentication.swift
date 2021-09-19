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
        let pubkey = self.textInput.stringValue.data(using: .utf8)
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        let path = "\(TorClient.sharedInstance.torPath())/host/bitcoin/\(chain)/authorized_clients/"
        
        do {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: true,
                                                    attributes: [FileAttributeKey.posixPermissions: 0o700])
        } catch {
            print("Directory previously created.")
        }
        
        FileManager.default.createFile(atPath: "\(path)\(filename).auth", contents: pubkey, attributes: [FileAttributeKey.posixPermissions: 0o700])
        
        guard let data = FileManager.default.contents(atPath: "\(path)\(filename).auth"), let retrievedPubkey = String(data: data, encoding: .utf8) else { return }
        
        if retrievedPubkey == self.textInput.stringValue {
            simpleAlert(message: "Authentication added ✓", info: "\(self.textInput.stringValue) was saved to \("\(path)\(filename).auth")", buttonLabel: "OK")
        }
    }
    
}
