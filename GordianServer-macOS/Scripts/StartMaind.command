#!/bin/sh

#  StartMaind.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoind -chain=main -daemon
exit 1
