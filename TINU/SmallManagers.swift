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
	//if we are really in the recovery
	public var isActuallyOn: Bool{
		struct MEM{
			static var tempReallyRecovery: Bool! = nil
		}
		
		if let v = MEM.tempReallyRecovery{
			return v
		}
		
		var really = false
		
		if isRootUser{
			really = !FileManager.default.fileExists(atPath: "/usr/bin/sudo")
		}
		
		MEM.tempReallyRecovery = really
		return really
	}
	
	//this varible tells if the app is running on a recovery/installer mode mac
	public var isOn = false
}

//this varible tells if the app is running on a recovery/installer mode mac
public var sharedIsOnRecovery: Bool{
	return RecoveryModeManager.shared.isOn
}

public var sharedIsReallyOnRecovery: Bool{
	return RecoveryModeManager.shared.isActuallyOn
}

public var isRootUser: Bool{
	return NSUserName() == "root"
}
