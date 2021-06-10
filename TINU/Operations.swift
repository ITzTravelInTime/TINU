//
//  OptionalOperations.swift
//  TINU
//
//  Created by Pietro Caruso on 18/07/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public struct SettingsRes: Equatable{
	let result: Bool?
	let messange: String?
	
	static let resTrueNil: SettingsRes = SettingsRes(result: true, messange: nil)
	static let resFalseNil: SettingsRes = SettingsRes(result: false, messange: nil)
}

public final class Operations{
	
	public static let shared = Operations()
	
	private let manager = FileManager.default
	
	#if useEFIReplacement && !macOnlyMode
	func mountEFIPartAndCopyEFIFolder() -> SettingsRes{
		
		let efiMan = EFIPartitionManager()
		
		let efiRepMan = EFIFolderReplacementManager.shared
		
		guard let f = efiRepMan!.checkSavedEFIFolder() else{
			log("There isn't any saved clover EFI folder, skipping EFI partition mount and EFI folder copying")
			return SettingsRes.resTrueNil
		}
		
		let badReturn = SettingsRes(result: false, messange: "TINU failed to mount the EFI partition or to copy the EFI folder inside of it")
		
		if !f{
			log("    Saved EFI folder is not a proper clover 64 bit EFI folder, impossible to copy it on the target drive's EFI partition")
			return badReturn
		}
		
		log("There is a saved clover EFI folder, trying to copy it into the EFI partition of the target drive")
		
		log("  Trying to mount the EFI partition of the target drive")
		
		let bsdid = dm.getDriveBSDIDFromVolumeBSDID(volumeID: cvm.shared.disk.bSDDrive) + "s1"
		
		log("    The EFI partition of the target drive is: \(bsdid)")
		
		if !efiMan.mountPartition(bsdid){
			
			log("    EFI partition not mounted!!!")
			return badReturn
			
		}
		
		log("    EFI partition \(bsdid) mounted with success")
		
		guard let mount = dm.getMountPointFromPartitionBSDID(bsdid) else{
			log("    Impossible to get a proper mount point for the mounted EFI partition")
			return badReturn
		}
		
		if !FileManager.default.fileExists(atPath: mount){
			log("    The mount point of the EFI partition does not exist!!!")
			return badReturn
		}
		
		log("    Mount point for the EFI partition \(bsdid) is: \(mount)")
		
		log("    Trying to copy the saved EFI folder in \(mount)")
		
		if !efiRepMan!.saveEFIFolder(mount + "/EFI"){
			log("Error while copying the clover EFI folder, operation canceled")
			return badReturn
		}
		
		log("    EFI folder copied with success")
		
		return SettingsRes.resTrueNil
	}
	#endif
	
	func createReadme() -> SettingsRes{
		
		guard let o = cvm.shared.options.list[.otherOptionCreateReadmeID]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		//creates a readme file into the target drive
		
		var ok = true
		
		do{
			log("   Creating the readme file")
			if let sv = cvm.shared.disk.path{
				//trys to write the readme file on the target drive using the text stored into a special variable
				try TextManager!.readmeText!.write(toFile: sv + "/README.txt", atomically: true, encoding: .utf8)
				
				//trys to change the file attributes of the readme file to make it visible
				let e = getErr(cmd: "chflags nohidden \"" + sv + "/README.txt\"")
				if (e != "" && e != "Password:"){
					log("       The readme file file can'be maked visible")
					ok = false
				}
			}
			//error handeling
		}catch let error{
			log("  Readme file creation failed, error: \n\(error)")
			ok = false
		}
		
		if !ok{
			log("!!Error while creating the \"README\" file!")
			
			return SettingsRes(result: false, messange: "TINU failed to create the \"README\" file on the target drive, check the log for details")
			
		}
		
		return SettingsRes.resTrueNil
	}
	
	#if !macOnlyMode
	func createAIBootFiles() -> SettingsRes{
		
		guard let o = cvm.shared.options.list[.otherOptionCreateAIBootFID]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !(o && !cvm.shared.installMac){
			return SettingsRes.resTrueNil
		}
		
		let iaFolder = cvm.shared.disk.path + "/.IABootFiles"
		
		do{
			
			if manager.fileExists(atPath: iaFolder){
				log("   .IABootFiles folder already exists")
				
				if try manager.contentsOfDirectory(atPath: iaFolder).isEmpty{
					log(".IABootFiles folders exists, but it's emty, so it will be removed and then replaced with a custom one")
					try manager.removeItem(atPath: iaFolder)
					return createAIBootFiles()
				}
				return SettingsRes.resTrueNil
			}
			
			log("   .IABootFiles folder creation needed")
			
			try manager.createDirectory(atPath: iaFolder, withIntermediateDirectories: true)
			
			let folders = ["/System/Library/CoreServices", "/System/Library/PrelinkedKernels", "/usr/standalone/i386"]
			
			for f in folders{
				let folder = cvm.shared.disk.path + f
				
				if !manager.fileExists(atPath: folder){
					log("        Folder \"\(f)\" does not exists, it's content will not be copyed inside .IABootFiles")
					continue
				}
				
				log("      Copying files from folder \(folder)")
				for ff in try manager.contentsOfDirectory(atPath: folder){
					let file = folder + "/" + ff
					if manager.fileExists(atPath: file){
						log("      Copying file \(file)")
						try manager.copyItem(atPath: file, toPath: iaFolder + "/" + ff)
					}
				}
			}
			
		}catch let error{
			log("   .IABootFiles folder creation failed, error: \n\(error)")
			log("!!Error while creating the \".IABootFiles\" folder!")
			
			return SettingsRes(result: false, messange: "TINU failed to create the \".IABootFiles\" folder, check the log for details")
		}
		
		return SettingsRes.resTrueNil
		
	}
	#endif
	
