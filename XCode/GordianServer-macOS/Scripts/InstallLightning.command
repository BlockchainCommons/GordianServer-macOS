#!/bin/sh

#  InstallLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/9/20.
#  Copyright © 2020 Peter. All rights reserved.

function configureHiddenServices () {

    echo "Checking if lightning hidden service's exist..."
    
    if [ -d /usr/local/var/lib/tor/standup/lightning ]; then
    
        echo "/usr/local/var/lib/tor/standup/lightning exists."
        
    else
    
        echo "Configuring tor v3 hidden service's..."
        
        sed -i -e 's/HiddenServicePort 1311 127.0.0.1:18443/HiddenServicePort 1311 127.0.0.1:18443\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/lightning\/p2p\/\
HiddenServiceVersion 3\
HiddenServicePort 9735 127.0.0.1:9735\
\
HiddenServiceDir \/usr\/local\/var\/lib\/tor\/standup\/lightning\/rpc\/\
HiddenServiceVersion 3\
HiddenServicePort 1312 127.0.0.1:1312/g' /usr/local/etc/tor/torrc
        
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
        
        chmod 700 /usr/local/var/lib/tor/standup/lightning
        chmod 700 /usr/local/var/lib/tor/standup/lightning/rpc
        chmod 700 /usr/local/var/lib/tor/standup/lightning/p2p
        
        echo "Rebooting Tor..."
        sudo -u $(whoami) /usr/local/bin/brew services restart tor
            
    fi

}

function installDependencies () {

    echo "Installing lightning dependencies..."
    
    if ! [ -d /usr/local/Cellar/autoconf ]; then
    
        echo "Installing autoconf..."
        sudo -u $(whoami) /usr/local/bin/brew install autoconf
        
    else
        
        echo "autoconf already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/automake ]; then
    
        echo "Installing automake..."
        sudo -u $(whoami) /usr/local/bin/brew install automake
        
    else
        
        echo "automake already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/libtool ]; then
    
        echo "Installing libtool..."
        sudo -u $(whoami) /usr/local/bin/brew install libtool
        
    else
        
        echo "libtool already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/python3 ]; then
    
        echo "Installing python3..."
        sudo -u $(whoami) /usr/local/bin/brew install python3
        
    else
        
        echo "python3 already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/gmp ]; then
    
        echo "Installing gmp..."
        sudo -u $(whoami) /usr/local/bin/brew install gmp
        
    else
        
        echo "gmp already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/gnu-sed ]; then
    
        echo "Installing gnu-sed..."
        sudo -u $(whoami) /usr/local/bin/brew install gnu-sed
        
    else
        
        echo "gnu-sed already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/gettext ]; then
    
        echo "Installing gettext..."
        sudo -u $(whoami) /usr/local/bin/brew install gettext
        
    else
        
        echo "gettext already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/libsodium ]; then
    
        echo "Installing libsodium..."
        sudo -u $(whoami) /usr/local/bin/brew install libsodium
        
    else
        
        echo "libsodium already installed"
    
    fi
    
    if ! [ -d /usr/local/Cellar/sqlite ]; then
    
        echo "Installing sqlite..."
        sudo -u $(whoami) /usr/local/bin/brew install sqlite
        
    else
        
        echo "sqlite already installed"
    
    fi
    
    if ! command -v /usr/local/bin/pip3 &> /dev/null; then
    
        sudo -u $(whoami) /usr/local/bin/brew install pip3
        
    else
    
        echo "pip3 installed"
        
    fi

}

function installLightning () {

    ln -s /usr/local/Cellar/gettext/0.20.1/bin/xgettext /usr/local/opt
    export PATH="/usr/local/opt:$PATH"

    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"
    
    cd ~/.standup
    git clone https://github.com/ElementsProject/lightning.git
    cd lightning
    git checkout tags/v0.9.1
    
    sudo -u $(whoami) /usr/local/bin/pip3 install --upgrade pip
    sudo -u $(whoami) /usr/local/bin/pip3 install mako

    sudo -u $(whoami) ~/.standup/lightning/configure
    /usr/bin/make
}

function configureLightning () {

CONFIG="alias=Gordian-Server\n\
bitcoin-rpcpassword="$RPC_PASSWORD"\n\
bitcoin-rpcuser="$RPC_USER"\n\
bitcoin-cli=/Users/$USER/.standup/BitcoinCore/"$PREFIX"/bin/bitcoin-cli\n\
bitcoin-datadir="$DATA_DIR"\n\
network=bitcoin\n\
plugin=/Users/$USER/.lightning/plugins/c-lightning-http-plugin/target/release/c-lightning-http-plugin\n\
proxy=127.0.0.1:9050\n\
announce-addr="$(cat /usr/local/var/lib/tor/standup/lightning/p2p/hostname)"\n\
bind-addr=127.0.0.1:9735\n\
log-file=/Users/$USER/.lightning/lightning.log\n\
log-level=debug:plugin\n\
http-pass="$HTTP_PASS"\n\
http-port=1312"
    
    if ! [ -d ~/.lightning ]; then
    
        echo "Creating ~/.lightning directory..."
        mkdir ~/.lightning
        
    else
        
        echo "~/.lightning directory already exists"
    
    fi
    
    
    if ! test -f ~/.lightning/config; then
    
        echo "Create ~/.lightning/config"
        touch ~/.lightning/config
        echo "$CONFIG" > ~/.lightning/config
        
    else
        
        echo "~/.lightning config already exists..."
    
    fi
    
    
    if ! [ -d ~/.lightning/plugins ]; then
    
        echo "Creating ~/.lightning/plugins directory..."
        mkdir ~/.lightning/plugins
        
    else
        
        echo "~/.lightning/plugins directory already exists"
    
    fi
    
    if ! test -f ~/.lightning/lightning.log; then
    
        echo "Create ~/.lightning/lightning.log"
        touch ~/.lightning/lightning.log
        
    else
        
        echo "~/.lightning/lightning.log already exists..."
    
    fi

}

function installHttpPlugin () {

    if ! [ -d /usr/local/Cellar/rustup ]; then
    
        echo "Installing rust..."
        sudo -u $(whoami) /usr/local/bin/brew install rustup
        rustup-init -y
        
    else
        
        echo "rustup already installed"
    
    fi
    
    cd ~/.lightning/plugins
    git clone https://github.com/Start9Labs/c-lightning-http-plugin.git
    cd c-lightning-http-plugin
    ~/.cargo/bin/cargo build --release
    chmod a+x ~/.lightning/plugins/c-lightning-http-plugin/target/release/c-lightning-http-plugin
    echo "C-Lightning installation complete!"
    echo "If this console does not dismiss or you get a spinner just force quit the app and reopen it"
    exit
}

configureHiddenServices
installDependencies
installLightning
configureLightning
installHttpPlugin
