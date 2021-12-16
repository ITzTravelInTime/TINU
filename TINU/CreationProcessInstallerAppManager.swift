/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa

extension CreationProcess{
	public /*final*/ class InstallerAppManager: CreationProcessSection, CreationProcessFSObject{
		
		//static let shared = InstallerAppManager()
		
		let ref: CreationProcess
		public private(set) var info: InfoPlist
		
		required init(reference: CreationProcess) {
			ref = reference
			info = InfoPlistProcess(reference: reference)
		}
		
		public var neededFiles: [[String]]{
			//the first element of the first of this array of arrays should always be executable to look for
			//TODO: Maybe check for the base system, this search might be more difficoult
			return [["/Contents/Resources/" + ref.executableName], ["/Contents/SharedSupport/InstallESD.dmg", "/Contents/SharedSupport/SharedSupport.dmg"],["/Contents/Info.plist"],["/Contents/SharedSupport"]]
		}
		
		public var current: InstallerAppInfo!{
			didSet{
				info = InfoPlistProcess(reference: self.ref)
				ref.options.check()
			}
		}
		
		public var path: String!{
			return current?.url?.path
		}
		
		public enum NeededFilesKeys: UInt8, Codable, Equatable{
			case executable = 0
			case dmg
			case infoPlist
			case sharedSupport
		}
		
		public var neededFilesNew: [NeededFilesKeys: [String]]{
			//the first element of the first of this array of arrays should always be executable to look for
			//TODO: Maybe check for the base system, this search might be more difficoult
			return [.executable : ["/Contents/Resources/" + ref.executableName], .dmg : ["/Contents/SharedSupport/InstallESD.dmg", "/Contents/SharedSupport/SharedSupport.dmg"], .sharedSupport : ["/Contents/SharedSupport"], .infoPlist : ["/Contents/Info.plist"]]
		}
		
		public func validateNew(at _app: URL?) -> InstallerAppInfo?{
			guard var app = _app else { return nil }
			if ref.disk.current == nil { return nil }
			
			print("Validating app at: \(app.path)")
			
			var ret = InstallerAppInfo(status: .usable, size: 0, url: app)
			
			let manager = FileManager.default
			
			var tmpURL: URL?
			if let isAlias = FileAliasManager.process(app, resolvedURL: &tmpURL){
				if isAlias{
					app = tmpURL!
				}
			}else{
				print("  The finder alias for \"\(app.path)\" is broken, invalid app path")
				ret.status = .badAlias
				ret.url = nil
				return ret
			}
			
			ret.url = app
			
			var info = [NeededFilesKeys: Bool]()
			
			for i in neededFilesNew{
				if i.value.isEmpty { continue }
				
				var present = false
				
				for f in i.value{
					if manager.fileExists(atPath: app.path + f){
						present = true
						break
					}
				}
				
				info[i.key] = present
			}
			
			print(info)
			
			if info[.executable] == false && info[.dmg] == false{
				print("  This app is not an installer app.")
				ret.status = .notInstaller
				return ret
			}
			
			if info[.infoPlist] == false{
				print("  This app doesn't have an info.plist file.")
				ret.status = .broken
				return ret
			}
			
			print("  The app seems to be an installer app, checking the type:")
			
			if info[.executable] == false && info[.dmg] == true{
				
				let info = InfoPlist(appPath: app.path )
				
				if info.goesUpTo(version: 10.9) && !ref.installMac{
					ret.status = .legacy
					print("    The app is a legacy app")
				}else{
					ret.status = .unsupported
					print("    The app is an unsupported app")
					return ret
				}
				
			}
			
			for i in info{
				if i.value == false{
					if (i.key != .executable && ret.status == .legacy) || (i.key == .executable && ret.status != .legacy){
						print("  The app is damaged")
						ret.status = .broken
						return ret
					}
				}
			}
			
			guard let sz = manager.directorySize(app) else {
				print("  Can't get the size of the app")
				return nil
			}
			
			ret.size = UInt64(sz)
			
			if !ref.disk.compareSize(to: UInt64(sz)){
				print(" The app is too big to fit on the target drive")
				ret.status = .tooBig
				return ret
			}
			
			if !self.isBigEnough(appSize: UInt64(sz)){
				print(" The app is too small to be a proper installer app")
				ret.status = .tooLittle
				return ret
			}
			
			print("The app seems to be valid")
			return ret
		}
		
		public func validate(at _app: URL?) -> InstallerAppInfo?{
			
			var ret = InstallerAppInfo(status: .usable, size: 0, url: nil)
			
			guard var app = _app else { return nil }
			if ref.disk.current == nil { return nil }
			
			print("Validating app at: \(app.path)")
			
			let manager = FileManager.default
			
			var tmpURL: URL?
			if let isAlias = FileAliasManager.process(app, resolvedURL: &tmpURL){
				if isAlias{
					app = tmpURL!
				}
			}else{
				print("  The finder alias for \"\(app.path)\" is broken, invalid app path")
				ret.status = .badAlias
				return ret
			}
			
			ret.url = app
			
			let needed = neededFiles
			var check: Int = needed.count
			var isCurrentExecutable = false
			var hasDMG = false
			
			for c in needed{
				if c.isEmpty{
					check-=1
					continue
				}
				
				var breaked = false
				for d in c{
					if manager.fileExists(atPath: app.path + d){
						check-=1
						if URL(fileURLWithPath: app.path + d).pathExtension == "dmg"{
							hasDMG = true
						}
						breaked.toggle()
						break
					}
				}
				
				if !breaked{
					print(" The app is not valid because it lacks one of those required files/folders: ")
					for d in c{
						print("    \(d)")
						if d.contains(ref.executableName){
							isCurrentExecutable.toggle()
							break
						}
					}
					
					if !isCurrentExecutable && hasDMG {
						isCurrentExecutable.toggle()
					}
					
					//break
				}
			}
			
			if isCurrentExecutable{
				ret.status = hasDMG ? .unsupported : .notInstaller
				return ret
			}
			
			if check != 0 {
				ret.status = .broken
				return ret
			}
			
			guard let sz = manager.directorySize(app) else {
				print("  Can't get the size of the installer app at: \(app.path)")
				return nil
			}
			
			ret.size = UInt64(sz)
			
			if !ref.disk.compareSize(to: UInt64(sz)){
				print(" The app is not valid because it's too big to fit on the target drive")
				ret.status = .tooBig
				return ret
			}
			
			if !self.isBigEnough(appSize: UInt64(sz)){
				print(" The app is not valid because it's too small to be a proper installer app")
				ret.status = .tooLittle
				return ret
			}
			
			print("The app seems to be valid")
			return ret
		}
		
		public func isBigEnough(appSize: UInt64) -> Bool{
			return appSize > 4 * UInt64(pow(10.0, 9.0))
		}
		
		public func listApps() -> [InstallerAppInfo]{
			
			log("Starting Installer App scanning")
			
			let fm = FileManager.default
			
			var foldersURLS = [URL?]()
			
			//TINU looks for installer apps in those folders: /Applications ~/Desktop /~Downloads ~/Documents
			
			if !Recovery.actualStatus{
				foldersURLS = [URL(fileURLWithPath: "/Applications"), fm.urls(for: .applicationDirectory, in: .systemDomainMask).first, /*fm.urls(for: .desktopDirectory, in: .userDomainMask).first, fm.urls(for: .downloadsDirectory, in: .userDomainMask).first, fm.urls(for: .documentDirectory, in: .userDomainMask).first,*/ fm.urls(for: .allApplicationsDirectory, in: .systemDomainMask).first, fm.urls(for: .allApplicationsDirectory, in: .userDomainMask).first]
			}
			
			//print(foldersURLS)
			
			let driveb = ref.disk.bSDDrive.mountPoint()
			
			for d in fm.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.isVolumeKey], options: [.skipHiddenVolumes])!{
				let p = d.path
				
				if p == driveb{
					continue
				}
				
				foldersURLS.append(d)
				
				var isDir : ObjCBool = false
				
				if fm.fileExists(atPath: p + "/Applications", isDirectory: &isDir){
					if isDir.boolValue && p != "/"{
						foldersURLS.append(URL(fileURLWithPath: p + "/Applications"))
					}
				}
				
				isDir = false
				
				if fm.fileExists(atPath: p + "/System/Applications", isDirectory: &isDir){
					if isDir.boolValue && p != "/"{
						foldersURLS.append(URL(fileURLWithPath: p + "/System/Applications"))
					}
				}
				
			}
			
