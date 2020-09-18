#!/bin/sh

#  GetLightningHostname.command
#  GordianServer-macOS
#
#  Created by Peter on 9/11/20.
#  Copyright © 2020 Peter. All rights reserved.
cat /usr/local/var/lib/tor/standup/lightning/p2p/hostname
cat /usr/local/var/lib/tor/standup/lightning/rpc/hostname
exit 1
