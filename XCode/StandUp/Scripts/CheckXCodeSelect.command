#!/bin/sh

#  CheckXCodeSelect.command
#  StandUp
#
#  Created by Peter on 27/05/20.
#  Copyright © 2020 Peter. All rights reserved.
if [[ $(command -v xcode-select) == "" ]]; then
    echo "XCode select not installed"
else
    echo "XCode select installed"
fi

exit 1
