#!/bin/sh

#  StartLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/17/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) ~/.gordain/lightning/lightningd/lightningd
exit 1
