/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Foundation

/*

This file contains explainations for the macros used in this app, those are indications for the compiler to compile or not some specific parts of the code

To enable each macro you need to go into the build settings section of the Xcode project and then add the macros to the Active Compilation Conditions for both debug and release

- demo
	This is an example macro to let you test macros effects, and check if you are able to make them to work, by enableing this you will see a message of success at the app startup

- noUnmounted
	This will not let the user to use drives without mounted partitions

- sudoStartup
	This will let the app to perform the SIP check at startup

- usedate
	This will add a string prefix with the date and the precise time in seconds in which that log message was send to the log system, usefoul for debug reasons, WARNING, this may slow down the app while creating the usb instller or while installing macOS via tinu using the recovery mode

- noFirstAuth
	This will disable first step authentication

- macOnlyMode
	This will hide and/or disable all the hackintosh-specific stuff and hackintosh references, made to make this app to be more apple friendly in case of a possible app store release (is apple would allow for this kind of tool to even be on the app store)

- useEFIReplacement
	This is used to compile and show stuff related to the "Install... EFI Folder" advanced settings

- useFileReplacement
	This allows the usage of the bootfiles replacement menu

- TINU
	This tells to compile the "TINU only" code

- isTool
	This is used to tell if some code is used for TINU or not

*/

#if demo

	var demoMacroEnabled = true{
		didSet{
			print("Demo macro works")
		}
	}

#endif


