#!/bin/sh

#  DebugScript.sh
#  TINU
#
#  Created by Pietro Caruso on 20/09/17.
#  Copyright © 2017 Pietro Caruso. All rights reserved.
echo "Staring running EFI Partition Mounter in log mode"
"$(dirname "$(dirname "$0")")/MacOS/EFI Partition Mounter" -diagnostics
