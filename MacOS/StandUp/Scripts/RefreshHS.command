#!/bin/sh

#  RefreshHS.command
#  StandUp
#
#  Created by Peter on 24/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
echo "Refreshing all hidden services..."
echo "Stopping Tor..."
sudo -u $(whoami) /usr/local/bin/brew services stop tor

echo "Removing all hidden services"
rm -f /usr/local/var/lib/tor/standup/main/hostname
rm -f /usr/local/var/lib/tor/standup/main/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/standup/main/hs_ed25519_secret_key

rm -f /usr/local/var/lib/tor/standup/test/hostname
rm -f /usr/local/var/lib/tor/standup/test/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/standup/test/hs_ed25519_secret_key

rm -f /usr/local/var/lib/tor/standup/reg/hostname
rm -f /usr/local/var/lib/tor/standup/reg/hs_ed25519_public_key
rm -f /usr/local/var/lib/tor/standup/reg/hs_ed25519_secret_key

echo "Starting Tor..."
sudo -u $(whoami) /usr/local/bin/brew services start tor
echo "Done"
exit 1
