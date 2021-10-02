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
        guard let log = URL(string: "/Users/\(NSUserName())/.gordian/gordian.log") else {
            print("unable to get log")
            return
        }
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(content.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try content.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
