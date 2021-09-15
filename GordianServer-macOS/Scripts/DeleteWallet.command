#!/bin/sh

#  DeleteWallet.command
#  GordianServer-macOS
#
#  Created by Peter on 9/6/20.
#  Copyright © 2020 Peter. All rights reserved.
MAINNET_DEFAULT="$DATADIR"/wallets/"$WALLET"
TESTNET_DEFAULT="$DATADIR"/testnet3/"$WALLET"
TESTNET_POSSIBLE="$DATADIR"/testnet3/wallets/"$WALLET"
SIGNET_POSSIBLE="$DATADIR"/signet/wallets/"$WALLET"

function deleteDefault () {

    if [ -d "$MAINNET_DEFAULT" ]; then
        sudo -u $(whoami) /bin/rm -R "$MAINNET_DEFAULT"
        echo ""$MAINNET_DEFAULT" deleted"
        exit 1
    else
        echo "Error, that wallet does not seem to exist in your data directory, since you are customizing things to custom locations please delete it manually" 1>&2
        exit 64
    fi
    
}

function deleteSignetPossible () {

    if [ -d "$SIGNET_POSSIBLE" ]; then
        sudo -u $(whoami) /bin/rm -R "$SIGNET_POSSIBLE"
        echo ""$SIGNET_POSSIBLE" deleted"
        exit 1
    else
        deleteDefault
    fi
    
}

function deleteTestnetDefault () {

    if [ -d "$TESTNET_DEFAULT" ]; then
        sudo -u $(whoami) /bin/rm -R "$TESTNET_DEFAULT"
        echo ""$TESTNET_DEFAULT" deleted"
        exit 1
    else
        deleteSignetPossible
    fi
    
}

function deleteTestnetPossible () {

    if [ -d "$TESTNET_POSSIBLE" ]; then
        sudo -u $(whoami) /bin/rm -R "$TESTNET_POSSIBLE"
        echo ""$TESTNET_POSSIBLE" deleted"
        exit 1
    else
        deleteTestnetDefault
    fi
    
}

deleteTestnetPossible
