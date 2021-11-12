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
import Command

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
	func mountEFIPartAndCopyEFIFolder(ref: CreationProcess) -> SettingsRes{
		
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
		
		let bsdid = BSDID(ref.disk.bSDDrive.driveID.rawValue + "s1")
		
		if !bsdid.isValid{
			log("    EFI partition id is not valid!!")
			return badReturn
		}
		
		log("    The EFI partition of the target drive is: \(bsdid.rawValue)")
		
		Diskutil.Info.resetCache()
		EFIPartition.clearPartitionsCache()
		
		guard let efi = EFIPartition(rawValue: bsdid)else{
			log("    EFI partition object isn't a valid efi partition")
			return badReturn
		}
		
		if !efi.mount(){
			log("    EFI partition not mounted!!!")
			return badReturn
		}
		
		log("    EFI partition \(bsdid) mounted with success")
		
		Diskutil.Info.resetCache()
		
		if !efiRepMan!.saveEFIFolder(toDisk: efi){
			log("Error while copying the clover EFI folder, operation canceled")
			return badReturn
		}
		
		log("    EFI folder copied with success")
		
		return SettingsRes.resTrueNil
	}
	#endif
	
	func createReadme(ref: CreationProcess) -> SettingsRes{
		
		guard let o = ref.options.list[.createReadme]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		//creates a readme file into the target drive
		
		var ok = true
		
		do{
			for _ in 0...0{
				
				log("   Creating the readme file")
				
				guard let sv = ref.disk.path else {
					log("    Error getting the directory for the README file!!")
					ok = false
					continue
				}
				
				//trys to write the readme file on the target drive using the text stored into a special variable
				let file = sv + "/README.txt"
				
				log("    The README file will be saved at path: \(file)")
				
				try TextManager!.readmeText!.write(toFile: file, atomically: true, encoding: .utf8)
				
				if !FileManager.default.fileExists(atPath: file){
					log("Error: The README file was not saved! ")
					ok = false
					continue
				}
				
				//trys to change the file attributes of the readme file to make it visible
				//let e = Command.getErr(cmd: "chflags nohidden \"" + sv + "/README.txt\"")
				if let ee = Command.run(cmd: "/usr/bin/chflags", args: ["nohidden", file]){
					let e = ee.errorString()
					if (!e.isEmpty && e != "Password:"){
						log("       The readme file file can'be maked visible")
						ok = false
					}
					
				}else{
					log("       The readme file file can'be maked visible because the marking action can't be performed")
					ok = false
				}
				//error handeling
				
			}
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
	func createAIBootFiles(ref: CreationProcess) -> SettingsRes{
		
		guard let o = ref.options.list[.createAIBootFiles]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !(o && !ref.installMac){
			return SettingsRes.resTrueNil
		}
		
		let iaFolder = ref.disk.path + "/.IABootFiles"
		
		do{
			
			if manager.fileExists(atPath: iaFolder){
				log("   .IABootFiles folder already exists")
				
				if try manager.contentsOfDirectory(atPath: iaFolder).isEmpty{
					log(".IABootFiles folders exists, but it's emty, so it will be removed and then replaced with a custom one")
					try manager.removeItem(atPath: iaFolder)
					return createAIBootFiles(ref: ref)
				}
				return SettingsRes.resTrueNil
			}
			
			log("   .IABootFiles folder creation needed")
			
			try manager.createDirectory(atPath: iaFolder, withIntermediateDirectories: true)
			
			let folders = ["/System/Library/CoreServices", "/System/Library/PrelinkedKernels", "/usr/standalone/i386"]
			
			for f in folders{
				let folder = ref.disk.path + f
				
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
	func deleteIAPMID(ref: CreationProcess) -> SettingsRes{
		guard let o = ref.options.list[.deleteIAPhysicalMedia]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !(o && !ref.installMac){
			return SettingsRes.resTrueNil
		}
		
		let iaFile = ref.disk.path + "/.IAPhysicalMedia"
		
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
	
	func createIcon(ref: CreationProcess) -> SettingsRes{
		
		guard let o = ref.options.list[.createIcon]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		
		//trys to create a volumeicon on the target drive if there isn't any, it's used mainly for versions of macOS installer older than 10.13
		do{
			log("   Trying to create the icon on the Bootable macOS installer")
			
			let origin = ref.app.path + "/Contents/Resources/InstallAssistant.icns" //"/Contents/Resources/ProductPageIcon.icns"
			
			if !manager.fileExists(atPath: origin){
				log("   Icon creation failed, the original icon from the macOS installer app was not found")
				//TODO: Translate this messange and the other one
				return SettingsRes(result: false, messange: "TINU failed to apply the installer app icon on the target drive")
			}
			
			let destination = ref.disk.path + "/.VolumeIcon"
			
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
			
			NSWorkspace.shared.setIcon(NSImage.init(contentsOf: URL.init(fileURLWithPath: origin)), forFile: ref.disk.path!, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
			
			log("   Icon file created successfully")
			
			//error handeling
		}catch let error{
			log("   VolumeIcon file creation failed, error: \n\(error)")
			log("!!Error while applying the installer app icon to the target volume!")
			
			return SettingsRes(result: false, messange: "TINU failed to apply the installer app icon on the target drive")
		}
		
		return SettingsRes.resTrueNil
	}
	
	func createTINUCopy(ref: CreationProcess) -> SettingsRes{
		guard let o = ref.options.list[.tinuCopy]?.canBeUsed() else { return SettingsRes.resTrueNil }
		
		if !o { return SettingsRes.resTrueNil }
		//trys to crerate a copy of this app on the mac os install media
		
		do{
			log("   Trying to create a copy of this app on the bootable macOS installer")
			
			var path = ""
			
			//if we have to put the app on a mac os installation, we need to use the app directory
			if ref.installMac{
				try manager.createDirectory(atPath: ref.disk.path + "/Applications", withIntermediateDirectories: true)
				
				path = ref.disk.path + "/Applications/" + (Bundle.main.bundleURL.lastPathComponent)
			}else{
				
				path = (ref.disk.path + "/" + (Bundle.main.bundleURL.lastPathComponent))
				
				if (path == ref.disk.path + "/" + URL.init(fileURLWithPath: ref.app.path, isDirectory: true).lastPathComponent){
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
