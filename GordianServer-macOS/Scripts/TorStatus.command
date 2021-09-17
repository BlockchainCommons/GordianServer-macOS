#!/bin/sh

#  TorStatus.command
#  StandUp
#
#  Created by Peter on 15/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
else
  export HOMEBREW="/usr/local/bin/brew"
fi

sudo -u $(whoami) $HOMEBREW services list | grep tor
exit 1
