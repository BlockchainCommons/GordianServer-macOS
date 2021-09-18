#!/bin/sh

#  UninstallTor.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/16/21.
#  Copyright © 2021 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
  export TOR_ETC="/opt/homebrew/etc/tor"
else
  export HOMEBREW="/usr/local/bin/brew"
  export TOR_ETC="/usr/local/etc/tor"
fi

echo "Removing $TOR_ETC"
rm -rf $TOR_ETC
echo "Removing /usr/local/var/lib/tor"
rm -rf /usr/local/var/lib/tor
echo "Stopping Tor..."
sudo -u $(whoami) $HOMEBREW services stop tor
echo "Uninstalling Tor..."
sudo -u $(whoami) $HOMEBREW uninstall tor
echo "Finished"
exit 1
