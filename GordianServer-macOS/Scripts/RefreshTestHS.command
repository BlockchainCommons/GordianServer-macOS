#!/bin/sh

#  RefreshTestHS.command
#  StandUp
#
#  Created by Peter on 02/06/20.
#  Copyright © 2020 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
else
  export HOMEBREW="/usr/local/bin/brew"
fi

echo "Refreshing testnet hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) $HOMEBREW services stop tor
rm -f /usr/local/var/lib/tor/gordian/test/hostname
rm -f /usr/local/var/lib/tor/gordian/test/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/gordian/test/hs_ed25519_secret_key
echo "Starting Tor..."
sudo -u $(whoami) $HOMEBREW services start tor
exit 1
