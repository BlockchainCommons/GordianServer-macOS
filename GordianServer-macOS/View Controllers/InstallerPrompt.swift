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
    var text = ""
    var headerText = ""
    var doneBlock: ((Bool) -> Void)?
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var header: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.stringValue = text
        header.stringValue = headerText
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = ""
    }
    
    @IBAction func installAction(_ sender: Any) {
        doneBlock!(true)
        
        DispatchQueue.main.async { [unowned vc = self] in
            vc.window?.performClose(nil)
        }
    }
    
}
