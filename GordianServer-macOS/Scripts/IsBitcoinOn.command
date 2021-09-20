#!/bin/sh

#  IsBitcoinOn.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoin-cli -chain=$CHAIN getblockchaininfo
exit 1
