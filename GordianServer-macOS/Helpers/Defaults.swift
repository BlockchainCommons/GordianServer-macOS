//
//  Defaults.swift
//  StandUp
//
//  Created by Peter on 23/11/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

class Defaults {
    
    private func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let path = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Application Support/Bitcoin/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            print("can not get bitcoin.conf")
            completion((nil, false))
            return
        }
        
        let conf = bitcoinConf.components(separatedBy: "\n")
        completion((conf, false))
    }
    
    let ud = UserDefaults.standard
    
    func setDefaults(completion: @escaping () -> Void) {
        if ud.object(forKey: "dataDir") == nil {
            ud.set("/Users/\(NSUserName())/Library/Application\\ Support/Bitcoin", forKey: "dataDir")
        }
        
        func setLocals() {
            if ud.object(forKey: "prune") == nil {
                ud.set(1000, forKey: "prune")
            }
            if ud.object(forKey: "txindex") == nil {
                ud.set(0, forKey: "txindex")
            }
            if ud.object(forKey: "walletdisabled") == nil {
                ud.set(0, forKey: "walletdisabled")
            }
            completion()
        }
        
        getBitcoinConf { [unowned vc = self] (conf, error) in
            var proxyOn = false
            var listenOn = false
            var bindOn = false
            if !error && conf != nil {
                if conf!.count > 0 {
                    for setting in conf! {
                        if setting.contains("=") && !setting.contains("#") {
                            let arr = setting.components(separatedBy: "=")
                            let k = arr[0]
                            let existingValue = arr[1]
                            switch k {
                            case "proxy":
                                if existingValue == "127.0.0.1:9050" {
                                    proxyOn = true
                                }
                                
                            case "listen":
                                if Int(existingValue) == 1 {
                                    listenOn = true
                                }
                                
                            case "bindaddress":
                                if existingValue == "127.0.0.1" {
                                    bindOn = true
                                }
                                
                            case "testnet", "regtest":
                                if Int(existingValue) == 1 {
                                    // MARK: TODO - throw an error as specifying a network in the conf file is incompatible with Standup
                                }
                                
                            case "prune":
                                vc.ud.set(Int(existingValue), forKey: "prune")
                                if Int(existingValue) == 1 {
                                    vc.ud.set(0, forKey: "txindex")
                                }
                                
                            case "disablewallet":
                                vc.ud.set(Int(existingValue), forKey: "disablewallet")
                                
                            case "txindex":
                                vc.ud.set(Int(existingValue), forKey: "txindex")
                                if Int(existingValue) == 1 {
                                    vc.ud.set(0, forKey: "prune")
                                }
                                
                            default:
                                break
                                
                            }
                        }
                    }
                    
                    if bindOn && proxyOn && listenOn {
                        vc.ud.set(1, forKey: "isPrivate")
                    } else {
                        vc.ud.set(0, forKey: "isPrivate")
                    }
                    setLocals()
                }
                
            } else {
                setLocals()
            }
        }
        
        if ud.object(forKey: "nodeLabel") == nil {
            ud.set("StandUp Node", forKey: "nodeLabel")
        }
    }
    
    func dataDir() -> String {
        return "/Users/\(NSUserName())/Library/Application Support/Bitcoin"
    }
    
    func blocksDir() -> String {
        return ud.object(forKey: "blocksDir") as? String ?? "/Users/\(NSUserName())/Library/Application Support/Bitcoin"
    }
    
    func isPrivate() -> Int {
        return ud.object(forKey: "isPrivate") as? Int ?? 0
    }
    
    func prune() -> Int {
        return ud.object(forKey:"prune") as? Int ?? 1000
    }
    
    func txindex() -> Int {
        return ud.object(forKey: "txindex") as? Int ?? 0
    }
    
    func walletdisabled() -> Int {
        return ud.object(forKey: "disablewallet") as? Int ?? 0
    }
    
    func setDataDir(value: String) {
        ud.set(value, forKey: "dataDir")
    }
    
    func existingVersion() -> String {
        return ud.object(forKey: "version") as? String ?? "22.0"
    }
    
    func existingBinary() -> String {
        return ud.object(forKey: "macosBinary") as? String ?? "bitcoin-\(existingVersion())-osx64.tar.gz"
    }
    
    func existingPrefix() -> String {
        return ud.object(forKey: "binaryPrefix") as? String ?? "bitcoin-\(existingVersion())"
    }

}

