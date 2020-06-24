//
//  AppManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public final class AppManager{

	static let shared = AppManager()
	
    
    public struct SettingsKeys{
        #if !isTool && TINU
        public let useVibrantKey = "useVibrant"
        public let useFocusAreaKey = "useFocus"
        #else
            #if EFIPM
        public let startsAsMenuKey = "startsAsMenuItem"
            #endif
        #endif
    }
    
    
     #if !isTool
	
	//this is used to determinate if the app is running in testing mode
	public var sharedTestingMode = false
	
//cheks if any debug option is enabled, so it will turn on the mode that shows the testing mode mark on  the window's title, because they are hard coded variables, it needs to be colled only once at startup
public func checkAppMode(){
	
	print(AppBanner.banner)
	
	let testingConditions = [
		simulateFormatFail,
		simulateFormatSkip,
		simulateNoUsableApps,
		simulateNoUsableDrives,
		simulateFirstAuthCancel,
		simulateAbnormalExitcode,
		simulateSecondAuthCancel,
		simulateConfirmGetDataFail,
		simulateCreateinstallmediaFail != nil,
		simulateNoSpecialOperations,
		simulateSpecialOperationsFail,
		simulateRecovery
	]
	
	sharedTestingMode = false
	
	for tc in testingConditions{
		if tc{
			sharedTestingMode = true
			break
		}
	}
	
	if sharedTestingMode{
		print("This copy of tinu is running in a testing mode")
	}
}
    
    #endif

//checks if teh app is running in a normal user level environment or in a root user inside the mac os recovery or installer, so it's sufficient to call it only once during the startup of the app
public func checkUser(){
	if sharedIsReallyOnRecovery{
		print("Running on the root user on a mac os recovery")
		sharedIsOnRecovery = true
	}else{
		sharedIsOnRecovery = false
		print("Running on this user: " + NSUserName())
        
		if simulateRecovery{
			print("Recovery mode simulation activated")
			sharedIsOnRecovery = true
		}
        
	}
}

   
    
//this function gets saved settings, should be called only once at app startapp
public func checkSettings(){
	if !sharedIsOnRecovery {
        #if !isTool && TINU
		//setSingleSettingBool(key: SettingsKeys().useVibrantKey, variable: &sharedUseVibrant)
		//setSingleSettingBool(key: settingUseFocusAreaKey, variable: &sharedUseFocusArea)
        #else
            #if EFIPM
                setSingleSettingBool(key: SettingsKeys().startsAsMenuKey, variable: &startsAsMenu)
            #endif
        #endif
	}
}

//this is used to manage settings from the app load, is used in checkSettings
private func setSingleSettingBool(key: String, variable: inout Bool){
	if let s = defaults.object(forKey: key) as? Bool{
		variable = s
	}else{
		defaults.set(variable, forKey: key)
	}
}
    
    

}
