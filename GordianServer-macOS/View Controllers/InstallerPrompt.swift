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
            
            if self.headerText == "Setup Secure Development Environment" {
                self.runScript(script: .launchStrap)
            } else {
                if !self.isHelp {
                    self.doneBlock!(true)
                }
            }
        }
    }
    
    private func runScript(script: SCRIPT) {
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async { [weak self] in
            let resource = script.rawValue
            guard let path = Bundle.main.path(forResource: resource, ofType: "command") else { return }
            let stdOut = Pipe()
            let stdErr = Pipe()
            let task = Process()
            task.launchPath = path
            //task.environment = self?.env
            task.standardOutput = stdOut
            task.standardError = stdErr
            task.launch()
            task.waitUntilExit()
//            let data = stdOut.fileHandleForReading.readDataToEndOfFile()
//            let errData = stdErr.fileHandleForReading.readDataToEndOfFile()
//            var result = ""
//
//            if let output = String(data: data, encoding: .utf8) {
//                #if DEBUG
//                print("output: \(output)")
//                #endif
//                result += output
//            }
//
//            if let errorOutput = String(data: errData, encoding: .utf8) {
//                #if DEBUG
//                print("error: \(errorOutput)")
//                if errorOutput != "" && !errorOutput.contains("not connect to the server") && !errorOutput.contains("block") && !errorOutput.contains("Loading P2P addresses")  {
//                    simpleAlert(message: "Error", info: errorOutput, buttonLabel: "OK")
//                }
//
//                #endif
//                result += errorOutput
//            }
        }
    }
    
}
