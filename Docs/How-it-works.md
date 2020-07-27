# How *Standup* MacOS Works

The application *Standup.app* currently installs, configures, and launches `Tor stable v0.4.3.5` and `Bitcoin-Core v0.20.0`. The app is under development, but as it stands, it will install and configure a pruned *Bitcoin Core* full node, Tor as a service, and a Tor V3 hidden service for each  `rpcport` with native client cookie authentication. 

*Standup* allows the user to set custom settings including `txindex`, `prune`, `walletdisabled`, and `datadir`, which should not interfere with any exisiting `bitcoin.conf` settings. Setting `txindex` to `1` will automatically set `prune` to `0` and vice versa as these settings are mutually exclusive.

⚠️ Tampering with `txindex` and `prune` can have major consequences. If you already have a fully indexed blockchain synced on your machine and you enable pruning, you will lose your fully indexed blockchain! Please use the pruning setting only if you are absolutely sure you want your node to be pruned. If you install *Bitcoin Core* on a machine that already has a fully indexed blockchain it *will not* interfere with it unless you explicitly enable pruning. *Standup* does however enable pruning by default if no exisiting *Bitcoin Core* instance is found on your machine.

Finally, it offers a simple `go private` option that closes off your node to the clearnet, only accepting connections over Tor. This setting is by default *disabled* in order to keep your initial block download at a reasonable pace.

There are three hidden services setup, one for each `rpcport`. They can be found at:

- `/usr/local/var/lib/tor/standup/main`
- `/usr/local/var/lib/tor/standup/test`
- `/usr/local/var/lib/tor/standup/reg`

This allows users to remotely connect to each network independently. The user may refresh their hidden service at the push of a button by tapping the `refresh` button which is displayed alongside the *Quick Connect QR Code*.

*Standup* will minimally interfere with an existing node, the only thing it will check for is that `rpcusername` and `rpcpassword` exist in the `bitcoin.conf`, if they do not exist *Standup* will add them. *Standup* checks for an exisiting `bitcoin.conf` in the default data directory which on MacOS is `~/Library/Application Support/Bitcoin`.

⚠️ If you are using a custom `datadir` *you must specify that in Standup's settings*!

⚠️ *Standup* is not compatible with a `bitcoin.conf` that specifies a network! 

If you have `testnet=1`, `testnet=0`, `regtest=1`, `regtest=0` in your `bitcoin.conf` you will get an error in *Standup* about a `conflicting bitcoin.conf` which needs to be resolved before *Standup* will function properly. This is because we allow multiple networks to run simultaneously, which is achieved by starting/stopping *Bitcoin Core* via `bitcoind -chain=test` whereby we specify the network as a command line argument. This is incomaptible with a `bitcoin.conf` that specifies a network. 


## Bitcoin.conf File

The default `bitcoin.conf` StandUp.app will create is (if one does not already exist):

```
walletdisabled=0
rpcuser=arandomstring
rpcpassword=astrongrandompassword
server=1
prune=1
txindex=0
#bindaddress=127.0.0.1
#proxy=127.0.0.1:9050
#listen=1
#debug=tor
[main]
rpcport=8332
[test]
rpcport=18332
[regtest]
rpcport=18443
```

If there is an exisiting `bitcoin.conf` in your `datadir` then *Standup.app* will simply check for and add `rpccredentials` if they are missing. 

We comment out the following settings so that your node will accept connections on the clearnet and Tor in order to keep your initial block download as speedy as possible:
```
#bindaddress=127.0.0.1
#proxy=127.0.0.1:9050
#listen=1
#debug=tor
```

When you enable the `Go private` feature in settings the above settings are uncommented out (or added), your node will then *only* be reachable over Tor.
