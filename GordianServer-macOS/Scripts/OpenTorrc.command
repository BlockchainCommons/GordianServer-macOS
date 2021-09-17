#!/bin/sh

#  OpenTorrc.command
#  GordianServer-macOS
#
#  Created by Peter on 9/1/20.
#  Copyright © 2020 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export TORRC="/opt/homebrew/etc/tor/torrc"
else
  export TORRC="/usr/local/etc/tor/torrc"
fi

echo "open /usr/local/etc/tor/torrc"
if test -f $TORRC; then
    open $TORRC
else
    echo "Can not find torrc"
fi
exit 1
