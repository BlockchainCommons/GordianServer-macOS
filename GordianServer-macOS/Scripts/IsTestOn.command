#!/bin/sh

#  IsTestOn.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoin-cli -chain=test getblockchaininfo
exit 1
