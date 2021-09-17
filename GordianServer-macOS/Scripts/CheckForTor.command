#!/bin/sh

#  CheckForTor.command
#  StandUp
#
#  Created by Peter on 20/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export TOR="/opt/homebrew/opt/tor/bin/tor"
else
  export TOR="/usr/local/bin/tor"
fi

$TOR --version
exit 1
