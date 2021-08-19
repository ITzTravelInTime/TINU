//
//  MediaCreationManagerProcesses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa
import Command
import CommandSudo

extension InstallMediaCreationManager{
	
	func killConflictingPrcesses() -> Bool{
		//creates a list of processes to kill
		let processesToClose = ["InstallAssistant", "InstallAssistant_plain", "InstallAssistant_springboard"]
		
		//try to terminate a process that may be still active in backgruound, maybe for a previuos crash of the app or the system
		log("""
			
			***Trying to close conflicting processes
			If those conflicting processes are running,
			they may interfere with the success of
			the \"\(cvm.shared.executableName)\" operation
			
			""")
		
		var p: String?
		//trys to terminate the process
		guard let successa = TaskKillManager.terminateAppsWithAsk(byCommonParameter: processesToClose, parameterKind: .executableName, mustBeEqual: true, firstFailedToCloseName: &p) else{
			log("***Failed to terminate conflicting process: \"" + p! + "\" because the user denid to close it\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if !successa{
			log("***Failed to close conflicting processes \(p!)!!!")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "TINU failed to stop conflicting process \"\(p!)\"", success: false)
				self.viewController.goToFinalScreen(id: "finalScreenCFE", success: false, parseList: ["{process}" : p!])
			}
			return false
		}
		
