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
		return lk
	}
	
	if ((sharedIsOnRecovery && !toggleRecoveryModeShadows) || simulateDisableShadows){
		return .recovery
	}
	if #available(macOS 11.0, *) {
		return .shadowsSFSymbols
	}else{
		return .shadowsOldIcons
	}
}

