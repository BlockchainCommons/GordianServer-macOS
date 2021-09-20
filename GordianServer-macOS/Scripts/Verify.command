#!/bin/sh

#  Verify.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

if [ -d ~/.gordian/BitcoinCore ]; then

  cd ~/.gordian/BitcoinCore
  shasum -c SHA256SUMS 2<&1 | grep $BINARY_NAME

else

  echo "No ~/.gordian/BitcoinCore directory"

fi

exit 1
