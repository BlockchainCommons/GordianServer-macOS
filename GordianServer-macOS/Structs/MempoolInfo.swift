//
//  MempoolInfo.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

public struct MempoolInfo: CustomStringConvertible {
    
    /*
     {
         bytes = 1313363;
         loaded = 1;
         maxmempool = 300000000;
         mempoolminfee = "1e-05";
         minrelaytxfee = "1e-05";
         size = 3320;
         "total_fee" = "0.21739883";
         unbroadcastcount = 0;
         usage = 5769104;
     }
     */
    
    let size:Int
    
    init(_ dictionary: [String: Any]) {
        self.size = dictionary["size"] as? Int ?? 0
    }
    
    public var description: String {
        return ""
    }
    
}
