#!/bin/sh

#  StandUp.command
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
fi

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
  if [[ $GPG_PATH == "" ]]; then
    echo "GPG NOT INSTALLED, UNABLE TO VERIFY SIGNAURES!"
    echo "To install GPG click Supported Apps in the menu and GPG Suite, signature verification can be done later."
    curl https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt -o ~/.gordian/BitcoinCore/keys.txt
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME
    configureBitcoin
  else
    curl https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt -o ~/.gordian/BitcoinCore/keys.txt
    
    if [[ $(command -v /opt/homebrew/bin/gpg) != "" ]]; then
        sudo -u $(whoami) sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) /opt/homebrew/bin/gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    elif [[ $(command -v /usr/local/bin/gpg) != "" ]]; then
        sudo -u $(whoami) sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) /usr/local/bin/gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    elif [[ $(command -v /usr/local/bin/brew/gpg) != "" ]]; then
        sudo -u $(whoami) sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) /usr/local/bin/brew/gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    elif [[ $(command -v /usr/local/MacGPG2/bin/gpg) != "" ]]; then
        sudo -u $(whoami) sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) /usr/local/MacGPG2/bin/gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    else
        sudo -u $(whoami) sh -c 'while read fingerprint keyholder_name; do sudo -u $(whoami) gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done < ~/.gordian/BitcoinCore/keys.txt'
    fi
    
    # Verifying Bitcoin: Signature
    echo "Verifying Bitcoin... (this can take a few moments)"

    export SHASIG=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature"`
    export SHACOUNT=`sudo -u $(whoami) $GPG_PATH --verify ~/.gordian/BitcoinCore/SHA256SUMS.asc ~/.gordian/BitcoinCore/SHA256SUMS 2>&1 | grep "Good signature" | wc -l`
  
    echo "SHASIG: $SHASIG"

    if [[ "$SHASIG" ]]; then

      echo "SIG VERIFICATION SUCCESS: $SHACOUNT GOOD SIGNATURES FOUND."
      echo "$SHASIG"

      echo "Unpacking $BINARY_NAME"
      tar -zxvf $BINARY_NAME
      configureBitcoin

    else

      echo "SIG VERIFICATION ERROR: No verified signatures for Bitcoin!"
      exit 1

    fi
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
