#!/bin/sh

#  StartRegd.command
#  StandUp
#
#  Created by Peter on 01/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/StandUp/BitcoinCore/$PREFIX/bin/bitcoind -chain=regtest -daemon
exit 1
