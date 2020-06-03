//
//  ScriptEnum.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

public enum SCRIPT: String {
    
    case removeBitcoin = "RemoveBitcoin"
    case torStatus = "TorStatus"
    case getTorHostname = "GetHostname"
    case getRPCCredentials = "GetBitcoinConf"
    case getTorrc = "GetTorrc"
    case checkForTor = "CheckForTor"
    case verifyBitcoin = "Verify"
    case checkForBitcoin = "CheckForBitcoinCore"
    case standUp = "StandUp"
    case startTor = "StartTor"
    case stopTor = "StopTor"
    case authenticate = "Authenticate"
    case standDown = "StandDown"
    case updateBTCConf = "UpdateBTCConf"
    case upgradeBitcoin = "UpgradeBitcoin"
    case showBitcoinLog = "ShowBitcoinCoreLog"
    case showTorLog = "ShowTorLog"
    case checkStandUp = "CheckStandUp"
    case checkHomebrew = "CheckHomebrew"
    case checkXcodeSelect = "CheckXCodeSelect"
    case getStrapped = "Strap"
    case launchStrap = "LaunchStrap"
    case openMainnetHiddenService = "OpenMainnetHiddenService"
    case openTestnetHiddenService = "OpenTestnetHiddenService"
    case openRegtestHiddenService = "OpenRegtestHiddenService"
    case isMainOn = "IsMainOn"
    case isTestOn = "IsTestOn"
    case isRegOn = "IsRegtestOn"
    case startMain = "StartMaind"
    case startRegtest = "StartRegd"
    case startTestd = "StartTestd"
    case stopMain = "StopMain"
    case stopTest = "StopTest"
    case stopReg = "StopReg"
    case refreshMainHS = "RefreshMainHS"
    case refreshTestHS = "RefreshTestHS"
    case refreshRegHS = "RefreshRegHS"
    case removeAuth = "RemoveAuth"
}

public enum BTCCONF: String {
    
    case prune = "prune"
    case txindex = "txindex"
    case mainnet = "mainnet"
    case testnet = "testnet"
    case regtest = "regtest"
    case disablewallet = "disablewallet"
    case datadir = "datadir"
    
}
