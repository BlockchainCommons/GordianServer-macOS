#!/bin/sh

#  IsProcessRunning.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/28/21.
#  Copyright © 2021 Peter. All rights reserved.
if pgrep "bitcoind"; then
    echo 'Running';
else
    echo "Stopped";
fi
exit 1