		guard let successb = TaskKillManager.terminateProcessWithAsk(name: cvm.shared.executableName) else{
			log("***Failed to terminate conflicting process: \"" + cvm.shared.executableName + "\" because the user denid to close it\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if !successb{
			log("***Failed to close conflicting processes \(cvm.shared.executableName)!!!")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "TINU failed to stop conflicting process \"\(sharedExecutableName)\"\nTry to restart the computer and try again", success: false)
				self.viewController.goToFinalScreen(id: "finalScreenCFE", success: false, parseList: ["{process}" : cvm.shared.executableName])
			}
			return false
		}
		
		
		log("***No conflicting processes found or conflicting processes closed with success")
		
		return true
	}
	
	func unmountConflictingVolumes() -> Bool{
		//trys to unmount possible conflicting drives that may interfere, like install esd
		log("""
			
			###Trying to unmount conflicting volumes
			Those volumes may be mounted images
			from inside the macOS installer app
			and may interfere with the success of
			the \"\(cvm.shared.executableName)\" operation
			
			""")
		
		//trys to unmount install esd because it can create
		if self.unmountConflictingDrive(){
			log("###Conflicting volumes unmounted with success or already unmounted")
		}else{
			log("###Failed to unmount conflicting volumes!!!")
			DispatchQueue.main.async {
				//self.viewController.goToFinalScreen(title: "TINU failed to unmount conflicting volumes", success: false)
				self.viewController.goToFinalScreen(id: "finalScreenCVGE")
			}
			
			return false
		}
		
		return true
	}
	
	class func unmountDiskAndGetDiskId(id: BSDID) -> Bool?{
		let tmpBSDName = id.driveID
		
		log("Disk that will be unmounted: \(tmpBSDName.rawValue)")
		
		guard let res = Diskutil.unmount(bsdID: tmpBSDName, useAdminPrivileges: true) else { return nil }
		
		return res
	}
	
	func formatTargetDrive() -> Bool{
		
		if simulateFormatFail{
			print("Process format fail simulation")
			if cvm.shared.installMac{
				//self.viewController.goToFinalScreen(title: "TINU failed to format \"\(dname)\" [SIMULATED]", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenCVE", success: false, parseList: ["{volume}" : cvm.shared.disk.current.driveName])
			}
			return false
		}
		
		DispatchQueue.main.sync {
			//self.setActivityLabelText("Formatting target drive")
			self.setActivityLabelText("activityLabel6")
		}
		
		log("@@@ Starting drive format process")
		
		log("    The disk needs to be unmounted, in order to be formatted")
		
		guard let unmount = InstallMediaCreationManager.unmountDiskAndGetDiskId(id: cvm.shared.disk.bSDDrive) else {
			log("@@@ Failed to authenticate to eject the drive!!!!\n[The app made sure that the drive has been re-mounted to let the user to use it]\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		let tmpBSDName = cvm.shared.disk.bSDDrive?.driveID
		
		if !unmount || tmpBSDName == nil{
			log("@@@ Failed to unmount the disk\n\n")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "Failed to unmount the chosen Disk, check log for more details", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenFUE")
			}
			return false
		}
		
		let newVolumeName = cvm.shared.app.info.bundleName ?? (cvm.shared.installMac ? "Macintosh HD" : "macOS install media")
		
		guard let res = Diskutil.eraseHFS(bsdID: tmpBSDName!, newVolumeName: newVolumeName, useAdminPrivileges: true) else {
			log("@@@Volume format process aborted by the user, going back")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if !res {
			DispatchQueue.main.sync {
				log("Process failed, drive format or partition table changement failed, please erase this drive manually with disk utility and then retry")
				
				//self.viewController.goToFinalScreen(title: "TINU failed to format \"\(dname)\"", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenFFE", success: false, parseList: ["{diskName}": cvm.shared.disk.current.driveName])
				
				//}
			}
			
			return false
		}
		
		let oldPart = cvm.shared.disk.current
		let newBSD = BSDID(tmpBSDName!.rawValue + "s2")
		let newPart = Part(bsdName: newBSD, fileSystem: .hFS, partScheme: oldPart!.partScheme, hasEFI: true, size: oldPart!.size, isDrive: false, path: newBSD.mountPoint())
		
		cvm.shared.disk.current = newPart
		
		cvm.shared.options.list[.forceToFormat]?.isActivated = false
		cvm.shared.options.list[.forceToFormat]?.isUsable = true
		
		DispatchQueue.main.async {
			guard let name = cvm.shared.disk.current else{ return }
			let old = self.viewController.driveName.stringValue
			
			sharedSetSelectedCreationUI(appName: &self.viewController.appName, appImage: &self.viewController.appImage, driveName: &self.viewController.driveName, driveImage: &self.viewController.driveImage, manager: cvm.shared, useDriveName: cvm.shared.disk.current.isDrive || cvm.shared.disk.shouldErase)
			
			//self.viewController.driveImage.image = name.genericIcon
			self.viewController.driveName.stringValue = old + "\n(" + TextManager.getViewString(context: self, stringID: "renamed") + " " + FileManager.default.displayName(atPath: name.path!) + ")"
			
			log("@@@Volume format process ended with success\n\n")
		}
		
		return true
	}
	
	
	
	func buildCommandString(useAPFS: Bool) -> ExecInfo{
		
		let isNotMojave = cvm.shared.app.info.goesUpTo(version: 14.0)!
		//let isNotCatalina = cvm.shared.app.info.goesUpTo(version: 15.0)!
		
		//this string is used to define the main command to use, then the prefix is added
		
		var mainCMD = ["--volume \"\(cvm.shared.disk.path!)\""]
		
		//mojave instalelr do not supports this argument
		//if isNotMojave || !isNotCatalina{
			//log("This is an older macOS installer app, it needs the --applicationpath argument to use " + pname)
		mainCMD.append("--applicationpath \"\(cvm.shared.app.path!)\"")
		//}
		
		//if tinu have to create a mac os installation on the selected drive
		if cvm.shared.installMac{
			
			///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
			
			mainCMD.append("--agreetolicense")
			
			//the command is adjusted if the version of the installer supports apfs and if the user prefers to avoid upgrading to apfs
			if !(cvm.shared.app.info.notSupportsAPFS() ?? true) || !isNotMojave{
				if useAPFS || cvm.shared.disk.aPFSContaninerBSDDrive != nil{
					mainCMD.append("--converttoapfs YES")
				}else{
					mainCMD.append("--converttoapfs NO")
				}
			}
			
		}else{
			//we are just on the standard createinstallmedia, so let's add what is missing
			mainCMD.append("--nointeraction")
		}
		
		var exec = "\"\(cvm.shared.app.path!)/Contents/Resources/\(cvm.shared.executableName)\""
		
		//this code is used to simulate results of createinstallmedia, saves time hen tesing the fial screen
		if let scf = simulateCreateinstallmediaFail{
			mainCMD = ["-c"]
			exec = "/bin/sh"
			
			//just for debug, prints the real command generated by the code
			log("Real command: " + mainCMD.stringLine())
			
			if simulateCreateinstallmediaFailCustomMessage.isEmpty{
				
				//replace with the test commands
				if !scf{
					if !isNotMojave{
						mainCMD.append("echo \"Install media now available at \(cvm.shared.disk.path!) \"")
					}else{
						mainCMD.append("echo \"done test\"")
					}
				}else{
					mainCMD.append("echo \"failed test\"")
				}
				
			}else{
				mainCMD.append("echo \"\(simulateCreateinstallmediaFailCustomMessage)\"")
			}
			
		}
		
		return ExecInfo(path: exec, args: mainCMD, shouldNotUseSudo: simulateCreateinstallmediaFail == nil)
	}
	
	//this function trys to unmount installesd is it'f mounted because it can create problems with the install process
	func unmountConflictingDrive() -> Bool{
		//unmount drive efi partition
		var res = true
		
		#if !macOnlyMode
		
		DispatchQueue.global(qos: .background).sync {
			
			log("    Unmounting EFI partitions")
			
			res = EFIPartition.unmountAllPartitions()
			
			if res{
				log("    EFI partitions unmounted correctly")
			}
			
			EFIPartition.clearPartitionsCache()
		}
		
		#endif
		
		let removeHardcoded = ["InstallESD", "OS X InstallESD"]
		
		for r in removeHardcoded{
			for i in 1...10{
				let path = "/Volumes/" + r + ((i > 1) ? (" " + String(i)) : "")
				
				log("    Unmounting \"\(path)\"")
				
				/*
				if !dm.driveHasID(path: path) {
					continue
				}
				*/
				
				if !FileManager.default.fileExists(atPath: path){
					continue
				}
				
				if !Diskutil.eject(mountedDiskAtPath: path){
					res = false
				}else{
					log("    \"\(path)\" unmounted correctly or already unmounted")
				}
			}
		}
		
		/*
		log("    Unmounting \"Shared Support\"")
		if dm.driveExists(path: "/Volumes/Shared Support") {
			if !NSWorkspace.shared().unmountAndEjectDevice(atPath: "/Volumes/Shared Support"){
				res = false
			}else{
				log("    \"Shared Support\" unmounted correctly or already unmounted")
			}
		}
		*/
		
		return res
	}
	
}
