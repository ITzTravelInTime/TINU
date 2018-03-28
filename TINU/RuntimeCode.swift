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
		simulateSpecialOpertaionsFail,
		simulateRecovery
	]
	
	sharedTestingMode = false
	
	for tc in testingConditions{
		if tc{
			sharedTestingMode = true
		}
	}
	
	if sharedTestingMode{
		print("This copy of tinu is running in a testing mode")
	}
	
	/*
    if simulateFormatFail || simulateFormatSkip || simulateNoUsableApps || simulateNoUsableDrives || simulateFirstAuthCancel || simulateAbnormalExitcode || simulateSecondAuthCancel || simulateConfirmGetDataFail || inoffensive || simulateNoSpecialOperations || simulateSpecialOpertaionsFail || simulateRecovery{
        sharedTestingMode = true
        print("This copy of tinu is running in a testing mode")
    }else{
        sharedTestingMode = false
    }*/
}

//checks if teh app is running in a normal user level environment or in a root user inside the mac os recovery or installer, so it's sufficient to call it only once during the startup of the app
public func checkUser(){
    let u = NSUserName()
    if sharedIsReallyOnRecovery{
        print("Running on the root user on a mac os recovery")
        sharedIsOnRecovery = true
    }else{
        sharedIsOnRecovery = false
        print("Running on this user: " + u)
        if simulateRecovery{
            print("Recovery mode simulation activated")
            sharedIsOnRecovery = true
        }
    }
}

