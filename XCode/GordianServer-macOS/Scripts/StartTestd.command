#!/bin/sh

#  StartTestd.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.standup/BitcoinCore/$PREFIX/bin/bitcoind -chain=test -daemon
exit 1
