//
//  RPCWhitelist.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/21/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

public var rpcWhiteList: String {
    return "importdescriptors, getblockcount, abortrescan, listlockunspent, lockunspent, getbestblockhash, getaddressesbylabel, listlabels, decodescript, combinepsbt, utxoupdatepsbt, listaddressgroupings, converttopsbt, getaddressinfo, analyzepsbt, createpsbt, joinpsbts, getmempoolinfo, signrawtransactionwithkey, listwallets, unloadwallet, rescanblockchain, listwalletdir, loadwallet, createwallet, finalizepsbt, walletprocesspsbt, decodepsbt, walletcreatefundedpsbt, fundrawtransaction, uptime, importmulti, getdescriptorinfo, deriveaddresses, getrawtransaction, decoderawtransaction, getnewaddress, gettransaction, signrawtransactionwithwallet, createrawtransaction, getrawchangeaddress, getwalletinfo, getblockchaininfo, getbalance, getunconfirmedbalance, listtransactions, listunspent, bumpfee, importprivkey, abandontransaction, getpeerinfo, getnetworkinfo, getmininginfo, estimatesmartfee, sendrawtransaction, importaddress, signmessagewithprivkey, verifymessage, signmessage, encryptwallet, walletpassphrase, walletlock, walletpassphrasechange, gettxoutsetinfo, help, stop, gettxout, getblockhash"
}
