#!/bin/sh

#  InstallTor.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/16/21.
#  Copyright © 2021 Peter. All rights reserved.
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW="/opt/homebrew/bin/brew"
  export TOR="/opt/homebrew/opt/tor/bin/tor"
  export TORRC="/opt/homebrew/etc/tor/torrc"
else
  export HOMEBREW="/usr/local/bin/brew"
  export TOR="/usr/local/bin/tor"
  export TORRC="/usr/local/etc/tor/torrc"
fi

function installTor () {
    if ! command -v $TOR &> /dev/null
    then
    
        echo "Installing tor..."
        sudo -u $(whoami) $HOMEBREW install tor
        
        echo "Checking if torrc exists..."
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
        
        sudo -u $(whoami) $HOMEBREW services start tor
        
        echo "Installation complete, you can now close this window if it does not automatically dismiss."
        exit 1
        
    else
        # We now update Tor if it already exists
        echo "Updating tor..."
        sudo -u $(whoami) $HOMEBREW upgrade tor
        
        # We now check if the torrc exists before creating one
        echo "Checking if torrc exists..."
        if test -f $TORRC; then
            echo "$TORRC exists."
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
    cp "$TORRC.sample" $TORRC
}

function configureTor () {
    echo "Configuring tor v3 hidden service's..."
    sed -i -e 's/#ControlPort 9051/ControlPort 9051/g' $TORRC
    sed -i -e 's/#CookieAuthentication 1/CookieAuthentication 1/g' $TORRC
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
HiddenServicePort 8080 127.0.0.1:8080/g' $TORRC

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
    exit 1
}

installTor
