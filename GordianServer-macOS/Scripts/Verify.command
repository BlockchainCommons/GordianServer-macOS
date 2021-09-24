#!/bin/sh

#  Verify.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

function verifySigs() {
  # Verifying Bitcoin: Signature
  echo "Verifying Bitcoin Core SHA256SUMS..."

  export SHASIG=`sudo -u $(whoami) /usr/local/bin/gpg --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
  export SHACOUNT=`sudo -u $(whoami) /usr/local/bin/gpg --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
  echo "SHASIG: $SHASIG"

  if [[ "$SHASIG" ]]; then

    echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
    exit 1

  else

    echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
    exit 1

  fi
}

  if [[ $(command -v /usr/local/bin/gpg) == "" ]]; then
     echo "GPG NOT INSTALLED, UNABLE TO VERIFY SIGNATURES!"
     echo "Click the Supported Apps menu item and GPG Suite to install GPG."
     exit 1
  else
     if [ -d ~/.gordian/BitcoinCore ]; then
       verifySigs
     else
       echo "No ~/.gordian/BitcoinCore directory"
       exit 1
     fi
fi


