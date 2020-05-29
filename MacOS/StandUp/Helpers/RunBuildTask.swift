//
//  RunBuildTask.swift
//  StandUp
//
//  Created by Peter on 13/11/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation
import Cocoa

class RunBuildTask {
    
    var isRunning = false
    var buildTask:Process!
    var fileHandle:FileHandle!
    var args = [String]()
    var env = [String:String]()
    var stringToReturn = ""
    var terminate = Bool()
    var errorBool = Bool()
    var errorDescription = ""
    var exitStrings = [String]()
    var textView = NSTextView()
    var showLog = Bool()
    var stdOut = Pipe()
    var stdErr = Pipe()
    
    func runScript(script: SCRIPT, completion: @escaping () -> Void) {
        
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let resource = script.rawValue
        
        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: resource, ofType: "command") else {
                print("Unable to locate \(resource).command")
                return
            }
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = self.args
            self.buildTask.environment = self.env
            self.buildTask.standardOutput = self.stdOut
            self.buildTask.standardError = self.stdErr
            
            self.buildTask.terminationHandler = { task in
                print("task did terminate")
                self.isRunning = false
                self.errorBool = false
                self.stdErr.fileHandleForReading.closeFile()
                self.stdOut.fileHandleForReading.closeFile()
                do {
                    if #available(OSX 10.15, *) {
                        if self.fileHandle != nil {
                            try self.fileHandle.close()
                            print("file closed")
                        }
                    } else {
                        //handle older version here
                    }
                } catch {
                    print("failed closing file")
                }
                
                completion()
                
            }
            
            self.captureStandardOutputAndRouteToTextView(task: self.buildTask, script: script, textView: self.textView, completion: completion)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    func captureStandardOutputAndRouteToTextView(task: Process, script: SCRIPT, textView: NSTextView, completion: @escaping () -> Void) {
        
        let handler = { [unowned vc = self] (file: FileHandle!) -> Void in
            
            vc.fileHandle = file
            let data = vc.fileHandle.availableData
            
            if vc.isRunning {
                
                guard let output = String(data: data, encoding: .utf8) else {
                    vc.errorBool = true
                    vc.errorDescription = "failed to parse data into string"
                    completion()
                    return
                }
                
                vc.stringToReturn += output as String
                
                if vc.showLog {
                    
                    DispatchQueue.main.async {
                        let prevOutput = vc.textView.string
                        let nextOutput = prevOutput + (output as String)
                        vc.textView.string = nextOutput
                    }
                    
                }
                
                var exitNow = false
                
                for str in vc.exitStrings {
                    
                    if (output as String).contains(str) {
                        
                        exitNow = true
                        print("exitnow")
                        
                    }
                    
                }
                
                if exitNow && vc.isRunning {
                    
                    if task.isRunning {
                        
                        task.terminate()
                        print("terminate")
                        
                    }
                    
                } else {
                    
                    if vc.isRunning {
                        
                        DispatchQueue.main.async { [unowned vc = self] in
                            vc.textView.scrollToEndOfDocument(self)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        stdErr.fileHandleForReading.readabilityHandler = handler
        stdOut.fileHandleForReading.readabilityHandler = handler
        
    }
    
}