			//print("This app will look for installer apps in: ")
			
			for pathURL in foldersURLS{
				
				guard let p = pathURL else { continue }
				
				//print("    " + p.path)
					
				do{
						
					for content in (try fm.contentsOfDirectory(at: p, includingPropertiesForKeys: nil, options: []).filter{ fm.directoryExistsAtPath($0.path) }){
						print("    " + content.path)
						foldersURLS.append(content)
					}
						
				} catch let err{
					print("Error while trying to retrive subfolders of: " + p.path + "\n" + err.localizedDescription)
				}
				
			}
			
			var ret = [InstallerAppInfo]()
			
			for dir in foldersURLS{
				
				guard let d = dir else { continue }
				
				if !fm.fileExists(atPath: d.path){
					continue
				}
				
				if d.pathExtension == "app"{
					continue
				}
				
				log("Scanning for usable apps in \(d.path)")
				
				//let fileNames = try manager.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }
				var appURLs = [URL]()
				
				do {
					appURLs = (try fm.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" })
				} catch let error as NSError {
					print("  Can't get contents of \(d.path)")
					print(error.localizedDescription)
					continue
				}
				
				appfor: for appURL in appURLs {
					
					if let dsk = ref.disk?.path{
						if !dsk.isEmpty{
							if appURL.path.starts(with: (dsk)){
								print("    Skipping \(appURL.path) because it belongs to the chosen drive")
								continue
							}
						}
					}
					
					/*
					guard let capp = self.validate(at: appURL) else {
						print("    Skipping \(appURL.path) because it can't be validated")
						continue
					}
					*/
					
					guard let capp = self.validateNew(at: appURL) else {
						print("    Skipping \(appURL.path) because it can't be validated")
						continue
					}
					
					
					if capp.url == nil{
						print("    Skipping \(appURL.path) because it doesn't have a path setted")
						continue
					}
					
					var found = false
					for a in ret{
						if a.url == capp.url{
							found.toggle()
							break
						}
					}
					
					if found{
						print("    Skipping \(appURL.path) because it is a duplicate")
						continue
					}
					
					switch capp.status {
					case .usable, .legacy, .broken, .tooBig, .tooLittle, .unsupported:
						log("    \(appURL.path) has been added to the apps list")
						ret.append(capp)
						break
					default:
						print("    Skipping \(appURL.path) because it is not an installer app or has errors")
						continue
					}
					
				}
				
			}
			
			log("Installer App Scanning is complete")
			print(ret)
			
			return ret
		}
		
