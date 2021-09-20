#!/bin/sh

#  UpgradeBitcoin.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
echo "Updating to $VERSION"
echo "Removing ~/.gordian"
rm -R ~/.gordian
mkdir ~/.gordian
mkdir ~/.gordian/BitcoinCore

echo "Downloading $SHA_URL"
curl $SHA_URL -o ~/.gordian/BitcoinCore/SHA256SUMS -s
echo "Saved to ~/.gordian/BitcoinCore/SHA256SUMS"

echo "Downloading Laanwj PGP signature from https://bitcoincore.org/laanwj-releases.asc..."
curl https://bitcoincore.org/laanwj-releases.asc -o ~/.gordian/BitcoinCore/laanwj-releases.asc -s
echo "Saved to ~/.gordian/BitcoinCore/laanwj-releases.asc"

echo "Downloading Bitcoin Core $VERSION from $MACOS_URL"
cd ~/.gordian/BitcoinCore
curl $MACOS_URL -o ~/.gordian/BitcoinCore/$BINARY_NAME --progress-bar

echo "Checking sha256 checksums $BINARY_NAME against SHA256SUMS"
ACTUAL_SHA=$(shasum -a 256 $BINARY_NAME | awk '{print $1}')
EXPECTED_SHA=$(grep osx64 SHA256SUMS | awk '{print $1}')

echo "See two hashes (they should match):"
echo $ACTUAL_SHA
echo $EXPECTED_SHA

if [ "$ACTUAL_SHA" == "$EXPECTED_SHA" ]; then

  echo "Hashes match"
  echo "Unpacking $BINARY_NAME"
  tar -zxvf $BINARY_NAME
  echo "You have upgraded to Bitcoin Core $VERSION"
  
else

  echo "Signatures do not match! Terminating..."
  
fi

exit 1
