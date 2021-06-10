//
//  SmallManagers.swift
//  TINU
//
//  Created by Pietro Caruso on 12/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

#if !isTool

import Cocoa

public final class FinalScreenSmallManager{
    static let shared =  FinalScreenSmallManager()
    
    var message = ""
    var title = ""
}
#endif

public final class RecoveryModeManager{
	public static let shared = RecoveryModeManager()
	
	//this is used to not repeat a lot of time the user and file check
	private var tempReallyRecovery: Bool! = nil
	
	//if we are really in the recovery
	public var sharedIsReallyOnRecovery: Bool{
		get{
			if let v = tempReallyRecovery{
				return v
			}else{
				var really = false
				
				if isRootUser{
					really = !FileManager.default.fileExists(atPath: "/usr/bin/sudo")
				}
				
				tempReallyRecovery = really
				return really
			}
		}
	}
	
	//this varible tells if the app is running on a recovery/installer mode mac
	public var sharedIsOnRecovery = false
}

//this varible tells if the app is running on a recovery/installer mode mac
public var sharedIsOnRecovery: Bool{
	get{
		return RecoveryModeManager.shared.sharedIsOnRecovery
	}
	set{
		RecoveryModeManager.shared.sharedIsOnRecovery = newValue
	}
}

public var sharedIsReallyOnRecovery: Bool{
	get{
		return RecoveryModeManager.shared.sharedIsReallyOnRecovery
	}
}

public var isRootUser: Bool{
	get{
		return NSUserName() == "root"
	}
}

typealias rmm = RecoveryModeManager
