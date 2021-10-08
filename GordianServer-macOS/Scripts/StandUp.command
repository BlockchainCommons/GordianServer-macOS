#!/bin/sh

#  StandUp.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

GPG_PATH="$(command -v gpg)"

function setUpGordianDir() {
    if ! [ -d ~/.gordian ]; then
        mkdir ~/.gordian
    fi
    
    if test -f ~/.gordian/gordian.log; then
        echo "~/.gordian/gordian.log exists."
    else
        touch ~/.gordian/gordian.log
    fi
}

function installBitcoin() {
  echo "Creating ~/.gordian/BitcoinCore..."
  mkdir ~/.gordian/BitcoinCore

  echo "Downloading $SHA_URL"
  curl $SHA_URL -o ~/.gordian/BitcoinCore/SHA256SUMS -s
  echo "Saved to ~/.gordian/BitcoinCore/SHA256SUMS"
  
  echo "Downloading $SIGS_URL"
  curl $SIGS_URL -o ~/.gordian/BitcoinCore/SHA256SUMS.asc -s
  echo "Saved to ~/.gordian/BitcoinCore/SHA256SUMS.asc"
  
  echo "Downloading Bitcoin Core $VERSION from $MACOS_URL"
  cd ~/.gordian/BitcoinCore
  curl $MACOS_URL -o ~/.gordian/BitcoinCore/$BINARY_NAME --progress-bar

  echo "Checking sha256 checksums $BINARY_NAME against provided SHA256SUMS"
  ACTUAL_SHA=$(shasum -a 256 $BINARY_NAME | awk '{print $1}')
  EXPECTED_SHA=$(grep osx64 SHA256SUMS | awk '{print $1}')

  echo "See two hashes (they should match):"
  echo $ACTUAL_SHA
  echo $EXPECTED_SHA
  
  if [ "$ACTUAL_SHA" == "$EXPECTED_SHA" ]; then
    echo "Hashes match"
    echo "Checking Signatures"
    verifySigs
    
  else
    echo "Hashes do not match! Terminating..."
    exit 1
  fi
}

function verifySigs() {
  echo "Downloading Bitcoin Core developer pgp keys from https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt"
  echo "Saving them to ~/.gordian/BitcoinCore/keys.txt"
  
  curl https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt -o ~/.gordian/BitcoinCore/keys.txt
  
  if [[ $GPG_PATH == "" ]]; then
    echo "GPG is not installed, ensure you have Homebrew installed by clicking Supported Apps in the menu bar > Homebrew"
    echo "Once Homebrew installation completes open a terminal and run:"
    echo "brew install gpg2 pinentry-mac"
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
    configureBitcoin
  else
    checkPermissions
  fi
}

function checkPermissions() {
  GNUPG_PERMISSIONS=$(ls -ld /Users/$(whoami)/.gnupg)
  CRLSD_PERMISSIONS=$(ls -ld /Users/$(whoami)/.gnupg/crls.d)
    
  if [[ $GNUPG_PERMISSIONS == drwx* ]] && [[ $CRLSD_PERMISSIONS == drwx* ]]; then
    verifyNow
  else
    echo "***INCORRECT Permissions set on /Users/$(whoami)/.gnupg***"
    echo $GNUPG_PERMISSIONS
    echo "Permissions set on /Users/$(whoami)/.gnupg/crls.d:"
    echo $CRLSD_PERMISSIONS
    echo "In order to import keys to verify signatures .gnupg and .gnupg/crls.d needs to be set with chmod 700 (drwx)"
    echo "Open a terminal, copy and paste the below commands, press enter, then use the Verify button to check signatures."
    echo "-------------------------------------------------"
    echo "sudo chown -R $(whoami):admin ~/.gnupg/"
    echo "find ~/.gnupg -type d -exec sudo chmod 700 {} \;"
    echo "find ~/.gnupg -type f -exec sudo chmod 600 {} \;"
    echo "-------------------------------------------------"
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
    configureBitcoin
  fi
}
    
function verifyNow() {
    sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) $(command -v gpg) --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    
    echo "Verifying Bitcoin Core signatures... (this can take a few moments)"

    export SHASIG=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
    export SHACOUNT=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
    echo "SHASIG: $SHASIG"

    if [[ "$SHASIG" ]]; then
      echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
      echo "Unpacking $BINARY_NAME"
      tar -zxvf $BINARY_NAME
      configureBitcoin
    else
      echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
      exit 1
    fi
}

function configureBitcoin() {
  echo "Creating the following bitcoin.conf at: "$DATADIR"/bitcoin.conf:"
  echo "$CONF"

  if [ -d "$DATADIR" ]; then
    cd "$DATADIR"
  else
    mkdir "$DATADIR"
    cd "$DATADIR"
  fi

  echo "$CONF" > bitcoin.conf
  exit 1
}

setUpGordianDir
installBitcoin
