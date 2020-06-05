#!/bin/sh

#  RemoveOldHost.command
#  StandUp
#
#  Created by Peter on 04/06/20.
#  Copyright © 2020 Peter. All rights reserved.
sudo -u $(whoami) /bin/rm -r /usr/local/var/lib/tor/standup
exit 1
