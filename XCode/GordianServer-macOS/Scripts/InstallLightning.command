#!/bin/sh

#  InstallLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/9/20.
#  Copyright © 2020 Peter. All rights reserved.
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
    installDependencies

    ln -s /usr/local/Cellar/gettext/0.20.1/bin/xgettext /usr/local/opt
    export PATH="/usr/local/opt:$PATH"

    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"

    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
    source ~/.bash_profile
    pyenv install 3.7.4
    pip install --upgrade pip

    cd ~/.standup
    git clone https://github.com/ElementsProject/lightning.git
    cd lightning

    pyenv local 3.7.4
    pip install mako

    ./configure
    make
}

installLightning
exit 1
