#!/bin/sh

#  OpenLightningLog.command
#  GordianServer-macOS
#
#  Created by Peter on 9/17/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "open ~/.lightning/lightning.log"
if test -f ~/.lightning/lightning.log; then
    open ~/.lightning/lightning.log
else
    echo "Can not find lightning log"
fi
exit 1
