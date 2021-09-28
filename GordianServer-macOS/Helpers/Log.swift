//
//  Log.swift
//  StandUp
//
//  Created by Peter on 20/11/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

class Log {
        
    class func writeToLog(content: String) {
        getLog { existingLog in
            var log = ""
            
            if existingLog != nil {
                log += existingLog!
            }
            
            log += "\n\n\(NSDate())\n\n" + content
            
            let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            
            taskQueue.async {                
                self.runScript(script: .writeLog, env: ["LOG": log], args: []) { _ in }
            }
        }
    }
    
    class func getLog(completion: @escaping (String?) -> Void) {
        runScript(script: .getLog, env: [:], args: []) { log in
            completion((log))
        }
    }
    
    class func runScript(script: SCRIPT, env: [String:String], args: [String], completion: @escaping ((String?)) -> Void) {
        #if DEBUG
        print("script: \(script.stringValue)")
        #endif
        let resource = script.stringValue
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
            completion(result)
        } else {
            completion(nil)
        }
    }
    
}
