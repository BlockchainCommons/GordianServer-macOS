#!/bin/sh

#  OpenFile.command
#  GordianServer-macOS
#
#  Created by Peter Denton on 9/19/21.
#  Copyright © 2021 Peter. All rights reserved.
if [[ $FILE = *.txt ]]; then
  open -a "TextEdit" "$FILE"
  
elif [[ $FILE = *.conf ]]; then
  open -a "TextEdit" "$FILE"
  
elif [[ $FILE = *.log ]]; then
  open -a "Console" "$FILE"
  
elif [[ "$FILE" == *"/host/bitcoin/rpc/"* ]]; then
  open "$FILE"
  
else
  echo "Need to specify a program to open $FILE with. Falling back with TextEdit."
  open -a "TextEdit" "$FILE"
  
fi

exit 1
