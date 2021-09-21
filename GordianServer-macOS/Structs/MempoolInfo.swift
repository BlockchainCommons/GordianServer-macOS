//
//  MempoolInfo.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

public struct MempoolInfo: CustomStringConvertible {
    
    let mempoolCount:Int
    
    init(_ dictionary: [String: Any]) {
        self.mempoolCount = dictionary["mempoolCount"] as? Int ?? 0
    }
    
    public var description: String {
        return ""
    }
    
}
