#!/bin/sh

#  StopLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/17/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordian/lightning/cli/lightning-cli stop
exit 1
