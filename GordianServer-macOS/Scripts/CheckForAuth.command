#!/bin/sh

#  CheckForAuth.command
#  StandUp
#
#  Created by Peter on 03/06/20.
#  Copyright © 2020 Peter. All rights reserved.
if find /usr/local/var/lib/tor/gordian/main/authorized_clients -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "Authenticated"
else
    echo "Unauthenticated"
fi
exit 1
