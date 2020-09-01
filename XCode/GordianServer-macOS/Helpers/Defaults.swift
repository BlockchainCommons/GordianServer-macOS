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
        guard let path = Bundle.main.path(forResource: SCRIPT.getRPCCredentials.rawValue, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = ["DATADIR":dataDir()]
        task.standardOutput = stdOut
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            if output != "" {
                let conf = output.components(separatedBy: "\n")
                completion((conf, false))
            } else {
                completion((nil, false))
            }
        } else {
            completion((nil, true))
        }
    }
    
    let ud = UserDefaults.standard
    
    func setDefaults(completion: @escaping () -> Void) {
        if ud.object(forKey: "dataDir") == nil {
            ud.set("/Users/\(NSUserName())/Library/Application Support/Bitcoin", forKey: "dataDir")
        }
        
        func setLocals() {
            if ud.object(forKey: "pruned") == nil {
                ud.set(halfOfDevicesFreeSpace() ?? 1000, forKey: "pruned")
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
        return ud.object(forKey:"dataDir") as? String ?? "/Users/\(NSUserName())/Application Support/Bitcoin"
    }
    
    func isPrivate() -> Int {
        return ud.object(forKey: "isPrivate") as? Int ?? 0
    }
    
    func prune() -> Int {
        return ud.object(forKey:"prune") as? Int ?? 0
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
        return ud.object(forKey: "version") as? String ?? "0.20.0rc1"
    }
    
    func existingBinary() -> String {
        return ud.object(forKey: "macosBinary") as? String ?? "bitcoin-\(existingVersion())-osx64.tar.gz"
    }
    
    func existingPrefix() -> String {
        return ud.object(forKey: "binaryPrefix") as? String ?? "bitcoin-\(existingVersion())"
    }
    
    private func halfOfDevicesFreeSpace() -> Int? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        do {
            let dictionary = try FileManager.default.attributesOfFileSystem(forPath: paths.last!)
            if let int64 = dictionary[FileAttributeKey.systemFreeSize] as? Int64 {
                let dbl = Double(int64)
                return Int((dbl / 1049000.0) / 2)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

}

