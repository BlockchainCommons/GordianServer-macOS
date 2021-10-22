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
    var showLog = Bool()
    var refreshing = Bool()
    var ignoreExistingBitcoin = Bool()
    var peerInfo = ""

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
        
    func filterAction() {
        if seeLog {
            spinner.alphaValue = 0
            seeLog = false
            let log = URL(fileURLWithPath: "/Users/\(NSUserName())/.gordian/gordian.log")
            do {
                let text = try String(contentsOf: log, encoding: .utf8)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.consoleOutput.string = text
                }
            } catch {
                simpleAlert(message: "Log does not exist.", info: "We were unable to fetch the log.", buttonLabel: "OK")
            }
            
        } else if peerInfo != "" {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.consoleOutput.string = self.peerInfo
                self.window?.title = "Peer Info"
                self.hideSpinner()
            }
            
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
    
    func hideSpinner() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.alphaValue = 0
            vc.spinnerDescription.stringValue = ""
            vc.spinner.stopAnimation(vc)
        }
    }
    
    func setScene() {
        window?.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.textColor = NSColor.green
        consoleOutput.isEditable = false
        consoleOutput.isSelectable = true
        spinnerDescription.stringValue = ""
    }

}
