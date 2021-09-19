//
//  ScriptEnum.swift
//  StandUp
//
//  Created by Peter on 31/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

public enum SCRIPT: String {
    case openFile = "OpenFile"
    case removeBitcoin = "RemoveBitcoin"
    case verifyBitcoin = "Verify"
    case checkForBitcoin = "CheckForBitcoinCore"
    case standUp = "StandUp"
    case standDown = "StandDown"
    case updateBTCConf = "UpdateBTCConf"
    case upgradeBitcoin = "UpgradeBitcoin"
    case checkStandUp = "CheckStandUp"
    case checkXcodeSelect = "CheckXCodeSelect"
    case getStrapped = "Strap"
    case launchStrap = "LaunchStrap"
    case isBitcoinOn = "IsBitcoinOn"
    case stopBitcoin = "StopBitcoin"
    case checkForOldHost = "CheckForOldHost"
    case removeOldHost = "RemoveOldHost"
    case rpc = "RPC"
    case deleteWallet = "DeleteWallet"
    case installLightning = "InstallLightning"
    case getLightningHostnames = "GetLightningHostname"
    case isLightningInstalled = "IsLightningInstalled"
    case isLightningRunning = "IsLightningRunning"
    case startLightning = "StartLightning"
    case stopLightning = "StopLightning"
    case getLightningRpcCreds = "GetLightningRpcCreds"
    case writeLog = "WriteLog"
    case getLog = "GetLog"
    case startBitcoin = "StartBitcoin"
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
