#!/bin/sh

#  Verify.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

if [ -d ~/.standup/BitcoinCore ]; then

  cd ~/.standup/BitcoinCore
  shasum -c SHA256SUMS.asc 2<&1 | grep $BINARY_NAME

else

  echo "No ~/.standup/BitcoinCore directory"

fi

exit 1
