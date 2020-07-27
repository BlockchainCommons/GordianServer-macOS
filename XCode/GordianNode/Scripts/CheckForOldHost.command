#!/bin/sh

#  CheckForOldHost.command
#  StandUp
#
#  Created by Peter on 04/06/20.
#  Copyright © 2020 Peter. All rights reserved.
FILE=/usr/local/var/lib/tor/standup/hostname
if [ -f "$FILE" ]; then
    echo "Exists"
else
    echo "Does not exist"
fi
