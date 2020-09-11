#!/bin/sh

#  InstallLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/9/20.
#  Copyright © 2020 Peter. All rights reserved.
CONFIG="alias=Gordian-Server\
bitcoin-rpcpassword="$RPC_PASSWORD"\
bitcoin-rpcuser="$RPC_USER"\
bitcoin-cli="$HOME"/.standup/BitcoinCore/"$PREFIX"/bin\
bitcoin-datadir="$DATA_DIR"\
network=bitcoin\
plugin="$HOME"/.lightning/plugins/c-lightning-http-plugin/target/release/c-lightning-http-plugin\
proxy=127.0.0.1:9050\
announce-addr="$LIGHTNING_P2P_ONION"\
bind-addr=127.0.0.1:9735\
log-file="$HOME"/.lightning/lightning.log\
log-level=debug:plugin\
http-pass="$HTTP_PASS"\
http-port=1312"

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
    
    if ! [ -d /usr/local/Cellar/pyenv ]; then
    
        echo "Installing pyenv..."
        sudo -u $(whoami) /usr/local/bin/brew install pyenv
        
    else
        
        echo "pyenv already installed"
    
    fi

}

function installLightning () {

    ln -s /usr/local/Cellar/gettext/0.20.1/bin/xgettext /usr/local/opt
    export PATH="/usr/local/opt:$PATH"

    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"

    /usr/local/bin/pyenv install 3.7.4
    /usr/local/bin/pip3 install --upgrade pip

    cd "$HOME"/.standup
    git clone https://github.com/ElementsProject/lightning.git
    cd lightning
    git checkout tags/v0.9.0-1

    /usr/local/bin/pyenv local 3.7.4
    /usr/local/bin/pip3 install mako

    ./configure
    /usr/bin/make
}

function configureLightning () {
    
    if ! [ -d "$HOME"/.lightning ]; then
    
        echo "Creating "$HOME"/.lightning directory..."
        mkdir "$HOME"/.lightning
        
    else
        
        echo ""$HOME"/.lightning directory already exists"
    
    fi
    
    
    if ! test -f "$HOME"/.lightning/config; then
    
        echo "Create "$HOME"/.lightning/config"
        touch "$HOME"/.lightning/config
        echo "$CONFIG" > "$HOME"/.lightning/config
        
    else
        
        echo ""$HOME"/.lightning config already exists..."
    
    fi
    
    
    if ! [ -d "$HOME"/.lightning/plugins ]; then
    
        echo "Creating "$HOME"/.lightning/plugins directory..."
        mkdir "$HOME"/.lightning/plugins
        
    else
        
        echo ""$HOME"/.lightning/plugins directory already exists"
    
    fi
    
    if ! test -f "$HOME"/.lightning/lightning.log; then
    
        echo "Create "$HOME"/.lightning/lightning.log"
        touch "$HOME"/.lightning/lightning.log
        
    else
        
        echo ""$HOME"/.lightning/lightning.log already exists..."
    
    fi

}

function installHttpPlugin () {

    if ! [ -d /usr/local/Cellar/rustup ]; then
    
        echo "Installing rust..."
        sudo -u $(whoami) /usr/local/bin/brew install rustup
        rustup-init
        
    else
        
        echo "rustup already installed"
    
    fi
    
    cd "$HOME"/.lightning/plugins
    git clone https://github.com/Start9Labs/c-lightning-http-plugin.git
    cd c-lightning-http-plugin
    /usr/local/bin/cargo build --release
    chmod a+x "$HOME"/.lightning/plugins/c-lightning-http-plugin/target/release/c-lightning-http-plugin
    echo "C-Lightning installation complete!"
    exit 1
}

installDependencies
installLightning
configureLightning
installHttpPlugin
