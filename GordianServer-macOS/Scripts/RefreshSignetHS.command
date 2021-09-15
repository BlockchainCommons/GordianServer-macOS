#!/bin/sh

#  RefreshSignetHS.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/15/21.
#  Copyright © 2021 Peter. All rights reserved.
echo "Refreshing signet hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) /usr/local/bin/brew services stop tor
rm -f /usr/local/var/lib/tor/gordian/signet/hostname
rm -f /usr/local/var/lib/tor/gordian/signet/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/gordian/signet/hs_ed25519_secret_key
echo "Starting Tor..."
sudo -u $(whoami) /usr/local/bin/brew services start tor
exit 1
