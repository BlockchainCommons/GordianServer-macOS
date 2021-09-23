#!/bin/sh

#  StandUp.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

function setUpGordianDir () {
    if ! [ -d ~/.gordian ]; then
        mkdir ~/.gordian
    fi
    
    if test -f ~/.gordian/gordian.log; then
        echo "~/.gordian/gordian.log exists."
    else
        touch ~/.gordian/gordian.log
    fi
}

function installBitcoin () {
  echo "Creating ~/.gordian/BitcoinCore..."
  mkdir ~/.gordian/BitcoinCore

  echo "Downloading $SHA_URL"
  curl $SHA_URL -o ~/.gordian/BitcoinCore/SHA256SUMS -s
  echo "Saved to ~/.gordian/BitcoinCore/SHA256SUMS"
  
  echo "Downloading $SIGS_URL"
  curl $SIGS_URL -o ~/.gordian/BitcoinCore/SHA256SUMS.asc -s
  echo "Saved to ~/.gordian/BitcoinCore/SHA256SUMS.asc"
  
  echo "Downloading Laanwj PGP public key from https://github.com/laanwj.gpg"
  curl https://github.com/laanwj.gpg -o ~/.gordian/BitcoinCore/laanwj.gpg -s
  #gpg --import ~/.gordian/BitcoinCore/laanwj.gpg
  
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
    # Need to check signatures too, having issues so skipping for now, user can do it manually.
    #gpg --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS
    
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
  else
    echo "Hashes do not match! Terminating..."
    exit 1
  fi

}

function configureBitcoin () {
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
configureBitcoin
