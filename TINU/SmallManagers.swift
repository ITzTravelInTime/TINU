//
//  SmallManagers.swift
//  TINU
//
//  Created by Pietro Caruso on 12/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class Recovery{
	//if we are really in the recovery
	static var isActuallyOn: Bool{
		struct MEM{
			static var tempReallyRecovery: Bool! = nil
		}
		
		if let v = MEM.tempReallyRecovery{
			return v
		}
		
		var really = false
		
		if User.isRoot && !Sandbox.isEnabled{
			really = !FileManager.default.fileExists(atPath: "/usr/bin/sudo")
		}
		
		MEM.tempReallyRecovery = really
		return really
	}
	
	//this varible tells if the app is running on a recovery/installer mode mac
	static var isOn: Bool{
		
		struct MEM{
			static var state: Bool! = nil
		}
		
		if let state = MEM.state{
			return state
		}
		
		if isActuallyOn{
			print("Running on the root user on a mac os recovery")
			MEM.state = true
			return true
		}else{
			print("Running on this user: " + User.name)
			
			if simulateRecovery{
				print("Recovery mode simulation activated")
			}
			
			MEM.state = simulateRecovery
			return simulateRecovery
		}
	}
}

public final class Sandbox{
	static var isEnabled: Bool {
		let environment = ProcessInfo.processInfo.environment
		let res = environment["APP_SANDBOX_CONTAINER_ID"] != nil
		print("Sandbox status is: \(res)")
		return res
	}
}

public final class User{
	static public var name: String{
		return NSUserName()
	}
	
	static public var isRoot: Bool{
		return name == "root"
	}

}
