#!/bin/sh

#  UpdateTor.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/17/21.
#  Copyright © 2021 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
else
  export HOMEBREW="/usr/local/bin/brew"
fi

$HOMEBREW upgrade tor
exit 1
