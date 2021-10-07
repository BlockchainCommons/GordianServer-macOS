//
//  Defaults.swift
//  StandUp
//
//  Created by Peter on 23/11/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

class Defaults {
    
    static let shared = Defaults()
    private init() {}
    
    private func getBitcoinConf(completion: @escaping ((conf: [String]?, error: Bool)) -> Void) {
        let path = URL(fileURLWithPath: dataDir + "/bitcoin.conf")
        
        guard let bitcoinConf = try? String(contentsOf: path, encoding: .utf8) else {
            completion((nil, false))
            return
        }
        
        let conf = bitcoinConf.components(separatedBy: "\n")
        completion((conf, false))
    }
    
    let ud = UserDefaults.standard
    
    func setDefaults(completion: @escaping () -> Void) {
        
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
            var onlyNetOnion = false
            var discover = false
            if !error && conf != nil {
                if conf!.count > 0 {
                    for setting in conf! {
                        if setting.contains("=") && !setting.contains("#") {
                            let arr = setting.components(separatedBy: "=")
                            let k = arr[0]
                            let existingValue = arr[1]
                            switch k {
                            case "blocksdir":
                                self.ud.setValue(existingValue, forKey: "blocksDir")
                                
                            case "discover":
                                if existingValue == "0" {
                                    discover = false
                                }
                            case "onlynet":
                                if existingValue == "onion" {
                                    onlyNetOnion = true
                                }
                            case "proxy":
                                if existingValue == "127.0.0.1:19150" {
                                    proxyOn = true
                                }
                                
                            case "listen":
                                if Int(existingValue) == 1 {
                                    listenOn = true
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
                    
                    if proxyOn && listenOn && onlyNetOnion && !discover {
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
        
        if ud.object(forKey: "autoStart") == nil {
            ud.setValue(true, forKey: "autoStart")
        }
    }
    
    var autoRefresh: Bool {
        return ud.object(forKey: "autoRefresh") as? Bool ?? true
    }
    
    var autoStart: Bool {
        return ud.object(forKey: "autoStart") as? Bool ?? true
    }
    
    var dataDir: String {
        // Remove escaping character from path for backwards compatibility
        if ud.object(forKey: "dataDir") as? String == "/Users/\(NSUserName())/Library/Application\\ Support/Bitcoin" {
            let correctPath = "/Users/\(NSUserName())/Library/Application Support/Bitcoin"
            ud.setValue(correctPath, forKey: "dataDir")
            return correctPath
        } else {
            return ud.object(forKey: "dataDir") as? String ?? "/Users/\(NSUserName())/Library/Application Support/Bitcoin"
        }
    }
    
    var blocksDir: String {
        return ud.object(forKey: "blocksDir") as? String ?? dataDir
    }
    
    var isPrivate: Int {
        return ud.object(forKey: "isPrivate") as? Int ?? 0
    }
    
    var prune: Int {
        return ud.object(forKey:"prune") as? Int ?? 1000
    }
    
    var txindex: Int {
        return ud.object(forKey: "txindex") as? Int ?? 0
    }
    
    var walletdisabled: Int {
        return ud.object(forKey: "disablewallet") as? Int ?? 0
    }
    
    var existingVersion: String {
        return ud.object(forKey: "version") as? String ?? "22.0"
    }
    
    var existingBinary: String {
        return ud.object(forKey: "macosBinary") as? String ?? "bitcoin-\(existingVersion)-osx64.tar.gz"
    }
    
    var existingPrefix: String {
        return ud.object(forKey: "binaryPrefix") as? String ?? "bitcoin-\(existingVersion)"
    }

}

