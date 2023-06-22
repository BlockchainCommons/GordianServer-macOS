#!/bin/sh

#  StandUp.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
BINARY_NAME=$1
MACOS_URL=$2
SHA_URL=$3
SIGS_URL=$4
VERSION=$5

function installBitcoin() {
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
  # TODO: replace bitcoin-23.1-x86_64-apple-darwin.tar.gz with correct env variable
  EXPECTED_SHA=$(grep $BINARY_NAME SHA256SUMS | awk '{print $1}')

  echo "See two hashes (they should match):"
  echo $ACTUAL_SHA
  echo $EXPECTED_SHA
  
  if [ "$ACTUAL_SHA" != "" ]; then
    export ACTUAL_SHA
    export EXPECTED_SHA
    unpackTarball
  else
    echo "No hash exists, Bitcoin Core download failed..."
    exit 1
  fi
}

function unpackTarball() {
  if [ "$ACTUAL_SHA" == "$EXPECTED_SHA" ]; then
    echo "Hashes match"
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
    echo "Installation complete, you can close this terminal."
    exit 1
  else
    echo "Hashes do not match! Terminating..."
    exit 1
  fi
}

installBitcoin