//this function gets saved settings, should be called only once at app startapp
public func checkSettings(){
    if !sharedIsOnRecovery {
        setSingleSettingBool(key: settingUseVibrantKey, variable: &sharedUseVibrant)
        //setSingleSettingBool(key: settingUseFocusAreaKey, variable: &sharedUseFocusArea)
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
    /*if let session = DASessionCreate(kCFAllocatorDefault) {
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
    }*/
    let res = getOut(cmd: "diskutil info \"" + id + "\" | grep \"Mount Point\" | awk '{ print substr($0, index($0,$3)) }'")
    
    if res.isEmpty{
        return nil
    }
    
    return res
}

//return the display name of drive from it's bsd id, used in different screens, called potentially many times during the app execution
public func getDeviceBSDIDFromMountPoint(_ mountPoint: String) -> String!{
	let res = getOut(cmd: "diskutil info \"" + mountPoint + "\" | grep \"Device Node\" | awk '{ print substr($0, index($0,$3)) }'")
	
	if res.isEmpty{
		return nil
	}
	
	return res
}

//gets the drive mount point from it's bsd name
public func getBSDIDFromDriveName(_ path: String) -> String!{
    let res = getOut(cmd: "df -lH | grep \"" + path + "\" | awk '{print $1}'")
	
    if res.isEmpty{
        return nil
    }
    
    return res
}

//gets the drive device name from it's device name
public func getDeviceNameFromBSDID(_ id: String) -> String!{
	let res = getOut(cmd: "diskutil info \"" + getDriveBSDIDFromVolumeBSDID(volumeID: id) + "\" | grep \"Device / Media Name\" | awk '{ print substr($0, index($0,$3)) }'")
	
	if res.isEmpty{
		return nil
	}
	
	return res
}

//checks if the drive exists if it can find it's mount point
public func driveExists(id: String) -> Bool{
    return getDriveNameFromBSDID(id) != nil
}

//checks if the drive exists if it can find it's bsd id from it's mount point
public func driveExists(path: String) -> Bool{
    return getBSDIDFromDriveName(path) != nil
}

//return the drive sbd id of a volume
public func getDriveBSDIDFromVolumeBSDID(volumeID: String) -> String{
    var tmpBSDName = ""
    var ns = 0
    
    for cc in volumeID.characters{
        let c = String(cc)
        if c.lowercased() == "s"{
            ns += 1
        }
        if ns == 1{
            if let _ = Int(c){
                tmpBSDName += c
            }
        }
    }
    
    return "disk" + tmpBSDName
}

//gets something from the Info.plist file lof the installer app
public func targetAppInfoPlistItem(itemKey: String) -> String!{
    if let sa = sharedApp{
        if FileManager.default.fileExists(atPath: sa + "/Contents/Info.plist"){
            do{
                let result: String! = (try decodeXMLDictionary(xml: try String.init(contentsOfFile: sa + "/Contents/Info.plist")) as? [String: Any])![itemKey] as? String
                
                if let r = result{
                    if r.contains("\n") || r.isEmpty {
                        print("Can't get app bundle \"\(itemKey)\" because it contains an illegal character or is empty")
                        return nil
                    }
                    print("App bundle \"\(itemKey)\" got with success: \(r)")
                    return result
                }else{
                    print("App bundle \"\(itemKey)\" not found or nil")
                    return nil
                }
            }catch let error{
                print("error while getting the bundle \"\(itemKey)\" of the target app: \(error)")
                return nil
            }
        }else{
            print("cant' find the needded file to get the \"\(itemKey)\" for the selected installer app")
            return nil
        }
    }else{
        print("can't get the target app bundle \"\(itemKey)\" because the user has not choosen any installer app")
        return nil
    }
}

//gets the bundle name of the installer app that the user has chosen
public func targetAppBundleName() -> String!{
    return targetAppInfoPlistItem(itemKey: "CFBundleDisplayName")
}

//gets the bundle version for the selected app
public func targetAppBundleVersion() -> String!{
   return targetAppInfoPlistItem(itemKey: "DTSDKBuild")
}

//checks the bundle name of the chosen installer app
public func checkSharedBundleName() -> Bool{
    if sharedBundleName.isEmpty {
        if let n = targetAppBundleName(){
            sharedBundleName = n
            return true
        }else{
            return false
        }
    }else{
        return true
    }
}

//checks the bundle version of the choosen installer app
public func checkSharedBundleVersion() -> Bool{
    if sharedBundleVersion.isEmpty {
        if let n = targetAppBundleVersion(){
            sharedBundleVersion = n
            return true
        }else{
            return false
        }
    }else{
        return true
    }
}

//checks both shared bundle name and shared bundle version
public func checkSharedBundleItems() -> Bool{
    return checkSharedBundleName() && checkSharedBundleVersion()
}

//returns the version number of the mac os installer app, returns nil if it was not found, returns an epty string if it's an unrecognized version
public func installerAppVersion() -> String!{
    if checkSharedBundleVersion(){
        return String(Int(String(sharedBundleVersion.characters.prefix(2)))! - 4)
    }
    
    if checkSharedBundleName(){
        let lc = sharedBundleName.lowercased()
        if lc.contains("high sierra") || lc.contains("10.13"){
            return "13"
        }
        if (lc.contains("sierra") && !lc.contains("high")) || lc.contains("10.12"){
            return "12"
        }
        if lc.contains("el capitan") || lc.contains("10.11"){
            return "11"
        }
        if lc.contains("yosemite") || lc.contains("10.10"){
            return "10"
        }
        if lc.contains("mavericks") || lc.contains("10.9"){
            return "9"
        }
        return ""
    }else{
        return nil
    }
}

//returns if the version of the installer app is the spcified version
public func installerAppSupportsThatVersion(version: Int) -> Bool!{
    /*if checkSharedBundleVersion(){
        return (Int(String(sharedBundleVersion.characters.prefix(2)))! - 4) <= version
    }
    
    if checkSharedBundleName(){
        
        
        if let n = Int(installerAppVersion()){
            return n <= version
        } 
    }*/
    
    if let v = installerAppVersion(){
        if !v.isEmpty{
            print("detected version: \(v)")
            if let n = Int(v){
                return n <= version
            }
        }
    }
    
    return nil
}

//checks if the selected macOS installer application version has apfs support
public func sharedAppNotSupportsAPFS() -> Bool!{
    print("Checking if the installer app supports APFS")
    return installerAppSupportsThatVersion(version: 12)
}

//checks if the selected mac os installer application does support using tinu from the recovery
public func sharedAppNotSupportsTINU() -> Bool!{
    print("Checking if the isntaller app supports TINU on recovery")
    return installerAppSupportsThatVersion(version: 10)
}

//this funtionm terminates a process
public func terminateProcess(name: String) -> Bool!{
    
    let pid = getOut(cmd:"ps -Ac -o pid,comm | awk '/^ *[0-9]+ " + name + "$/ {print $1}'")

    if pid.isEmpty{
        log("Process \"" + name + "\" does not needs to be closed")
        return true
    }else{
        if let res = runCommandWithSudo(cmd: "/bin/sh", args: ["-c", "kill " + pid]){
            
            if res.exitCode != 0{
                log("Failed to close \"\(name)\" because the closing process has exited with a code that is not 0: \n     exit code: \(res.exitCode)\n    output: \(res.output)\n     error/s produced: \(res.error)")
                return false
            }
            
            if let f = res.output.first{
                if (f.isEmpty || f == "Password:" || f == "\n"){
                    log("Process \"\(name)\" stopped with success")
                    return true
                }else{
                    log("Failed to close \"\(name)\": \n     exit code: \(res.exitCode)\n    output: \(res.output)\n     error/s produced: \(res.error)")
                    return false
                }
            }else{
                log("Failed to close \"\(name)\" because is not possible to get the output of the termination process")
                return false
            }
        }else{
            log("Failed to close \"\(name)\" because of an authentication failure")
            return nil
        }
    }
    
    //return false
}

//return the icon of thespecified installer app

func getInstallerAppIcon(forApp app: String) ->NSImage{
    let iconp = app + "/Contents/Resources/InstallAssistant.icns"
    
    if FileManager.default.fileExists(atPath: iconp){
        if let i = NSImage(contentsOfFile: iconp){
            return i
        }
    }
    
    return NSWorkspace.shared().icon(forFile: app)
}

//gets an icon from a file, if the file do not exista, it uses an icon from the assets
public func getIconFor(path: String, name: String) -> NSImage!{
	if FileManager.default.fileExists(atPath: path){
		return NSImage(contentsOfFile: path)
	}else{
		return NSImage(named: name)
	}
}

public func getIconFor(path: String, alternate: NSImage!) -> NSImage!{
	if FileManager.default.fileExists(atPath: path){
		return NSImage(contentsOfFile: path)
	}else{
		return alternate
	}
}

//dedicated to plist serialization and deserialization
public func decodeXMLArray(xml: String) throws -> NSArray{
    return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSArray
}

public func codeXMLFromArray(decoded: NSArray) throws -> String{
    //let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
    return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
}

func decodeXMLDictionary(xml: String) throws -> NSDictionary{
    return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSDictionary
}

func decodeXMLDictionaryOpt(xml: String) throws -> NSDictionary?{
    return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as? NSDictionary
}

func codeXMLFromDictionary(decoded: NSDictionary) throws -> String{
    //let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
    return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
}

func codeXMLFromDictionaryOpt(decoded: NSDictionary) throws -> String?{
    //let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
    return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)
}
