#!/bin/sh

#  StandUp.command
#  StandUp
#
#  Created by Peter on 07/11/19.
#  Copyright © 2019 Blockchain Commons, LLC

function installBitcoin () {

  echo "Creating ~/.standup/BitcoinCore..."
  mkdir ~/.standup/BitcoinCore

  echo "Downloading $SHA_URL"
  curl $SHA_URL -o ~/.standup/BitcoinCore/SHA256SUMS.asc -s
  echo "Saved to ~/.standup/BitcoinCore/SHA256SUMS.asc"
  
  echo "Downloading Bitcoin Core $VERSION from $MACOS_URL"
  cd ~/.standup/BitcoinCore
  curl $MACOS_URL -o ~/.standup/BitcoinCore/$BINARY_NAME --progress-bar

  echo "Checking sha256 checksums $BINARY_NAME against SHA256SUMS.asc"
  ACTUAL_SHA=$(shasum -a 256 $BINARY_NAME | awk '{print $1}')
  EXPECTED_SHA=$(grep osx64 SHA256SUMS.asc | awk '{print $1}')

  echo "See two signatures (they should match):"
  echo $ACTUAL_SHA
  echo $EXPECTED_SHA
  
  if [ "$ACTUAL_SHA" == "$EXPECTED_SHA" ]; then

    echo "Signatures match"
    echo "Unpacking $BINARY_NAME"
    tar -zxvf $BINARY_NAME

  else

    echo "Signatures do not match! Terminating..."
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
        MAINNET_HS=/usr/local/var/lib/tor/standup/main
        if test -f "$MAINNET_HS"; then
            echo "$MAINNET_HS exists."
        else
            configureTor
        fi
        
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
        if [ -d /usr/local/var/lib/tor/standup/main ]; then
            echo "/usr/local/var/lib/tor/standup/main exists."
        else
            configureTor
        fi
        
        echo "Installation complete, you can now close this window if it does not automatically dismiss."
        exit 1
        
    fi
  
}

function createTorrc () {

    echo "Creating torrc file..."
    cp /usr/local/etc/tor/torrc.sample /usr/local/etc/tor/torrc
    
}

function configureTor () {

    echo "Configuring tor v3 hidden service's..."
    sed -i -e 's/#ControlPort 9051/ControlPort 9051/g' /usr/local/etc/tor/torrc
    sed -i -e 's/#CookieAuthentication 1/CookieAuthentication 1/g' /usr/local/etc/tor/torrc
    sed -i -e 's/## address y:z./## address y:z.\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/main\/\
HiddenServiceVersion 3\
HiddenServicePort 1309 127.0.0.1:8332\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/test\/\
HiddenServiceVersion 3\
HiddenServicePort 1310 127.0.0.1:18332\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/reg\/\
HiddenServiceVersion 3\
HiddenServicePort 1311 127.0.0.1:18443\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/lightning\/p2p\/\
HiddenServiceVersion 3\
HiddenServicePort 9735 127.0.0.1:9735\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/lightning\/rpc\/\
HiddenServiceVersion 3\
HiddenServicePort 1312 127.0.0.1:1312/g' /usr/local/etc/tor/torrc

    echo "Creating hidden service directories at /usr/local/var/lib/tor/standup"
    
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
    
    mkdir /usr/local/var/lib/tor/standup
    if [ -d /usr/local/var/lib/tor/standup ]; then
        echo "/usr/local/var/lib/tor/standup created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/main
    if [ -d /usr/local/var/lib/tor/standup/main ]; then
        echo "/usr/local/var/lib/tor/standup/main created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/main"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/test
    if [ -d /usr/local/var/lib/tor/standup/test ]; then
        echo "/usr/local/var/lib/tor/standup/test created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/test"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/reg
    if [ -d /usr/local/var/lib/tor/standup/reg ]; then
        echo "/usr/local/var/lib/tor/standup/reg created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/reg"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/lightning
    if [ -d /usr/local/var/lib/tor/standup/lightning ]; then
        echo "/usr/local/var/lib/tor/standup/lightning created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/lightning"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/lightning/p2p
    if [ -d /usr/local/var/lib/tor/standup/lightning/p2p ]; then
        echo "/usr/local/var/lib/tor/standup/lightning/p2p created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/lightning/p2p"
        exit 1
    fi
    
    mkdir /usr/local/var/lib/tor/standup/lightning/rpc
    if [ -d /usr/local/var/lib/tor/standup/lightning/rpc ]; then
        echo "/usr/local/var/lib/tor/standup/lightning/rpc created"
    else
        echo "There was an error creating /usr/local/var/lib/tor/standup/lightning/rpc"
        exit 1
    fi
    
    echo "Assigning hidden service directories with permissions 700..."
    chmod 700 /usr/local/var/lib/tor/standup/main
    chmod 700 /usr/local/var/lib/tor/standup/test
    chmod 700 /usr/local/var/lib/tor/standup/reg
    chmod 700 /usr/local/var/lib/tor/standup/lightning
    chmod 700 /usr/local/var/lib/tor/standup/lightning/rpc
    chmod 700 /usr/local/var/lib/tor/standup/lightning/p2p
    
}

mkdir ~/.standup
installBitcoin
configureBitcoin
installTor
