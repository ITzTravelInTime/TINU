//
//  SharedVariables.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import AppKit

//REQUIRED TO LET THE APP TO WORK PROPERLY
//here there are all the variables that are accessible in all the app to determinate the status of the app and what it is doing

//the shared variable of the main windows, it used as safe reference
public var sharedWindow: NSWindow!
//the shared contacts window
public var contactsWindowController: ContactsWindowController!
//the shared credits window
public var creditsWindowController: CreditsWindowController!

public var wMSDINDWindow: DriveDetectInfoWindowController!
public var downloadAppWindow: DownloadAppWindowController!

#if !macOnlyMode
public var EFIPartitionMonuterTool: EFIPartitionMounterWindowController!
#endif

//public log window varivble
public var logWindow: LogWindowController!
//this variable is a storyboard that is used to instanciate some windows
public var sharedStoryboard: NSStoryboard!
//sets if the license window has to be show
public var sharedShowLicense = false
//this variable tells to the app to install macos on the targetvolume using the target app (experimental, to keep disabled at the moment because it does not seems to work)
public var sharedInstallMac: Bool = false

//this variable returns the name of the current executable used by the app
public var sharedExecutableName: String{
	/*
		var res = "createinstallmedia"
        if sharedInstallMac{
            res = "startosinstall"
        }
		log(res)
        return res
	*/
	if sharedInstallMac{
		return "startosinstall"
	}
	return "createinstallmedia"
}

//this gives the prefix for the window title
public var sharedWindowTitlePrefix: String{
    get{
        if AppManager.shared.sharedTestingMode{
            return "TINU (testing version)"
        }
        
        return "TINU"
    }
}


fileprivate let toggleRecoveryModeShadows = !false
public var blockShadow: Bool {
	return ((sharedIsOnRecovery && !toggleRecoveryModeShadows) || simulateDisableShadows)
}
