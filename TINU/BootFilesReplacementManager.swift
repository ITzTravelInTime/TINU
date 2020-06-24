//
//  PostCreationVariables.swift
//  TINU
//
//  Created by ITzTravelInTime on 09/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

/*
import Foundation

#if !macOnlyMode

public final class BootFilesReplacementManager{
	
	static let shared = BootFilesReplacementManager()
	
	var replacementProcessProgress: Double!
	
	private final class FilesPaths{
		
		static let current = FilesPaths()
		
		private let p = [
			"/.IABootFiles",										//0
			
			"/System/Library/Caches/com.apple.kext.caches/Startup", //1
			
			"/System/Library/PrelinkedKernels", 					//2
			
			"/usr/standalone/i386",									//3
			
			"/System/Library/CoreServices",							//4
			
			"/Library/Preferences/SystemConfiguration"				//5
		]
		
		//those variables stores the paths in which each boot file can be found
		var kernelCachePaths:           [String]
		
		var prelinkedKernelPaths:       [String]
		
		var bootEfiPaths:               [String]
		
		var comAppleBootPlistPaths:     [String]
		
		var platformSupportPlistPaths:  [String]
		
		var systemVersionPlistPaths:    [String]
		
		var versionBridgeBinPaths:      [String]
		
		var immutablekernelPaths:       [String]
		
		var secureBootBundle:           [String]
		
		
		init(){
			kernelCachePaths = 			[p[0], p[1]] 		// /.IABootFiles /System/Library/Caches/com.apple.kext.caches/Startup
			
			prelinkedKernelPaths = 		[p[0], p[1], p[2]]  // /.IABootFiles /System/Library/PrelinkedKernels /System/Library/Caches/com.apple.kext.caches/Startup"]
			
			bootEfiPaths =				[p[0], p[3], p[4]]  // /.IABootFiles /usr/standalone/i386 /System/Library/CoreServices
			
			comAppleBootPlistPaths =    [p[0], p[5]]        // /.IABootFiles /Library/Preferences/SystemConfiguration
			
			platformSupportPlistPaths = [p[0], p[4]]        // /.IABootFiles /System/Library/CoreServices
			
			systemVersionPlistPaths =   [p[4]]              // /System/Library/CoreServices
			
			versionBridgeBinPaths =     [p[0], p[4]]        // /.IABootFiles /System/Library/CoreServices
			
			immutablekernelPaths =      [p[0], p[2]]        // /.IABootFiles /System/Library/PrelinkedKernels
			
			secureBootBundle =          [p[0], p[3]]        // /.IABootFiles /usr/standalone/i386
		}
	}
	
	public var filesToReplace: [ReplaceFileObject] = [
		
		ReplaceFileObject.init(name: "boot.efi",              possiblePaths: FilesPaths.current.bootEfiPaths,              contentData: nil),
		ReplaceFileObject.init(name: "BridgeVersion.bin",     possiblePaths: FilesPaths.current.versionBridgeBinPaths,     contentData: nil),
		ReplaceFileObject.init(name: "com.apple.Boot.plist",  possiblePaths: FilesPaths.current.comAppleBootPlistPaths,    contentData: nil),
		ReplaceFileObject.init(name: "immutablekernel",       possiblePaths: FilesPaths.current.immutablekernelPaths,      contentData: nil),
		ReplaceFileObject.init(name: "kernelcache",           possiblePaths: FilesPaths.current.kernelCachePaths,          contentData: nil),
		ReplaceFileObject.init(name: "PlatformSupport.plist", possiblePaths: FilesPaths.current.platformSupportPlistPaths, contentData: nil),
		ReplaceFileObject.init(name: "prelinkedkernel",       possiblePaths: FilesPaths.current.prelinkedKernelPaths,      contentData: nil),
		ReplaceFileObject.init(name: "SecureBoot.bundle",     possiblePaths: FilesPaths.current.secureBootBundle,          contentData: nil),
		ReplaceFileObject.init(name: "SystemVersion.plist",   possiblePaths: FilesPaths.current.systemVersionPlistPaths,   contentData: nil)
		
	]
	
	//file replacement options
	public func replaceMultipleItems(paths: [String], newItem: Data, nameWithExtension: String) -> Bool{
		let manager = FileManager.default
		
		if cvm.shared.sharedVolume == nil{
			return false
		}
		
		log("   Trying to replace item \"" + nameWithExtension + "\"")
		
		let bfa = InstallerAppManager.shared.sharedAppNeedsIABoot()
		
		var returnValue = true
		for p in paths{
			
			if p == "/.IABootFiles"{
				if let bf = bfa{
					if bf && !oom.shared.otherOptions[oom.OtherOptionID.otherOptionCreateAIBootFID]!.canBeUsed(){
						print("       The .IABootFiles folder is not present, skipping it")
						continue
					}
				}
			}
			
			let path = URL.init(fileURLWithPath: cvm.shared.sharedVolume + p + "/" + nameWithExtension, isDirectory: false)
			do{
				log("       Trying to replace in path \"" + p + "\"")
				
				var isDir : ObjCBool = false
				if !manager.fileExists(atPath: cvm.shared.sharedVolume + p, isDirectory:&isDir) {
					log("       Item's directory do not exists, trying to create it")
					try manager.createDirectory(atPath: cvm.shared.sharedVolume + p, withIntermediateDirectories: true, attributes: [:])
					log("       Item's directory created successfully")
				}
				
				
				if manager.fileExists(atPath: path.path){
					log("       Trying to remove the old item")
					try manager.removeItem(at: path)
					log("       Old item removed successfully")
				}
				
				try newItem.write(to: path, options: .atomic)
				
				log("       Replace in path \"" + p + "\" ended with success")
				
			}catch let error{
				log("       Item replace failed in path: \(p) \n            error details: \n               \(error)")
				returnValue = false
			}
		}
		
		return returnValue
	}
	
	public class ReplaceFileObject{
		var filename: String
		var paths: [String]
		var data: Data!
		
		var visible = true
		
		init() {
			filename = ""
			paths = []
			data = nil
		}
		
		init(name: String, possiblePaths: [String], contentData: Data!) {
			filename = name
			paths = possiblePaths
			data = contentData
		}
		
		init(name: String, possiblePaths: [String], contentData: Data!, isVisible: Bool) {
			filename = name
			paths = possiblePaths
			data = contentData
			
			visible = isVisible
		}
		
		init(name: String, possiblePaths: [String], isVisible: Bool){
			filename = name
			paths = possiblePaths
			
			data = nil
			
			visible = isVisible
		}
		
		public func replace() -> Bool{
			if data != nil && cvm.shared.sharedVolume != nil{
				return BootFilesReplacementManager.shared.replaceMultipleItems(paths: paths, newItem: data!, nameWithExtension: filename)
			}
			return true
		}
	}
	
	public func eraseReplacementFilesData(){
		//dealloc data we no longer need
		print("Erasing boot files replacement data")
		for f in filesToReplace{
			if f.data != nil{
				f.data.removeAll()
				f.data = nil
			}
		}
		print("Boot files replacement data erased")
	}
	
}

#endif
*/

