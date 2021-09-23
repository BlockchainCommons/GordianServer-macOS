#!/bin/sh

#  UpgradeBitcoin.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
echo "Updating to $VERSION"
echo "Removing ~/.gordian/BitcoinCore"
rm -R ~/.gordian/BitcoinCore
mkdir ~/.gordian/BitcoinCore

function updateBitcoin () {
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
  curl https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt -o ~/.gordian/BitcoinCore/keys.txt
  sh -c 'while read fingerprint keyholder_name; do gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'

  echo "Verifying Bitcoin."

  export SHASIG=`sudo -u $(whoami) /usr/local/bin/gpg --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
  export SHACOUNT=`sudo -u $(whoami) /usr/local/bin/gpg --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
  echo "SHASIG: $SHASIG"

  if [[ "$SHASIG" ]]; then

    echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
    echo "$SHASIG"

    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
    exit 1

  else

    echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
    exit 1

  fi
}

updateBitcoin
