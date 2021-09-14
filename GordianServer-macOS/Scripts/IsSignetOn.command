#!/bin/sh

#  IsSignetOn.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/14/21.
#  Copyright © 2021 Peter. All rights reserved.
sudo -u $(whoami) ~/.standup/BitcoinCore/$PREFIX/bin/bitcoin-cli -chain=signet getblockchaininfo
exit 1