	#if !macOnlyMode
	func deleteIAPMID() -> SettingsRes{
		guard let o = cvm.shared.options.list[.otherOptionDeleteIAPMID]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !(o && !cvm.shared.installMac){
			return SettingsRes.resTrueNil
		}
		
		let iaFile = cvm.shared.disk.path + "/.IAPhysicalMedia"
		
		do{
			
			if manager.fileExists(atPath: iaFile){
				log("   removing .IAPhysicalMedia file")
				
				try manager.removeItem(atPath: iaFile)
				
				
				log("   .IAPhysicalMedia removed successfully")
			}else{
				log("   .IAPhysicalMedia file does not exists, this step is not needed")
			}
			
		}catch let error{
			log("   .IAPhysicalMedia remove failed, error: \n\(error)")
			log("!!Error while removing the \".IAPhysicalMedia\" file!")
			
			return SettingsRes(result: false, messange: "TINU failed to remove the \".IAPhysicalMedia\" file, check the log for details")
		}
		
		return SettingsRes.resTrueNil
	}
	#endif
	
	func createIcon() -> SettingsRes{
		
		guard let o = cvm.shared.options.list[.otherOptionCreateIconID]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		
		//trys to create a volumeicon on the target drive if there isn't any, it's used mainly for versions of macOS installer older than 10.13
		do{
			log("   Trying to create the icon on the Bootable macOS installer")
			
			let origin = cvm.shared.app.path + "/Contents/Resources/InstallAssistant.icns" //"/Contents/Resources/ProductPageIcon.icns"
			
			if !manager.fileExists(atPath: origin){
				log("   Icon creation failed, the original icon from the macOS installer app was not found")
				//TODO: Translate this messange and the other one
				return SettingsRes(result: false, messange: "TINU failed to apply the installer app icon on the target drive")
			}
			
			let destination = cvm.shared.disk.path + "/.VolumeIcon"
			
			//trys to copy the volumeicon from the install app to the target volume, if it's already in place, it will be skipped
			
			/*
			if manager.fileExists(atPath: destination){
			log("   Removing existing icon file")
			try manager.removeItem(atPath: destination)
			}
			
			log("   Creating the icon file")
			try manager.copyItem(atPath: origin, toPath: destination)
			*/
			
			if manager.fileExists(atPath: destination + ".icns"){
				log("       Removing existing icon file")
				try manager.removeItem(atPath: destination + ".icns")
				log("       Existing icon file removed successfully")
			}
			
			log("       Creating the icon file")
			try manager.copyItem(atPath: origin, toPath: destination + ".icns")
			
			NSWorkspace.shared.setIcon(NSImage.init(contentsOf: URL.init(fileURLWithPath: origin)), forFile: cvm.shared.disk.path!, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
			
			log("   Icon file created successfully")
			
			//error handeling
		}catch let error{
			log("   VolumeIcon file creation failed, error: \n\(error)")
			log("!!Error while applying the installer app icon to the target volume!")
			
			return SettingsRes(result: false, messange: "TINU failed to apply the installer app icon on the target drive")
		}
		
		return SettingsRes.resTrueNil
	}
	
	func createTINUCopy() -> SettingsRes{
		guard let o = cvm.shared.options.list[.otherOptionTinuCopyID]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		//trys to crerate a copy of this app on the mac os install media
		
		do{
			log("   Trying to create a copy of this app on the bootable macOS installer")
			
			var path = ""
			
			//if we have to put the app on a mac os installation, we need to use the app directory
			if cvm.shared.installMac{
				try manager.createDirectory(atPath: cvm.shared.disk.path + "/Applications", withIntermediateDirectories: true)
				
				path = cvm.shared.disk.path + "/Applications/" + (Bundle.main.bundleURL.lastPathComponent)
			}else{
				
				path = (cvm.shared.disk.path + "/" + (Bundle.main.bundleURL.lastPathComponent))
				
				if (path == cvm.shared.disk.path + "/" + URL.init(fileURLWithPath: cvm.shared.app.path, isDirectory: true).lastPathComponent){
					path = path.deletingSuffix(".app") + "_.app"
				}
				
			}
			
			if manager.fileExists(atPath: path){
				log("       Trying to remove an existing copy of the app")
				try manager.removeItem(atPath: path)
				log("       Existing copy of the app removed successfully")
			}
			
			log("       Trying to copy this app")
			try manager.copyItem(at: Bundle.main.bundleURL, to: URL.init(fileURLWithPath: path, isDirectory: true))
			log("       This app has been copied successfully")
			
		}catch let error{
			log("   Copy of this app failed, error: \n\(error)")
			log("!!Error while copying this app into the target volume!")
			
			return SettingsRes(result: false, messange: "TINU failed to create a copy of itself into the target drive, check the log for details")
		}
		
		return SettingsRes.resTrueNil
	}
	
}
