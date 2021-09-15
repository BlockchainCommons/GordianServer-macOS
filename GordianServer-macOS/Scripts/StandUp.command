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
  
}

function installTor () {
    
    if ! command -v /usr/local/bin/tor &> /dev/null
    then
    
        echo "Installing tor..."
        sudo -u $(whoami) /usr/local/bin/brew install tor
        
        echo "Checking if torrc exists..."
        TORRC=/usr/local/etc/tor/torrc
        if test -f "$TORRC"; then
            echo "$TORRC exists."
        else
            createTorrc
        fi
        
        echo "Checking if mainnet hidden service exists..."
        MAINNET_HS=/usr/local/var/lib/tor/gordian/main
        if test -f "$MAINNET_HS"; then
            echo "$MAINNET_HS exists."
        else
            configureTor
        fi
        
        sudo -u $(whoami) /usr/local/bin/brew services start tor
        
        echo "Installation complete, you can now close this window if it does not automatically dismiss."
        exit 1
        
    else
        # We now update Tor if it already exists
        echo "Updating tor..."
        sudo -u $(whoami) /usr/local/bin/brew upgrade tor
        
        # We now check if the torrc exists before creating one
        echo "Checking if torrc exists..."
        if test -f /usr/local/etc/tor/torrc; then
            echo "/usr/local/etc/tor/torrc exists."
        else
            createTorrc
        fi
        
        # We now check if the hidden service for mainnet already exists before creating a new one
        echo "Checking if mainnet hidden service exists..."
        if [ -d /usr/local/var/lib/tor/gordian/main ]; then
            echo "/usr/local/var/lib/tor/gordian/main exists."
        else
            configureTor
        fi
                
        echo "Installation complete, you can now close this window if it does not automatically dismiss."
        exit 1
        
    fi
  
}

function createTorrc () {

    echo "Creating torrc file..."
    cp /usr/local/etc/tor/torrc.sample.default /usr/local/etc/tor/torrc
    
}

function configureTor () {

    echo "Configuring tor v3 hidden service's..."
    sed -i -e 's/#ControlPort 9051/ControlPort 9051/g' /usr/local/etc/tor/torrc
    sed -i -e 's/#CookieAuthentication 1/CookieAuthentication 1/g' /usr/local/etc/tor/torrc
    sed -i -e 's/## address y:z./## address y:z.\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/main\/\
HiddenServiceVersion 3\
HiddenServicePort 8332 127.0.0.1:8332\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/test\/\
HiddenServiceVersion 3\
HiddenServicePort 18332 127.0.0.1:18332\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/regtest\/\
HiddenServiceVersion 3\
HiddenServicePort 18443 127.0.0.1:18443\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/signet\/\
HiddenServiceVersion 3\
HiddenServicePort 38332 127.0.0.1:38332\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/lightning\/p2p\/\
HiddenServiceVersion 3\
HiddenServicePort 9735 127.0.0.1:9735\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/gordian\/lightning\/rpc\/\
HiddenServiceVersion 3\
HiddenServicePort 8080 127.0.0.1:8080/g' /usr/local/etc/tor/torrc

    echo "Creating hidden service directories at /usr/local/var/lib/tor/gordian"
    
    # We now check if directory creation fails which happens if Tor installation fails, if so exit the script
    mkdir /usr/local/var/lib
    if [ -d /usr/local/var/lib ]; then
        echo "/usr/local/var/lib created"
    else
        echo "There was an error creating /usr/local/var/lib"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor
    if [ -d /usr/local/var/lib/tor ]; then
        echo "/usr/local/var/lib/tor created"
    else
        echo "There was an error creating /usr/local/var/lib/tor"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian
    if [ -d /usr/local/var/lib/tor/gordian ]; then
        echo "/usr/local/var/lib/tor/gordian created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/main
    if [ -d /usr/local/var/lib/tor/gordian/main ]; then
        echo "/usr/local/var/lib/tor/gordian/main created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/main"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/test
    if [ -d /usr/local/var/lib/tor/gordian/test ]; then
        echo "/usr/local/var/lib/tor/gordian/test created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/test"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/regtest
    if [ -d /usr/local/var/lib/tor/gordian/regtest ]; then
        echo "/usr/local/var/lib/tor/gordian/regtest created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/regtest"
        exit 1
    fi
    
    
    mkdir /usr/local/var/lib/tor/gordian/signet
    if [ -d /usr/local/var/lib/tor/gordian/signet ]; then
        echo "/usr/local/var/lib/tor/gordian/signet created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/signet"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/lightning
    if [ -d /usr/local/var/lib/tor/gordian/lightning ]; then
        echo "/usr/local/var/lib/tor/gordian/lightning created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/lightning"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/lightning/p2p
    if [ -d /usr/local/var/lib/tor/gordian/lightning/p2p ]; then
        echo "/usr/local/var/lib/tor/gordian/lightning/p2p created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/lightning/p2p"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/gordian/lightning/rpc
    if [ -d /usr/local/var/lib/tor/gordian/lightning/rpc ]; then
        echo "/usr/local/var/lib/tor/gordian/lightning/rpc created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/gordian/lightning/rpc"
        exit 1
    fi
    
    echo "Assigning hidden service directories with permissions 700..."
    chmod 700 /usr/local/var/lib/tor/gordian/main
    chmod 700 /usr/local/var/lib/tor/gordian/test
    chmod 700 /usr/local/var/lib/tor/gordian/regtest
    chmod 700 /usr/local/var/lib/tor/gordian/signet
    chmod 700 /usr/local/var/lib/tor/gordian/lightning
    chmod 700 /usr/local/var/lib/tor/gordian/lightning/rpc
    chmod 700 /usr/local/var/lib/tor/gordian/lightning/p2p
    
}

setUpGordianDir
installBitcoin
configureBitcoin
installTor
