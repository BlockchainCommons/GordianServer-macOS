//
//  BlockchainInfo.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

public struct BlockchainInfo: CustomStringConvertible {
    let difficulty:Int
    let network:String
    let blockheight:Int
    let size_on_disk:Int
    let progress:String
    let pruned:Bool
    let verificationprogress:Double
    let pruneheight:Int
    let chain:String
    let blocks:Int
    let initialblockdownload:Bool
    
    init(_ dictionary: [String: Any]) {
        network = dictionary["chain"] as? String ?? ""
        blockheight = dictionary["blocks"] as? Int ?? 0
        UserDefaults.standard.set(blockheight, forKey: "blockheight")
        difficulty = Int(dictionary["difficulty"] as! Double)
        size_on_disk = Int(dictionary["size_on_disk"] as! UInt64)
        progress = dictionary["progress"] as? String ?? ""
        pruned = dictionary["pruned"] as? Bool ?? false
        verificationprogress = dictionary["verificationprogress"] as? Double ?? 0.0
        pruneheight = dictionary["pruneheight"] as? Int ?? 0
        chain = dictionary["chain"] as? String ?? ""
        UserDefaults.standard.set(chain, forKey: "chain")
        blocks = dictionary["blocks"] as? Int ?? 0
        initialblockdownload = dictionary["initialblockdownload"] as? Bool ?? false
    }
    
    public var description: String {
        return ""
    }
}
