#!/bin/sh

#  ShowBitcoinConf.command
#  GordianServer-macOS
#
#  Created by Peter on 9/1/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "open "$DATADIR"/bitcoin.conf"
if test -f "$DATADIR"/bitcoin.conf; then
    open "$DATADIR"/bitcoin.conf
else
    echo "Can not find bitcoin.conf"
fi
exit 1
