//
//  Credentials.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 2/8/24.
//  Copyright © 2024 Peter. All rights reserved.
//

import Foundation

public struct Credentials: CustomStringConvertible {
    let rpcAuth:String
    let rpcPassword:String
    
    init(_ dict: [String:String]) {
        rpcAuth = dict["rpcAuth"]!
        rpcPassword = dict["rpcPassword"]!
    }
    
    public var description: String {
        return ""
    }
}
