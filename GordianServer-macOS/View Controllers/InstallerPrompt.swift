//
//  InstallerPrompt.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/15/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Cocoa

class InstallerPrompt: NSViewController {
    
    var window: NSWindow?
    var isHelp = false
    var text = ""
    var headerText = ""
    var doneBlock: ((Bool) -> Void)?
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var header: NSTextField!
    @IBOutlet weak var buttonOutlet: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.stringValue = text
        header.stringValue = headerText
        
        if isHelp {
            buttonOutlet.title = "OK"
        }
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = ""
    }
    
    @IBAction func installAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.window?.performClose(self)
            if !self.isHelp {
                self.doneBlock!(true)
            }
        }
    }
    
}
