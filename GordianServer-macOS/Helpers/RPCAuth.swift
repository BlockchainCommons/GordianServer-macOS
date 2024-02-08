//
//  RPCAuth.swift
//  FullyNoded
//
//  Created by Peter Denton on 1/23/24.
//  Copyright © 2024 Fontaine. All rights reserved.
//

import CryptoKit
import Foundation

class RPCAuth {
 
    private func generateSalt() -> String? {
        // Generates 16 random bytes, return as hex string.
         var bytes = [UInt8](repeating: 0, count: 16)
         let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

         guard result == errSecSuccess else {
             print("Problem generating random bytes")
             return nil
         }
        
        return Data(bytes).hexString
    }

    private func generatePassword() -> String? {
        // Create 32 byte b64 password.
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard result == errSecSuccess else {
            print("Problem generating random bytes")
            return nil
        }
        
        return Data(bytes).urlSafeB64String
    }

    private func passwordToHmac(salt: String, password: String) -> String? {
        if #available(macOS 10.15, *) {
            let key = SymmetricKey(data: Data(salt.utf8))
            let authenticationCode = HMAC<SHA256>.authenticationCode(for: Data(password.utf8), using: key)
            return authenticationCode.compactMap { String(format: "%02x", $0) }.joined()
        } else {
            return nil
        }
    }

    func generateCreds(username: String, password: String?) -> Credentials? {
        guard let salt = generateSalt() else { return nil }
        guard let password = password ?? generatePassword() else { return nil }
        guard let passwordHmac = passwordToHmac(salt: salt, password: password) else { return nil }
        let d: [String:String] = [
            "rpcPassword": password,
            "rpcAuth": "rpcauth=\(username):\(salt)$\(passwordHmac)"
        ]
        return Credentials(d)
    }
}
