//
//  InstallerAppManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension CreationVariablesManager{
	public /*final*/ class InstallerAppManager: CreationVariablesManagerSection{
	
	//static let shared = InstallerAppManager()
	
	let ref: CreationVariablesManager
	
	required init(reference: CreationVariablesManager) {
		ref = reference
	}
	
	private var cachedAppInfo: [String: Any]!
	
	private var internalBundleName: String!
	private var internalBundleVersion: String!
		
	deinit {
		cachedAppInfo = nil
		internalBundleName = nil
		internalBundleVersion = nil
	}
	
	public var path: String!{
		didSet{
			
			if path != nil{
				resetCachedAppInfo()
			}
			
			ref.options.checkOtherOptions()
		}
	}
	
	//this variable tells to the app which is the bundle name of the selcted installer app
	public var bundleName: String!{
		if cachedAppInfo == nil{
			return nil
		}
		
		if (internalBundleName ?? "").isEmpty {
			guard let n = targetAppBundleName() else {return nil}
			internalBundleName = n
			return n
		}else{
			return internalBundleName
		}
	}
	
	//this is used for the app version
	public var bundleVersion: String!{
		if cachedAppInfo == nil{
			return nil
		}
		
		if (internalBundleVersion ?? "").isEmpty {
			guard let n = targetAppBundleVersion() else {return nil}
			internalBundleVersion = n
			return n
		}else{
			return internalBundleVersion
		}
	}
	
	public func resetCachedAppInfo(){
		cachedAppInfo = nil
		internalBundleName = nil
		internalBundleVersion = nil
		
		if let sa = path{
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
	
	//returns the version number of the mac os installer app, returns nil if it was not found, returns an epty string if it's an unrecognized version
	public func installerAppVersion() -> String!{
		print("Detecting app version")
		if bundleVersion != nil{
			var subVer = String(bundleVersion!.prefix(3))
			
			subVer.removeFirst()
			subVer.removeFirst()
			
			let hexString = UInt8(subVer, radix: 36)! - 10
			
			let ret = String(UInt(String(bundleVersion!.prefix(2)))! - 4) + "." + String(hexString)
			
			print("Detected app version (using the build number): \(ret)")
			return ret
			
		}
		
		if bundleName != nil{
			
			//fallback method, really not used a lot and not that precise, but it's tested to work
			
			let checkList: [UInt: ([String], [String])] = [17: (["12", "Monterey"], ["10.12"]), 16: (["big sur", "10.16", "11."], []), 15: (["catalina", "10.15"], []), 14: (["mojave", "10.14"], []), 13: (["high sierra", "high", "10.13"], []), 12: (["sierra", "10.12"], ["high"]), 11: (["el capitan", "el", "capitan", "10.11"], []), 10: (["yosemite", "10.10"], []), 9: (["mavericks", "10.9"], [])]
			
			let lc = bundleName!.lowercased()
			
			check: for item in checkList{
				for s in item.value.0{
					if lc.contains(s){
						var correct: Bool = true
						
						for t in item.value.1{
							if lc.contains(t){
								correct = false
								break
							}
						}
						
						if correct{
							print("Detected app version (using the bundle name): \(item.key)")
							return String(item.key)
						}else{
							continue check
						}
					}
				}
			}
			
			return ""
		}else{
			return nil
		}
	}
	
	public func installerAppVersion() -> Float!{
		guard let v: String = installerAppVersion() else {return nil}
		
		if v.isEmpty{ return nil }
		
		print("detected version: \(v)")
		
		return Float(v)
	}
	
	//returns if the version of the installer app is the spcified version or a newer one
	public func installerAppSupportsThatVersion(version: Float) -> Bool!{
		guard let ver: Float = installerAppVersion() else { return nil }
		return ver >= version
	}
	
	//returns if the installer app version is earlyer than the specified one
	public func installerAppGoesUpToThatVersion(version: Float) -> Bool!{
		guard let ver: Float = installerAppVersion() else { return nil }
		return ver < version
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
	
	#if !macOnlyMode
	@inline(__always) public func sharedAppSupportsIAEdit() -> Bool!{
		print("Checking if the installer app supports the creation of .IABootFiles folder")
		return !installerAppGoesUpToThatVersion(version: 13.4) && installerAppGoesUpToThatVersion(version: 14.0)
	}
	#endif
	
}

}

//typealias iam = InstallerAppManager
