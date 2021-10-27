# How GordianServer-macOS Works

The application *GordianServer.app* uses Bitcoin Standup to install, configure, and launch `Tor stable v0.4.4.6` and `Bitcoin-Core v22.0`. The app is under development, but as it stands, it will install and configure a pruned *Bitcoin Core* full node, Tor as a service, and a Tor V3 hidden service for each  `rpcport` with native client cookie authentication. 

*GordianServer-macOS* allows the user to set custom settings including a prune value, `txindex`, `walletdisabled`, and `datadir`, which should not interfere with any exisiting `bitcoin.conf` settings. Selecting `txindex` will automatically set `prune` to `0` and vice versa, as these settings are mutually exclusive.

⚠️ Tampering with `txindex` and `prune` can have major consequences. If you already have a fully indexed blockchain synced on your machine and you enable pruning, you will lose your fully indexed blockchain! Please use the pruning setting only if you are absolutely sure you want your node to be pruned. If you install *Bitcoin Core* on a machine that already has a fully indexed blockchain it *will not* interfere with it unless you explicitly enable pruning. *GordianServer-macOS* does however enable pruning by default, set to 1000mb, if no exisiting *Bitcoin Core* instance is found on your machine.

Finally, *GordianServer-macOS* offers a simple `go private` option that closes off your node to the clearnet, only accepting connections over Tor. This setting is by default *disabled* in order to keep your initial block download at a reasonable pace.

There are four hidden services setup, one for each `rpcport`. They can be found at:

- `~/.gordian/tor/host/bitcoin/rpc/main`
- `~/.gordian/tor/host/bitcoin/rpc/test`
- `~/.gordian/tor/host/bitcoin/rpc/regtest`
- `~/.gordian/tor/host/bitcoin/rpc/signet`

This allows users to remotely connect to each network independently. The user may refresh their hidden service at the push of a button by tapping the `refresh` button in "Settings".

*GordianServer-macOS* will minimally interfere with an existing node, the only thing it will check for is that `rpcusername` and `rpcpassword` exist in the `bitcoin.conf`, if they do not exist *GordianServer-macOS* will add them. *GordianServer-macOS* checks for an exisiting `bitcoin.conf` in the default data directory which on macOS is `~/Library/Application\Support/Bitcoin`.

⚠️ If you are using a custom `datadir` *you must specify that in GordianServer-macOS settings*!

⚠️ *GordianServer-macOS* is not compatible with a `bitcoin.conf` that specifies a network! 

If you have `testnet=1`, `testnet=0`, `regtest=1`, `regtest=0` in your `bitcoin.conf` you will get an error in *GordianServer-macOS* about a `conflicting bitcoin.conf` which needs to be resolved before *GordianServer-macOS* will function properly. This is because we allow multiple networks to run simultaneously, which is achieved by starting/stopping *Bitcoin Core* via `bitcoind -chain=test` whereby we specify the network as a command line argument. This is incomaptible with a `bitcoin.conf` that specifies a network. 

## Bitcoin.conf File

The default `bitcoin.conf` GordianServer-macOS.app will create is (if one does not already exist):

```
disablewallet=0
rpcuser=arandomstring
rpcpassword=astrongrandompass
server=1
prune=1000
txindex=0
dbcache=7632
maxconnections=20
maxuploadtarget=500
fallbackfee=0.00009
blocksdir=/Users/your-account/Library/Application Support/Bitcoin
proxy=127.0.0.1:19150
listen=1
discover=1
[main]
externalip=onionaddress
rpcport=8332
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
rpcwhitelist=t11Vp1XIk0:importdescriptors, getblockcount, abortrescan, listlockunspent, lockunspent, getbestblockhash, getaddressesbylabel, listlabels, decodescript, combinepsbt, utxoupdatepsbt, listaddressgroupings, converttopsbt, getaddressinfo, analyzepsbt, createpsbt, joinpsbts, getmempoolinfo, signrawtransactionwithkey, listwallets, unloadwallet, rescanblockchain, listwalletdir, loadwallet, createwallet, finalizepsbt, walletprocesspsbt, decodepsbt, walletcreatefundedpsbt, fundrawtransaction, uptime, importmulti, getdescriptorinfo, deriveaddresses, getrawtransaction, decoderawtransaction, getnewaddress, gettransaction, signrawtransactionwithwallet, createrawtransaction, getrawchangeaddress, getwalletinfo, getblockchaininfo, getbalance, getunconfirmedbalance, listtransactions, listunspent, bumpfee, importprivkey, abandontransaction, getpeerinfo, getnetworkinfo, getmininginfo, estimatesmartfee, sendrawtransaction, importaddress, signmessagewithprivkey, verifymessage, signmessage, encryptwallet, walletpassphrase, walletlock, walletpassphrasechange, gettxoutsetinfo, help, stop, gettxout, getblockhash
[test]
externalip=onionaddress
rpcport=18332
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
[regtest]
rpcport=18443
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
[signet]
externalip=onionaddress
rpcport=38332
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
```

If there is an exisiting `bitcoin.conf` in your `datadir` then *GordianServer-macOS.app* will simply check for and add `rpccredentials` if they are missing. 

We comment out the following settings so that your node will accept connections on the clearnet and Tor in order to keep your initial block download as speedy as possible:
```
#bindaddress=127.0.0.1
#proxy=127.0.0.1:9050
#listen=1
#debug=tor
```

When you enable the `Go private` feature in settings the above settings are uncommented out (or added), your node will then *only* be reachable over Tor.
