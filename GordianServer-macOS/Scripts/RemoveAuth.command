#!/bin/sh

#  RemoveAuth.command
#  StandUp
#
#  Created by Peter on 03/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) /bin/rm -r /usr/local/var/lib/tor/gordian/main/authorized_clients/*
sudo -u $(whoami) /bin/rm -r /usr/local/var/lib/tor/gordian/test/authorized_clients/*
sudo -u $(whoami) /bin/rm -r /usr/local/var/lib/tor/gordian/regtest/authorized_clients/*
sudo -u $(whoami) /bin/rm -r /usr/local/var/lib/tor/gordian/signet/authorized_clients/*
exit 1
