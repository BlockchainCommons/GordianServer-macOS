#!/bin/sh

#  CheckHomebrew.command
#  StandUp
#
#  Created by Peter on 27/05/20.
#  Copyright © 2020 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
else
  export HOMEBREW="/usr/local/bin/brew"
fi

if [[ $(command -v $HOMEBREW) == "" ]]; then
    echo "Homebrew not installed"
else
    echo "Homebrew installed"
fi

exit 1
