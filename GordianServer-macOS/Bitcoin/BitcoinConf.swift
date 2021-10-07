//
//  BitcoinConf.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

class BitcoinConf {
    
    static func bitcoinConf() -> String? {
        let d = Defaults.shared
        let prune = d.prune
        let txindex = d.txindex
        let walletDisabled = d.walletdisabled
        let rpcuser = "GordianServer"
        let rpcauthCreds = RPCAuth.generateRpcAuth(user: "GordianServer")
        
        guard let rpcauth = rpcauthCreds.rpcauth, let rpcpassword = rpcauthCreds.rpcpassword else {
            simpleAlert(message: "Error", info: "Unable to create rpcauth credentials.", buttonLabel: "OK")
            return nil
        }
        
        UserDefaults.standard.setValue(rpcpassword, forKey: "rpcpassword")
        UserDefaults.standard.setValue(rpcuser, forKey: "rpcuser")
        
        return """
        disablewallet=\(walletDisabled)
        server=1
        prune=\(prune)
        txindex=\(txindex)
        dbcache=\(optimumCache)
        maxconnections=20
        maxuploadtarget=500
        fallbackfee=0.00009
        blocksdir=\(d.blocksDir)
        proxy=127.0.0.1:19150
        listen=1
        discover=1
        \(rpcauth)
        rpcwhitelist=\(rpcuser):\(rpcWhiteList)
        [main]
        externalip=\(TorClient.sharedInstance.p2pHostname(chain: "main") ?? "")
        rpcport=8332
        rpcallowip=127.0.0.1
        rpcbind=127.0.0.1
        [test]
        externalip=\(TorClient.sharedInstance.p2pHostname(chain: "test") ?? "")
        rpcport=18332
        rpcallowip=127.0.0.1
        rpcbind=127.0.0.1
        [regtest]
        rpcport=18443
        rpcallowip=127.0.0.1
        rpcbind=127.0.0.1
        [signet]
        rpcport=38332
        rpcallowip=127.0.0.1
        rpcbind=127.0.0.1
        externalip=\(TorClient.sharedInstance.p2pHostname(chain: "signet") ?? "")
        """
    }
    
    static var optimumCache: Int {
        /// Converts devices ram to gb, divides it by two and converts that to mebibytes. That way we use half the RAM for IBD cache as a reasonable default.
        return Int(((Double(ProcessInfo.processInfo.physicalMemory) / 1073741824.0) / 2.0) * 954.0)
    }
}



