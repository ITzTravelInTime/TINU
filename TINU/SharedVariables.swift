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


public final class AppBanner{
public static let banner = "\n" + """
\(getRow(isUP: true))
\u{2551}                                     \u{2551}
\u{2551}        _/_ o                        \u{2551}
\u{2551}        /  , _ _   ,  ,              \u{2551}
\u{2551}       (__(_( ( (_/(_/(__            \u{2551}
\u{2551}       Version: \(getSpaces())\u{2551}
\u{2551}                                     \u{2551}
\u{2551}       Made with love using:         \u{2551}
\u{2551}         __,                         \u{2551}
\u{2551}        (           o  /) _/_        \u{2551}
\u{2551}         `.  , , , ,  //  /          \u{2551}
\u{2551}       (___)(_(_/_(_ //_ (__         \u{2551}
\u{2551}                    /)               \u{2551}
\u{2551}                   (/                \u{2551}
\u{2551}                                     \u{2551}
\(getRow(isUP: false))
""" + "\n"

fileprivate static func getSpaces() -> String{
	let spacel = 20
	
	let version = Bundle.main.version!
	
	var res = ""
	
	if version.count >= spacel{
		
		for i in version.indices{
			res += "\(version[i])"
		}
		
	}else{
		res += version
		
		for _ in 0...(spacel - version.count){
			res += " "
		}
		
	}
	
	return res
}

fileprivate static func getRow(isUP: Bool) -> String{
	let length = 36
	
	var res = "\u{2554}"
	
	if !isUP{
		res = "\u{255A}"
	}
	
	for _ in 0...(length){
		res += "\u{2550}"
	}
	
	if isUP{
		res += "\u{2557}"
	}else{
		res += "\u{255D}"
	}
	
	return res
}
	
}

//use for settings management
public var defaults = UserDefaults.init()

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
public var sharedShowLicense = true
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


//suff to be deprecated


//this variable is used to determinate if the interface must use the vibrant look, it will not be enabled if the apop is used in a mac os installer or recovery, because the effects without graphics acceleration will cause only lagg
/*public var sharedUseVibrant = false{
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
                defaults.set(sharedUseVibrant, forKey: AppManager.SettingsKeys().useVibrantKey)
            }
        }
    }
}*/

//this is used to know if it's really possible to use the vibrant graphics
//public var canUseVibrantLook: Bool{get{return (sharedUseVibrant && !sharedIsOnRecovery)}}

//this gives the prefix for the window title
public var sharedWindowTitlePrefix: String{
    get{
        if AppManager.shared.sharedTestingMode{
            return "TINU (testing version)"
        }
        
        return "TINU"
    }
}

//this variable tells if the "focus area with the vibrant layout" can be used
/*public var sharedUseFocusArea = false{
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
                    defaults.set(sharedUseFocusArea, forKey: AppManager.SettingsKeys().useFocusAreaKey)
                }
            }
        }
    }
}*/
