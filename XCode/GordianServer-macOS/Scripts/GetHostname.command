#!/bin/sh

#  GetHostname.command
#  StandUp
#
#  Created by Peter on 20/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
cat /usr/local/var/lib/tor/standup/main/hostname
cat /usr/local/var/lib/tor/standup/test/hostname
cat /usr/local/var/lib/tor/standup/reg/hostname

if test -f /usr/local/var/lib/tor/standup/lightning/hostname; then
    cat /usr/local/var/lib/tor/standup/lightning/hostname
fi

exit 1
