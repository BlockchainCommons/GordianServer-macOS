#!/bin/sh

#  UninstallTor.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/16/21.
#  Copyright © 2021 Peter. All rights reserved.
echo "Removing /usr/local/etc/tor"
rm -rf /usr/local/etc/tor
echo "Removing /usr/local/var/lib/tor"
rm -rf /usr/local/var/lib/tor
echo "Stopping Tor..."
sudo -u $(whoami) $(command -v brew) services stop tor
echo "Uninstalling Tor..."
sudo -u $(whoami) $(command -v brew) uninstall tor
echo "Finished"
exit 1
