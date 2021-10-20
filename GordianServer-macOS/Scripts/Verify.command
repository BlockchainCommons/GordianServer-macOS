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
fi
export GPG_PATH

function checkPermissions() {

  if [[ ! -d /Users/$(whoami)/.gnupg ]]; then
    mkdir  /Users/$(whoami)/.gnupg
  fi
  
  if [[ ! -f /Users/$(whoami)/crls.d ]]; then
    touch /Users/$(whoami)/.gnupg/crls.d
  fi

  GNUPG_PERMISSIONS=$(ls -ld /Users/$(whoami)/.gnupg)
  CRLSD_PERMISSIONS=$(ls -ld /Users/$(whoami)/.gnupg/crls.d)
    
  if [[ $GNUPG_PERMISSIONS == drwx* ]] && [[ $CRLSD_PERMISSIONS == drwx* ]]; then
    verifySigs
  else
    echo "Permissions set on /Users/$(whoami)/.gnupg:"
    echo $GNUPG_PERMISSIONS
    echo "Permissions set on /Users/$(whoami)/.gnupg/crls.d:"
    echo $CRLSD_PERMISSIONS
    echo "In order to import keys to verify signatures .gnupg and .gnupg/crls.d needs to be set with chmod 700 (drwx)"
    echo "Open a terminal, copy and paste the below commands, press enter, then try using the Verify button again"
    echo "sudo chown -R $(whoami):admin ~/.gnupg/"
    echo "find ~/.gnupg -type d -exec sudo chmod 700 {} \;"
    echo "find ~/.gnupg -type f -exec sudo chmod 600 {} \;"
    exit 1
  fi
}

function verifySigs() {
  curl https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt -o ~/.gordian/BitcoinCore/keys.txt
  
  sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) $GPG_PATH --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'

  echo "Verifying Bitcoin Core signatures... (this can take a few moments)"

  export SHASIG=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
  export SHACOUNT=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
  echo "SHASIG: $SHASIG"

  if [[ "$SHASIG" ]]; then
    echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
  else
    echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
  fi
  
  exit 1
}

function checkForGnupg() {
  if [[ $GPG_PATH == "" ]]; then
    echo "GPG is not installed, ensure you have brew installed by clicking Supported Apps in the menu bar > Homebrew"
    echo "Once Homebrew installation completes open a terminal and run:"
    echo "brew install gpg pinentry-mac"
    exit 1
  else
    checkPermissions
  fi
}

if [ -d ~/.gordian/BitcoinCore ]; then
    checkForGnupg
else
    echo "No ~/.gordian/BitcoinCore directory, click Install then try again."
    exit 1
fi
