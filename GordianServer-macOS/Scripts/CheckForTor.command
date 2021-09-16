#!/bin/sh

#  CheckForTor.command
#  StandUp
#
#  Created by Peter on 20/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
$(command -v tor) --version
exit 1
