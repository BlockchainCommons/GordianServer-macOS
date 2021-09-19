#!/bin/sh

#  StartBitcoin.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/19/21.
#  Copyright © 2021 Peter. All rights reserved.
ulimit -n 188898
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoind -$CHAIN -daemon
exit 1
