#!/bin/sh

#  IsLightningInstalled.command
#  GordianServer-macOS
#
#  Created by Peter on 9/16/20.
#  Copyright © 2020 Peter. All rights reserved.
if ! command -v ~/.gordian/lightning/lightningd/lightningd &> /dev/null; then
    echo "lightning not installed"
    exit 1
else
    echo "lightning installed"
    exit 1
fi
