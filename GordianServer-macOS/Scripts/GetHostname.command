#!/bin/sh

#  GetHostname.command
#  StandUp
#
#  Created by Peter on 20/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
cat /usr/local/var/lib/tor/gordian/main/hostname
cat /usr/local/var/lib/tor/gordian/test/hostname
cat /usr/local/var/lib/tor/gordian/regtest/hostname
cat /usr/local/var/lib/tor/gordian/signet/hostname

if test -f /usr/local/var/lib/tor/gordian/lightning/hostname; then
    cat /usr/local/var/lib/tor/gordian/lightning/hostname
fi

exit 1
