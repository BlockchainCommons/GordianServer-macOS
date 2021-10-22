//
//  Installer.swift
//  StandUp
//
//  Created by Peter on 07/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class Installer: NSViewController {
    
    @IBOutlet var consoleOutput: NSTextView!
    
    var window: NSWindow?
    let ud = UserDefaults.standard
    var seeLog = Bool()
    var showLog = Bool()
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
    
    func filterAction() {
        if seeLog {
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
            }
            
        }
    }
    
    func setScene() {
        window?.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.backgroundColor = #colorLiteral(red: 0.1605761051, green: 0.1642630696, blue: 0.1891490221, alpha: 1)
        consoleOutput.textColor = NSColor.green
        consoleOutput.isEditable = false
        consoleOutput.isSelectable = true
    }

}
