#!/bin/sh

#  CreateMediaWithAuth.sh
#  TINU
#
#  Created by Pietro Caruso on 17/10/2018.
#  Copyright © 2018 Pietro Caruso. All rights reserved.

echo $1

func(){

OUT=$(eval "$1 --help")

local EC=$?

printf "%i\n" "$EC"
}

func

