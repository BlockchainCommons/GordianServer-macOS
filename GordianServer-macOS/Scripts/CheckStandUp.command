#!/bin/sh

#  CheckStandUp.command
#  StandUp
#
#  Created by Peter on 27/12/19.
#  Copyright © 2019 Blockchain Commons, LLC
if [ -d ~/.standup/BitcoinCore ]; then
  echo "True"

else
  echo "False"

fi

exit 1
