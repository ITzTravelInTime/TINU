//
//  MacrosReference.swift
//  TINU
//
//  Created by Pietro Caruso on 05/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

/*

This file contains explainations for the macros used in this app, those are indications for the compiler to compile or not some specific parts of the code

To enable each macro you need to go into the build settings section of the Xcode project and then add the macros to the Active Compilation Conditions for both debug and release

- demo
	This is an example macro to let you test macros effects, and check if you are able to make them to work, by enableing this you will see a message of success at the app startup

- sudoStartup
	This will let the app to always start as sudo

- usedate
	This will add a string prefix with the date and the precise time in seconds in which that log message was send to the log system, usefoul for debug reasons, WARNING, this may slow down the app while creating the usb instller or while installing macOS via tinu using the recovery mode

- noFirstAuth
	This will disable first step authentication

- macOnlyMode
	This will hide and/or disable all the hackintosh-specific stuff and hackintosh references, made to make this app to be more apple friendly in case of a possible app store release (is apple would allow for this kind of tool to even be on the app store)

- useEFIReplacement
	This is used to compile and show stuff related to the "Install ... EFI Folder" advanced settings

- useFileReplacement
	This allows the usage of the bootfiles replacement menu

- skipChooseCustomization
	This will skip the screen that prompts for the customization options and instead shoing the confirm screen with a button which allows to customize the advanced settings, setted by default, please keep it enabled, or some users may have a bad time using the app

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


