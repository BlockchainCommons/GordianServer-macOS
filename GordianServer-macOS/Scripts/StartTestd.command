#!/bin/sh

#  StartTestd.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
ulimit -n 188898
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoind -chain=test -daemon
exit 1
