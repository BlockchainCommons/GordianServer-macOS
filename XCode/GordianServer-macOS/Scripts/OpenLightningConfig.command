#!/bin/sh

#  OpenLightningConfig.command
#  GordianServer-macOS
#
#  Created by Peter on 9/17/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "open ~/.lightning/config"
if test -f ~/.lightning/config; then
    open ~/.lightning/config
else
    echo "Can not find lightning config"
fi
exit 1
