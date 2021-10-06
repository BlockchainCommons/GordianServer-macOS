#!/bin/sh

#  Verify.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

GPG_PATH=""

if [[ $(command -v /opt/homebrew/bin/gpg) != "" ]]; then
    GPG_PATH="/opt/homebrew/bin/gpg"
elif [[ $(command -v /usr/local/bin/gpg) != "" ]]; then
    GPG_PATH="/usr/local/bin/gpg"
elif [[ $(command -v /usr/local/bin/brew/gpg) != "" ]]; then
    GPG_PATH="/usr/local/bin/brew/gpg"
elif [[ $(command -v /usr/local/MacGPG2/bin/gpg) != "" ]]; then
    GPG_PATH="/usr/local/MacGPG2/bin/gpg"
else
    echo "GPG NOT INSTALLED, UNABLE TO VERIFY SIGNATURES!"
    echo "Click the Supported Apps menu item and GPG Suite to install GPG. Or install homebrew and run `brew install gnupg`."
    exit 1
fi

function verifySigs() {
  # Verifying Bitcoin: Signature
  echo "Verifying Bitcoin Core SHA256SUMS..."

  export SHASIG=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
  export SHACOUNT=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
  echo "SHASIG: $SHASIG"

  if [[ "$SHASIG" ]]; then
    echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
    exit 1
  else
    echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
    exit 1
  fi
}

if [ -d ~/.gordian/BitcoinCore ]; then
    verifySigs
else
    echo "No ~/.gordian/BitcoinCore directory"
    exit 1
fi


