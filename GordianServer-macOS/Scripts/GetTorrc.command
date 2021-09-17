#!/bin/sh

#  GetTorrc.command
#  StandUp
#
#  Created by Peter on 20/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export TORRC="/opt/homebrew/etc/tor/torrc"
else
  export TORRC="/usr/local/etc/tor/torrc"
fi

cat $TORRC
exit 1
