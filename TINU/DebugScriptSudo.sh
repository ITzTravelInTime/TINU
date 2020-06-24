#!/bin/sh

#  DebugScriptSudo.sh
#  TINU
#
#  Created by Pietro Caruso on 20/06/20.
#  Copyright © 2017-2020 Pietro Caruso. All rights reserved.
echo "Staring running TINU in log mode"
sudo "$(dirname "$(dirname "$0")")/MacOS/TINU"
