#!/bin/sh

#  LaunchInstaller.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 10/21/21.
#  Copyright © 2021 Peter. All rights reserved.
INSTALL_SCRIPT_PATH="/Users/$(whoami)/.gordian/installBitcoin.sh"
LOG="/Users/$(whoami)/.gordian/gordian.log"
touch $INSTALL_SCRIPT_PATH
DIRNAME="$()"
echo ""$(cd "$(dirname "$0")"; pwd)"/StandUp.command $BINARY_NAME $MACOS_URL $SHA_URL $SIGS_URL $VERSION | tee -a $LOG" > $INSTALL_SCRIPT_PATH
chmod +x $INSTALL_SCRIPT_PATH
open -a Terminal $INSTALL_SCRIPT_PATH
exit 1
