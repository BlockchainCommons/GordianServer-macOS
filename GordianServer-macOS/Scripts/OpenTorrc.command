#!/bin/sh

#  OpenTorrc.command
#  GordianServer-macOS
#
#  Created by Peter on 9/1/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "open /usr/local/etc/tor/torrc"
if test -f /usr/local/etc/tor/torrc; then
    open /usr/local/etc/tor/torrc
else
    echo "Can not find torrc"
fi
exit 1
