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

//use for settings management
public var defaults = UserDefaults.init()

//the shared variable of the main windows, it used as safe reference
public var sharedWindow: NSWindow!
//the shared contacts window
public var contactsWindowController: ContactsWindowController!
//the shared credits window
public var creditsWindowController: CreditsWindowController!
//public log window varivble
var logWindow: LogWindowController!

//this variable is a storyboard that is used to instanciate some windows
public var sharedStoryboard: NSStoryboard!
//sets if the license window has to be show
public var showLicense = true
//this varible tells if the app is running on a recovery/installer mode mac
public var sharedIsOnRecovery = false

//just some shared variables to setup the final result window
public var sharedIsOk = false
public var sharedMessage = ""
public var sharedTitle = ""

//this variable tells if the pre-creation is in progress
public var sharedIsPreCreationInProgress = false

//this tells to the rest of the app if the creation of the installer is in execution
public var sharedIsCreationInProgress = false

//this variable is the drive or partition that the user has selected
public var sharedVolume: String!

//this variable is the bsd name of the drive or partition currently selected by the user
public var sharedBSDDrive: String!
//this is the path of the mac os installer application that the user has selected
public var sharedApp: String!
//this varable tells to the app if the selected volume or drive needs to be reformatted using hfs+ (deprecated)
//public var sharedVolumeNeedsFormat: Bool!
//this variable tells to the app if the selected drive needs to be formatted using GUID partition method
public var sharedVolumeNeedsPartitionMethodChange: Bool!

//this variable tells to the app to install macos on the targetvolume using the target app (experimental, to keep disabled at the moment because it does not seems to work)
public var sharedInstallMac: Bool = false

//this variable returns the name of the current executable used by the app
public var sharedExecutableName: String{
    get{
        if sharedInstallMac{
            return "startosinstall"
        }
        return "createinstallmedia"
    }
}

//this variable is used to determinate if the interface must use the vibrant look, it will not be enabled if the apop is used in a mac os installer or recovery, because the effects without graphics acceleration will cause only lagg
public var sharedUseVibrant = false{
    didSet{
        if !sharedIsOnRecovery{
            for i in NSApplication.shared().windows{
                if let c = i.windowController as? GenericWindowController{
                    c.checkVibrant()
                }
            }
            defaults.set(sharedUseVibrant, forKey: sharedUseVibrantKey)
        }
    }
}

//this is used to know if it's really possible to use the vibrant graphics
public var canUseVibrantLook: Bool{get{return (sharedUseVibrant && !sharedIsOnRecovery)}}

//this is used to determinate if the app is running in testing mode
public var sharedTestingMode = false

//this gives the prefix for the window title
public var sharedWindowTitlePrefix: String{
    get{
        if sharedTestingMode{
            return "TINU (testing version)"
        }
        return "TINU"
    }
}

//this variable tells if the "focus area with the vibrant layout" can be used
public var sharedUseFocusArea = false{
    didSet{
        if !sharedIsOnRecovery{
            for i in NSApplication.shared().windows{
                if let c = i.windowController as? GenericWindowController{
                    c.checkVibrant()
                    if let w = c.contentViewController as? GenericViewController{
                        w.viewDidSetVibrantLook()
                    }
                }
            }
            defaults.set(sharedUseFocusArea, forKey: sharedUseFocusAreaKey)
        }
    }
}

//this is the verbose mode script, a copy here is leaved here just in case it's missing from the application folder
public let verboseScript = "#!/bin/sh\n#  DebugScript.sh\n#  TINU\n#\n#  Created by Pietro Caruso on 20/09/17.\n#  Copyright © 2017 Pietro Caruso. All rights reserved.\necho \"Staring running TINU in log mode\"\n\"$(dirname \"$(dirname \"$0\")\")/MacOS/TINU\""

//variables used to manage the creation process
public var process = Process()
public var errorPipe = Pipe()
public var outputPipe = Pipe()
