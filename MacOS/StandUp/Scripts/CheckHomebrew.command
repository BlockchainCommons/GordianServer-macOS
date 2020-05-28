#!/bin/sh

#  CheckHomebrew.command
#  StandUp
#
#  Created by Peter on 27/05/20.
#  Copyright © 2020 Peter. All rights reserved.
if [[ $(command -v brew) == "" ]]; then
    echo "Homebrew not installed"
else
    echo "Homebrew installed"
fi

exit 1
