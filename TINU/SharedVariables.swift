//
//  SharedVariables.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//here there are all the variables that are accessible in all the app to determinate the status of the app and what it is doing
let toggleRecoveryModeShadows = false

public var look: UIManager.AppLook{
	
	struct MEM{
		static var result: UIManager.AppLook! = nil
	}
	
	if let r = MEM.result{
		return r
	}
	
	var ret: UIManager.AppLook! = nil
	
	if let lk = simulateLook, ret == nil{
		print("Forcing a simulated Theme \(lk.rawValue)")
		ret = lk
	}
	
	if (Recovery.isOn && !toggleRecoveryModeShadows && (ret == nil)){
		print("Recovery theme will be used")
		ret = .recovery
	}
	
	if #available(macOS 11.0, *), ret == nil {
		print("Shadows SF Symbols theme will be used")
		ret = .shadowsSFSymbols
	}else{
		print("Shadows Old Icons theme will be used")
	}
	
	MEM.result = ret ?? .shadowsOldIcons
	return MEM.result!
}