		public class InfoPlistProcess: InfoPlist, CreationProcessSection{
			let ref: CreationProcess
			
			required init(reference: CreationProcess) {
				let sa = reference.app?.path ?? ""
				ref = reference
				super.init(appPath: sa)
			}
			
			
		}
		
		public class InfoPlist{
			
			private var cache: [String: Any]!
			private var internalBundleName: String!
			private var internalBundleVersion: String!
			
			deinit {
				cache = nil
				internalBundleName = nil
				internalBundleVersion = nil
			}
			
			//this variable tells to the app which is the bundle name of the selcted installer app
			public var bundleName: String!{
				if cache == nil{
					return nil
				}
				
				if (internalBundleName ?? "").isEmpty {
					guard let n = item(itemKey: "CFBundleDisplayName") else {return nil}
					internalBundleName = n
					return n
				}else{
					return internalBundleName
				}
			}
			
			//this is used for the app version
			public var bundleVersion: String!{
				if cache == nil{
					return nil
				}
				
				if (internalBundleVersion ?? "").isEmpty {
					guard let n = item(itemKey: "DTSDKBuild") else {return nil}
					internalBundleVersion = n
					return n
				}else{
					return internalBundleVersion
				}
			}
			
			public init(appPath: String){
				cache = nil
				internalBundleName = nil
				internalBundleVersion = nil
				
				/*
				guard let sa = ref.app?.path else{
					print("can't get the target app bundle info because the user has not choosen any installer app")
					return
				}*/
				
				let sa = appPath
				
				if !FileManager.default.fileExists(atPath: sa + "/Contents/Info.plist") {
					print("cant' find the needded file to get the bundle info for the selected installer app")
					return
				}
				
				//do{
					//let result = try Decode.plistToDictionary(from: try String.init(contentsOfFile: sa + "/Contents/Info.plist")) as? [String: Any]
					
					let result = [String: Any].init(fromFileAtPath: sa + "/Contents/Info.plist")
					
					if let r = result{
						
						cache = r
						
						return
					}else{
						print("App bundle info not found or nil")
						return
					}
				
				/*
				}catch let error{
					print("error while getting the bundle info of the target app: \(error)")
					return
				}
				*/
			}
			
