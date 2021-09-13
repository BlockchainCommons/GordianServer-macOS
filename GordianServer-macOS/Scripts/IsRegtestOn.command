#!/bin/sh

#  IsRegtestOn.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.standup/BitcoinCore/$PREFIX/bin/bitcoin-cli -chain=regtest getblockchaininfo
exit 1
