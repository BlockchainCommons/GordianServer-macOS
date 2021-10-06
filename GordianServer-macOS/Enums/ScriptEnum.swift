//
//  ScriptEnum.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

public enum SCRIPT: String {
    case hasBitcoinShutdownCompleted
    case isBitcoindRunning
    case didBitcoindStart
    case installHomebrew
    case installXcode
    case openFile
    case removeBitcoin
    case verifyBitcoin
    case checkForBitcoin
    case standUp
    case standDown
    case updateBTCConf
    case upgradeBitcoin
    case checkForGordian
    case checkXcodeSelect
    case getStrapped
    case launchStrap
    case isBitcoinOn
    case stopBitcoin
    case checkForOldHost
    case removeOldHost
    case rpc
    case deleteWallet
    case installLightning
    case getLightningHostnames
    case isLightningInstalled
    case isLightningRunning
    case startLightning
    case stopLightning
    case getLightningRpcCreds
    case startBitcoin
    
    var stringValue:String {
        switch self {
        case .hasBitcoinShutdownCompleted, .isBitcoindRunning, .didBitcoindStart:
            return "IsProcessRunning"
        case .installHomebrew:
            return "LaunchBrewInstall"
        case .installXcode:
            return "LaunchXcodeInstall"
        case .openFile:
            return "OpenFile"
        case .removeBitcoin:
            return "RemoveBitcoin"
        case .verifyBitcoin:
            return "Verify"
        case .checkForBitcoin:
            return "CheckForBitcoinCore"
        case .standUp:
            return "StandUp"
        case .standDown:
            return "StandDown"
        case .updateBTCConf:
            return "UpdateBTCConf"
        case .upgradeBitcoin:
            return "UpgradeBitcoin"
        case .checkForGordian:
            return "CheckStandUp"
        case .checkXcodeSelect:
            return "CheckXCodeSelect"
        case .getStrapped:
            return "Strap"
        case .launchStrap:
            return "LaunchStrap"
        case .isBitcoinOn:
            return "IsBitcoinOn"
        case .stopBitcoin:
            return "StopBitcoin"
        case .checkForOldHost:
            return "CheckForOldHost"
        case .removeOldHost:
            return "RemoveOldHost"
        case .rpc:
            return "RPC"
        case .deleteWallet:
            return "DeleteWallet"
        case .installLightning:
            return "InstallLightning"
        case .getLightningHostnames:
            return "GetLightningHostname"
        case .isLightningInstalled:
            return "IsLightningInstalled"
        case .isLightningRunning:
            return "IsLightningRunning"
        case .startLightning:
            return "StartLightning"
        case .stopLightning:
            return "StopLightning"
        case .getLightningRpcCreds:
            return "GetLightningRpcCreds"
        case .startBitcoin:
            return "StartBitcoin"
        }
    }
}

public enum BTCCONF: String {
    case prune = "prune"
    case txindex = "txindex"
    case mainnet = "mainnet"
    case testnet = "testnet"
    case regtest = "regtest"
    case disablewallet = "disablewallet"
    case datadir = "datadir"
    case blocksdir = "blocksdir"
}
