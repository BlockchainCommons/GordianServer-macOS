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
    
    @IBAction func cancelAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.window?.performClose(nil)
        }
    }
    
    @IBAction func helpAction(_ sender: Any) {
        DispatchQueue.main.async {
            guard let url = URL(string: "https://community.torproject.org/onion-services/advanced/client-auth/") else { return }
            NSWorkspace.shared.open(url)
        }
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
    
    private func authenticate() {
        let filename = randomString(length: 10)
        let pubkey = self.textInput.stringValue.data(using: .utf8)
        let chain = UserDefaults.standard.string(forKey: "chain") ?? "main"
        let path = "\(TorClient.sharedInstance.hiddenServicePath)/bitcoin/rpc/\(chain)/authorized_clients/"
        
        do {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: true,
                                                    attributes: [FileAttributeKey.posixPermissions: 0o700])
        } catch {
            print("Directory previously created.")
        }
        
        FileManager.default.createFile(atPath: "\(path)\(filename).auth", contents: pubkey, attributes: [FileAttributeKey.posixPermissions: 0o700])
        
        guard let data = FileManager.default.contents(atPath: "\(path)\(filename).auth"), let retrievedPubkey = String(data: data, encoding: .utf8) else {
            simpleAlert(message: "Auth key not added!", info: "Something went wrong and your auth key was not saved. Please reach out and let us know about this bug.", buttonLabel: "OK")
            return
        }
        
        if retrievedPubkey == self.textInput.stringValue {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .authAdded, object: nil, userInfo: nil)
                let alert = NSAlert()
                alert.messageText = "Authentication added ✓"
                alert.informativeText = "\(self.textInput.stringValue) was saved to \("\(path)\(filename).auth")"
                alert.addButton(withTitle: "Add more")
                alert.addButton(withTitle: "Done")
                alert.alertStyle = .informational
                let modalResponse = alert.runModal()
                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.textInput.stringValue = ""
                    }
                }
                
                if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        TorClient.sharedInstance.resign()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            TorClient.sharedInstance.start(delegate: nil)
                            self.window?.performClose(nil)
                        }
                    }
                }
            }
        } else {
            simpleAlert(message: "Auth key error.", info: "Something went wrong and your auth key was not saved correctly. Please reach out and let us know about this bug.", buttonLabel: "OK")
        }
    }
    
}