			//gets something from the Info.plist file lof the installer app
			public func item(itemKey: String) -> String!{
				if cache == nil{
					return nil
				}
				
				let result: String! = cache![itemKey] as? String
				
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
			
			//returns the version number of the mac os installer app, returns nil if it was not found, returns an epty string if it's an unrecognized version
			public func versionString() -> String!{
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
				
				if bundleName == nil{
					return nil
				}
				
				//fallback method, really not used a lot and not that precise, but it's tested to work
				
				let checkList: [UInt: ([String], [String])] = [17: (["12", "12.", "Monterey"], ["10.12"]), 16: (["big sur", "10.16", "11", "11."], []), 15: (["catalina", "10.15"], []), 14: (["mojave", "10.14"], []), 13: (["high sierra", "high", "10.13"], []), 12: (["sierra", "10.12"], ["high"]), 11: (["el capitan", "el", "capitan", "10.11"], []), 10: (["yosemite", "10.10"], []), 9: (["mavericks", "10.9"], []), 8: (["mountain lion", "mountain", "10.8"], []), 7: (["lion", "10.7"], ["mountain"])]
				
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
			}
			
			public func versionNumber() -> Float!{
				guard let v: String = versionString() else {return nil}
				
				if v.isEmpty{ return nil }
				
				print("detected version: \(v)")
				
				return Float(v)
			}
			
			//returns if the version of the installer app is the spcified version or a newer one
			public func supports(version: Float) -> Bool!{
				guard let ver: Float = versionNumber() else { return nil }
				return ver >= version
			}
			
			//returns if the installer app version is earlyer than the specified one
			public func goesUpTo(version: Float) -> Bool!{
				guard let ver: Float = versionNumber() else { return nil }
				return ver < version
			}
			
			//checks if the selected macOS installer application version has apfs support
			@inline(__always) public func notSupportsAPFS() -> Bool!{
				print("Checking if the installer app supports APFS")
				return goesUpTo(version: 13)
			}
			
			//checks if the installer app is a macOS mojave app
			@inline(__always) public func isNotMojave() -> Bool!{
				print("Checking if the installer app is MacOS Mojave")
				return goesUpTo(version: 14)
			}
			
			//checks if the selected mac os installer application does support using tinu from the recovery
			@inline(__always) public func notSupportsTINU() -> Bool!{
				print("Checking if the isntaller app supports TINU on recovery")
				return goesUpTo(version: 11)
			}
			
			#if !macOnlyMode
			@inline(__always) public func supportsIAEdit() -> Bool!{
				print("Checking if the installer app supports the creation of .IABootFiles folder")
				return !goesUpTo(version: 13.4) && goesUpTo(version: 14.0)
			}
			#endif
			
		}
		
	}
	
}

//typealias iam = InstallerAppManager
