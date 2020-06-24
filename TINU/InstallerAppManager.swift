//
//  InstallerAppManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public final class InstallerAppManager{
	
	static let shared = InstallerAppManager()
	
	private var cachedAppInfo: [String: Any]!
	
	public func resetCachedAppInfo(){
		cachedAppInfo = nil
		
		if let sa = cvm.shared.sharedApp{
			if FileManager.default.fileExists(atPath: sa + "/Contents/Info.plist"){
				do{
					let result = try DecodeManager.decodePlistDictionary(xml: try String.init(contentsOfFile: sa + "/Contents/Info.plist")) as? [String: Any]
					
					if let r = result{
						
						cachedAppInfo = r
						
						return
					}else{
						print("App bundle info not found or nil")
						return
					}
				}catch let error{
					print("error while getting the bundle info of the target app: \(error)")
					return
				}
			}else{
				print("cant' find the needded file to get the bundle info for the selected installer app")
				return
			}
		}else{
			print("can't get the target app bundle info because the user has not choosen any installer app")
			return
		}
	}
	
	//gets something from the Info.plist file lof the installer app
	public func targetAppInfoPlistItem(itemKey: String) -> String!{
		if cachedAppInfo == nil{
			return nil
		}
		
		let result: String! = cachedAppInfo![itemKey] as? String
					
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
	}
	
	//gets the bundle name of the installer app that the user has chosen
	@inline(__always) public func targetAppBundleName() -> String!{
		return targetAppInfoPlistItem(itemKey: "CFBundleDisplayName")
	}
	
	//gets the bundle version for the selected app
	@inline(__always) public func targetAppBundleVersion() -> String!{
		return targetAppInfoPlistItem(itemKey: "DTSDKBuild")
	}
	
	//checks the bundle name of the chosen installer app
	public func checkSharedBundleName() -> Bool{
		if cvm.shared.sharedBundleName.isEmpty {
			if let n = targetAppBundleName(){
				cvm.shared.sharedBundleName = n
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
		if cvm.shared.sharedBundleVersion.isEmpty {
			if let n = targetAppBundleVersion(){
				cvm.shared.sharedBundleVersion = n
				return true
			}else{
				return false
			}
		}else{
			return true
		}
	}
	
	//checks both shared bundle name and shared bundle version
	@inline(__always) public func checkSharedBundleItems() -> Bool{
		return checkSharedBundleName() && checkSharedBundleVersion()
	}
	
	//returns the version number of the mac os installer app, returns nil if it was not found, returns an epty string if it's an unrecognized version
	public func installerAppVersion() -> String!{
		if checkSharedBundleVersion(){
			var subVer = String(cvm.shared.sharedBundleVersion.prefix(3))
			
			subVer.removeFirst()
			subVer.removeFirst()
			
			let hexString = String(UInt8(subVer, radix: 36)! - 10)
			
			return String(UInt(String(cvm.shared.sharedBundleVersion.prefix(2)))! - 4) + "." + hexString
			
		}
		
		if checkSharedBundleName(){
			
			//fallback, really not used a lot
			
			let lc = cvm.shared.sharedBundleName.lowercased()
			if lc.contains("big sur") || lc.contains("10.16") || lc.contains("11.0"){
				return "16"
			}
			if lc.contains("catalina") || lc.contains("10.15"){
				return "15"
			}
			if lc.contains("mojave") || lc.contains("10.14"){
				return "14"
			}
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
	public func installerAppSupportsThatVersion(version: Float) -> Bool!{
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
				if let n = Float(v){
					return n <= version
				}
			}
		}
		
		return nil
	}
	
	//returns if the installer app version is earlyer than the specified one
	
	public func installerAppGoesUpToThatVersion(version: Float) -> Bool!{
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
				if let n = Float(v){
					return n < version
				}
			}
		}
		
		return nil
	}
	
	//checks if the selected macOS installer application version has apfs support
	@inline(__always) public func sharedAppNotSupportsAPFS() -> Bool!{
		print("Checking if the installer app supports APFS")
		return installerAppGoesUpToThatVersion(version: 13)
	}
	
	//checks if the installer app is a macOS mojave app
	@inline(__always) public func sharedAppNotIsMojave() -> Bool!{
		print("Checking if the installer app is MacOS Mojave")
		return installerAppGoesUpToThatVersion(version: 14)
	}
	
	//checks if the selected mac os installer application does support using tinu from the recovery
	@inline(__always) public func sharedAppNotSupportsTINU() -> Bool!{
		print("Checking if the isntaller app supports TINU on recovery")
		return installerAppGoesUpToThatVersion(version: 11)
	}
	
	@inline(__always) public func sharedAppNeedsIABoot() -> Bool!{
		print("Checking if the installer app needs particular boot files replacement or the creation of .IABootFiles folder")
		return !installerAppGoesUpToThatVersion(version: 13.4)
	}
	
}

typealias iam = InstallerAppManager
