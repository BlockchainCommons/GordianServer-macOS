//
//  RPCAuth.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 10/6/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation
import PythonKit

class RPCAuth {
    
    static var rpcAuthPath: URL {
        return URL(string: "file://\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? "")/rpcauth.py")!
    }
    
    static var directory: String {
        return "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? "")/"
    }
    
    class func generateRpcAuth(user: String) -> (rpcauth: String?, rpcpassword: String?) {
        guard let filePath = Bundle.main.url(forResource: "rpcauth", withExtension: "py") else { print("can't get bundle path."); return (nil, nil) }
        
        guard let rpcauthFile = try? String(contentsOf: filePath, encoding: .utf8) else {
            print("can not get rpcauth.py")
            return (nil, nil)
        }
        
        do {
            try rpcauthFile.write(to: rpcAuthPath, atomically: false, encoding: .utf8)
        } catch {
            print("an error happened while creating the file: \(error.localizedDescription)")
        }
        
        print("python version: \(Python.version)")

        let sys = Python.import("sys")
        sys.path.append(directory)
        let rpcAuth = Python.import("rpcauth")
        let response = rpcAuth.main(user)
        return (response[0].description, response[1].description)
    }
}
