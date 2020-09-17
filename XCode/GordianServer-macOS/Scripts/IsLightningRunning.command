#!/bin/sh

#  IsLightningRunning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/17/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.standup/lightning/cli/lightning-cli getinfo
exit 1
