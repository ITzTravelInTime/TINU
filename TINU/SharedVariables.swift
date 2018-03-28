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
public var logWindow: LogWindowController!

//this variable is a storyboard that is used to instanciate some windows
public var sharedStoryboard: NSStoryboard!
//sets if the license window has to be show
public var sharedShowLicense = true
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
public var sharedBSDDrive: String!/*{
    didSet{
        restoreOtherOptions()
    }
}*/

//this variable is used to store apfs disk bsd id
public var sharedBSDDriveAPFS: String!

//used to detect if a volume relly uses apfs or it's just an internal apple volume
public var sharedSVReallyIsAPFS = false

//this is the path of the mac os installer application that the user has selected
public var sharedApp: String!{
    didSet{
        DispatchQueue.global(qos: .background).async{
            restoreOtherOptions()
            eraseReplacementFilesData()
			
			processLicense = ""
			
            if sharedApp != nil{
                if let version = targetAppBundleVersion(), let name = targetAppBundleName(){
                    sharedBundleVersion = version
                    sharedBundleName = name
                    
                    var supportsTINU = false
                    
                    if let st = sharedAppNotSupportsTINU(){
                        supportsTINU = st
                    }
                    
                    if !sharedInstallMac{
                        for i in 0...(filesToReplace.count - 1){
                            let item = filesToReplace[i]
                            
                            switch item.filename{
                            case "prelinkedkernel":
                                item.visible = !supportsTINU
                            case "kernelcache":
                                item.visible = supportsTINU
                            default:
                                break
                            }
                        }
                    }
                    
                    if let item = otherOptions[otherOptionTinuCopyID]{
                        item.isUsable = !supportsTINU
                        item.isActivated = !supportsTINU
                    }
                    
                    if sharedInstallMac{
                        var supportsAPFS = false
                        if let st = sharedAppNotSupportsAPFS(){
                            supportsAPFS = st
                        }
                        if let item = otherOptions[otherOptionDoNotUseApfsID]{
                            item.isVisible = !supportsAPFS
							if !sharedSVReallyIsAPFS{
								item.isUsable = (sharedBSDDriveAPFS == nil)
							}else{
								item.isUsable = false
								item.isActivated = false
							}
                        }
                    }
                    
                }
                
                if let item = otherOptions[otherOptionForceToFormatID]{
                    if let st = sharedVolumeNeedsPartitionMethodChange{
                        item.isUsable = !st
                        item.isActivated = st
                    }
                }
            }
        }
    }
}
//this variable tells to the app which is the bundle name of the selcted installer app
public var sharedBundleName = ""

//this is used for the app version
public var sharedBundleVersion = ""

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
        DispatchQueue.global(qos: .background).async {
            if !sharedIsOnRecovery{
                for i in NSApplication.shared().windows{
                    if let c = i.windowController as? GenericWindowController{
                        DispatchQueue.main.sync {
                            c.checkVibrant()
                        }
                    }
                }
                defaults.set(sharedUseVibrant, forKey: settingUseVibrantKey)
            }
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
        
        if sharedInstallMac{
            return "TINU: Install macOS"
        }
        
        
        return "TINU"
    }
}

//this variable tells if the "focus area with the vibrant layout" can be used
public var sharedUseFocusArea = false{
    didSet{
        DispatchQueue.global(qos: .background).async{
            if !sharedIsOnRecovery{
                for i in NSApplication.shared().windows{
                    if let c = i.windowController as? GenericWindowController{
                        DispatchQueue.main.sync {
                            c.checkVibrant()
                            if let w = c.contentViewController as? GenericViewController{
                                w.viewDidSetVibrantLook()
                                
                            }
                        }
                    }
                    defaults.set(sharedUseFocusArea, forKey: settingUseFocusAreaKey)
                }
            }
        }
    }
}

//this is the verbose mode script, a copy here is leaved here just in case it's missing from the application folder
public let verboseScript = "#!/bin/sh\n#  DebugScript.sh\n#  TINU\n#\n#  Created by Pietro Caruso on 20/09/17.\n#  Copyright © 2017 Pietro Caruso. All rights reserved.\necho \"Staring running TINU in log mode\"\n\"$(dirname \"$(dirname \"$0\")\")/MacOS/TINU\""

//this is the text of the readme file that is written on the macOS install media at the end of the createinstallmedia process
public var readmeText: String {
    get{
        if sharedInstallMac{
            return "Thank you for using TINU\n\nIf you want to use this macOS system on an hackintosh, please download and install the clover bootloader, you can find it here:\n https://sourceforge.net/projects/cloverefiboot/files/latest/download?source=files\n\nIf you want to use this macOS system on a standard mac, you don`t have to do extra steps, it`s ready to be used"
        }else{
            return "Thank you for using TINU\n\nIf you want to use this macOS install media on an hackintosh, please download and install the clover bootloader, you can find it here:\n https://sourceforge.net/projects/cloverefiboot/files/latest/download?source=files\n\nIf you want to use this macOS install media on a standard mac, you don`t have to extra steps, it`s ready to be used"
        }
    }
}

//warning icon used by the app
public var warningIcon: NSImage!{
    get{
        return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns", name: "warning")
    }
}

//stop icon used by the app
public var stopIcon: NSImage!{
	get{
		if let i = getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", name: "warning"){
			return i
		}else{
			return NSImage(named: "uncheck")
		}
	}
}

//gets the overlay for usupported stuff
public var unsupportedOverlay: NSImage!{
    get{
        return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Unsupported.icns", name: "warning")
    }
}

public var infoIcon: NSImage!{
	get{
		return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns", name: "warning")
	}
}

//this is used to not repeat a lot of time the user and file check
fileprivate var tempReallyRecovery: Bool! = nil

//if we are really in the recovery
public var sharedIsReallyOnRecovery: Bool{
    get{
        if let v = tempReallyRecovery{
            return v
        }else{
            let really = !FileManager.default.fileExists(atPath: "/usr/bin/sudo") && NSUserName() == "root"
            tempReallyRecovery = really
            return really
        }
    }
}

//this tells to the app is the install media uses custom settings
var sharedMediaIsCustomized = false

//items size for chose drive and chose app screens

let itmSz: NSSize = NSSize(width: 130, height: 160)

//variables used to manage the creation process
public var process = Process()
public var errorPipe = Pipe()
public var outputPipe = Pipe()
