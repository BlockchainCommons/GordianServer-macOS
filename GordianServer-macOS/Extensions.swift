//
//  Extensions.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/13/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
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
        return "\((Double(self)/1000000000.0).rounded(toPlaces: 1)) gb"
    }
    
    var diffString: String {
        return "\(Int(self / 1000000000000)) trillion"
    }
    
    var withCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension Data {
    /// A hexadecimal string representation of the bytes.
    var hexString: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
        
    }
    
    var urlSafeB64String: String {
        return self.base64EncodedString().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "+", with: "-")
    }
}
