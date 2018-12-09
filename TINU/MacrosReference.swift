//
//  MacrosReference.swift
//  TINU
//
//  Created by Pietro Caruso on 05/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

/*

This file contains explaination for the macros used in this app for the compiler to enable some implemented features
To enable each macro you need to go into the build settings section of the project and then add the macros to the Active Compilation Conditions for debug, release or both

- demo
	This is an example macro to let you test macros effects, by enableing this you will see a message of success at the app startup

- recovery
	This is normally used to use the LocalAuthentication APIs for the first set user authentication in the app on macOS versions starting from El Capitan (older ones will still use older SecurityFoundation APIs to manage the first step auth)

- usedate
	This will add a string prefix with the date and the precise time in seconds in which that log message was send to the log system, usefoul for debug reasons, WARNING, this may slow down the app while creating the usb instller or while installing macOS

- noFirstAuth
	This will disable first step authentication

- macOnlyMode
	This will hide and/or disable all the hackintosh-specific stuff and hackintosh references, made to make this app to be pubblishable on the app-store

- useEFIReplacement
	This is used to compile and show stuff related to the "Copy EFI Folder" advanced setting

- useOldDriveDetection
	This will use a system based on the interpretation of the output of diskutil list instead of diskutil list -plist to get info to detect the storage devices, leaved as a retrocompatibility feature

- skipChooseCustomization
	This will skip the screen that prompts for the customization options and instead shoing the confirm screen with a button which allows to customize the advanced settings

- TINU
	This tells to compile the "TINU only" code

- isTool
	This tells if code is being compiled by tinu or by a tool which uses tinu code
*/

#if demo

	var demoMacroEnabled = true

#endif


