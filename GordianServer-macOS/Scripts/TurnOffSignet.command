#!/bin/sh

#  TurnOffSignet.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/14/21.
#  Copyright © 2021 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordian/BitcoinCore/$PREFIX/bin/bitcoin-cli -chain=signet stop
exit 1
