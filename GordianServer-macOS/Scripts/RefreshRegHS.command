#!/bin/sh

#  RefreshRegHS.command
#  StandUp
#
#  Created by Peter on 02/06/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "Refreshing testnet hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) $(command -v brew) services stop tor
rm -f /usr/local/var/lib/tor/gordian/regtest/hostname
rm -f /usr/local/var/lib/tor/gordian/regtest/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/gordian/regtest/hs_ed25519_secret_key
echo "Starting Tor..."
sudo -u $(whoami) $(command -v brew) services start tor
exit 1
