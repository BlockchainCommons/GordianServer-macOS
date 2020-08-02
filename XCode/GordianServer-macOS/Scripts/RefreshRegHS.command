#!/bin/sh

#  RefreshRegHS.command
#  StandUp
#
#  Created by Peter on 02/06/20.
#  Copyright © 2020 Peter. All rights reserved.
echo "Refreshing testnet hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) /usr/local/bin/brew services stop tor
rm -f /usr/local/var/lib/tor/standup/reg/hostname
rm -f /usr/local/var/lib/tor/standup/reg/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/standup/reg/hs_ed25519_secret_key
echo "Starting Tor..."
sudo -u $(whoami) /usr/local/bin/brew services start tor
exit 1
