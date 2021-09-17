#!/bin/sh

#  RefreshSignetHS.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/15/21.
#  Copyright © 2021 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
else
  export HOMEBREW="/usr/local/bin/brew"
fi

echo "Refreshing signet hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) $HOMEBREW services stop tor
rm -f /usr/local/var/lib/tor/gordian/signet/hostname
rm -f /usr/local/var/lib/tor/gordian/signet/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/gordian/signet/hs_ed25519_secret_key
echo "Starting Tor..."
sudo -u $(whoami) $HOMEBREW services start tor
exit 1
