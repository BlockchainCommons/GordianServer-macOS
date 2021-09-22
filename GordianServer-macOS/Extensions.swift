//
//  Extensions.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/13/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

extension Double {
    var bitcoinCoreSyncStatus: String {
        if self >= 0.9999 {
            return "100%"
        } else {
            return "\(Int(self*100))%"
        }
    }
    
    var uptime: String {
        return "\(Int(self) / 86400) d \((Int(self) % 86400) / 3600) h"
    }
    
    var hashrate: String {
        let exahashesPerSecond = self / 1000000000000000000.0
        return "\(Int(exahashesPerSecond)) EX/s"
    }    
}

extension Int {
    var size: String {
        return "\(self/1000000000) gb"
    }
    
    var diffString: String {
        return "\(Int(self / 1000000000000)) trillion"
    }
}
