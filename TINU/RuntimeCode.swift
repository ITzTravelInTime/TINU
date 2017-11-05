//
//  RuntimeCode.swift
//  TINU
//
//  Created by ITzTravelInTime on 17/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//functions used in in different parts of the app

//cheks if any debug option is enabled, so it will turn on the mode that shows the testing mode mark on  the window's title, because they are hard coded variables, it needs to be colled only once at startup
public func checkAppMode(){
    var inoffensive = false
    
    if simulateCreateinstallmediaFail != nil{
        inoffensive = true
        print("Inoffensive mode on")
    }
    
    if simulateFormatFail || simulateFormatSkip || simulateNoUsableApps || simulateNoUsableDrives || simulateFirstAuthCancel || simulateAbnormalExitcode || simulateSecondAuthCancel || simulateConfirmGetDataFail || inoffensive {
        sharedTestingMode = true
        print("This copy of tinu is running in a testing mode")
    }else{
        sharedTestingMode = false
    }
}

//checks if teh app is running in a normal user level environment or in a root user inside the mac os recovery or installer, so it's sufficient to call it only once during the startup of the app
public func checkUser(){
    let u = NSUserName()
    if !FileManager.default.fileExists(atPath: "/usr/bin/sudo") && u == "root"{
        print("Running on the root user on a mac os recovery")
        sharedIsOnRecovery = true
    }else{
        sharedIsOnRecovery = false
        print("Running on this user: " + u)
    }
}

//this function gets saved settings, should be called only once at app startapp
public func checkSettings(){
    if !sharedIsOnRecovery {
        setSingleSettingBool(key: sharedUseVibrantKey, variable: &sharedUseVibrant)
        //setSingleSettingBool(key: sharedUseFocusAreaKey, variable: &sharedUseFocusArea)
    }
}

//this is used to manage settings from the app load, is used in checkSettings
fileprivate func setSingleSettingBool(key: String, variable: inout Bool){
    if let s = defaults.object(forKey: key) as? Bool{
        variable = s
    }else{
        defaults.set(variable, forKey: key)
    }
}

//return the display name of drive from it's bsd id, used in different screens, called potentially many times during the app execution
public func getDriveNameFromBSDID(_ id: String) -> String!{
    if let session = DASessionCreate(kCFAllocatorDefault) {
        
        let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [], options: [])!
        for volume in mountedVolumes {
            if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volume as CFURL) {
                if let bsd = DADiskGetBSDName(disk){
                    if let bsdName = String.init(utf8String: bsd) {
                        if "/dev/" + bsdName == id{
                            return volume.path
                        }
                    }
                }
            }
        }
    }
    
    return nil
}
