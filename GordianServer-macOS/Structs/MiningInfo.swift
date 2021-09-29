//
//  MiningInfo.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

public struct MiningInfo: CustomStringConvertible {
    
    let hashrate:String
    
    init(_ dictionary: [String: Any]) {
        self.hashrate = (dictionary["networkhashps"] as? Double ?? 0.0).hashrate
    }
    
    public var description: String {
        return ""
    }
}
