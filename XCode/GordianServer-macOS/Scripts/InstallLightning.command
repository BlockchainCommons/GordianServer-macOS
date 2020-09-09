#!/bin/sh

#  InstallLightning.command
#  GordianServer-macOS
#
#  Created by Peter on 9/9/20.
#  Copyright © 2020 Peter. All rights reserved.
function installLightning () {
    sudo -u $(whoami) /usr/local/bin/brew install autoconf automake libtool python3 gmp gnu-sed gettext libsodium
    ln -s /usr/local/Cellar/gettext/0.20.1/bin/xgettext /usr/local/opt
    export PATH="/usr/local/opt:$PATH"

    sudo -u $(whoami) /usr/local/bin/brew install sqlite
    export LDFLAGS="-L/usr/local/opt/sqlite/lib"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include"

    sudo -u $(whoami) /usr/local/bin/brew install pyenv
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
