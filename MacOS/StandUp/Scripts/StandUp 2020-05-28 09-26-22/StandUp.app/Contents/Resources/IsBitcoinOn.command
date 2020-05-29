#!/bin/sh

#  IsBitcoinOn.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

# Check if StandUp exists
if [ -d ~/StandUp/BitcoinCore ]; then

# if it does use it
  ~/StandUp/BitcoinCore/$PREFIX/bin/bitcoin-cli -datadir="$DATADIR" getblockchaininfo

else

# if it doesn't use whatever exists
  PATH="$(command -v bitcoin-cli)"
  #$PATH -datadir="$DATADIR" getblockchaininfo
  
  if ! [ "$DATADIR" == "" ]; then
  
    $PATH -datadir="$DATADIR" getblockchaininfo
    
  else
  
    $PATH getblockchaininfo
  
  fi

fi

echo "Done"
exit 1
