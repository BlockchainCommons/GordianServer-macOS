#!/bin/sh

#  RPC.command
#  GordianServer-macOS
#
#  Created by Peter on 9/3/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoin-cli -datadir=$DATADIR -chain=$CHAIN $COMMAND
exit 1
