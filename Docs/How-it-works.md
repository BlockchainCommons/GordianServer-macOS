# How *Bitcoin-Standup* MacOS Works

The application *Bitcoin Standup.app* currently installs, configures, and launches `tor stable v0.4.2.5` and `bitcoin-core v0.19.0.1`. The app is under development, but as it stands will install and configure a Bitcoin Core full node, Tor as a service, and a Tor V3 hidden service controlling each  `rpcport` with native client cookie authentication. 

*Bitcoin-Standup* allows the user to set custom settings including `txindex`, `prune`, `walletdisabled`, `testnet`, `mainnet`, `datadir`, which should not interfere with any exisiting `bitcoin.conf` settings. Finally, it offers a simple `go private` option that closes off your node to the clearnet, only accepting connections over Tor. The user may refresh their hidden service at the push of a button.

## Bitcoin.conf File

The default `bitcoin.conf` StandUp.app will create is:

```
testnet=1
walletdisabled=0
rpcuser=arandomstring
rpcpassword=astrongrandompassword
server=1
prune=0
txindex=1
rpcallowip=127.0.0.1
bindaddress=127.0.0.1
proxy=127.0.0.1:9050
listen=1
debug=tor
[main]
rpcport=8332
[test]
rpcport=18332
[regtest]
rpcport=18443
```

If there is an exisiting `bitcoin.conf` in your `datadir` then *Bitcoin Standup.app* will simply check for and add `rpccredentials` if they are missing. 

The app currently relies on initial installation of [Strap.sh](https://github.com/MikeMcQuaid/strap/) to install basic development tools before installing `tor` and `bitcoin-qt`. This tool also does some basic hardening of your Macintosh including turning on FileVault (the full-disk encryption services offered in macOS), turning on your Mac firewall, and turning off Java. Future versions of *Bitcoin Standup* will integrate *Strap.sh* features directly to offer additional macOS hardening configuration options.