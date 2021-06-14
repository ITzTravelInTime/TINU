//
//  SharedVariables.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//here there are all the variables that are accessible in all the app to determinate the status of the app and what it is doing
let toggleRecoveryModeShadows = !false

public var look: UIManager.AppLook{
	if let lk = simulateLook{
		print("Forcing a simulated Theme \(lk.rawValue)")
		return lk
	}
	
	if ((sharedIsOnRecovery && !toggleRecoveryModeShadows) || simulateDisableShadows){
		print("Recovery theme will be used")
		return .recovery
	}
	
	if #available(macOS 11.0, *) {
		print("Shadows SF Symbols theme will be used")
		return .shadowsSFSymbols
	}else{
		print("Shadows Old Icons theme will be used")
		return .shadowsOldIcons
	}
}

