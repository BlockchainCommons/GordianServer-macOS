#!/bin/sh

#  ShowTorLog.command
#  StandUp
#
#  Created by Peter on 25/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export TOR_LOG="/opt/homebrew/var/log/tor.log"
else
  export TOR_LOG="/usr/local/var/log/tor.log"
fi

open $TOR_LOG
exit 1
