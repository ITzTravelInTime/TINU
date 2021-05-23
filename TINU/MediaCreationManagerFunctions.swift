//
//  MediaCreationManagerProcesses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{
	
	func killConflictingPrcesses() -> Bool{
		//creates a list of processes to kill
		let processesToClose = ["InstallAssistant", "InstallAssistant_plain", "InstallAssistant_springboard"]
		
		//try to terminate a process that may be still active in backgruound, maybe for a previuos crash of the app or the system
		log("""
			
			***Trying to close conflicting processes
			If those conflicting processes are running,
			they may interfere with the success of
			the \"\(sharedExecutableName)\" operation
			
			""")
		
		var p: String?
		//trys to terminate the process
		if let success = TaskKillManager.terminateAppsWithAsk(byCommonParameter: processesToClose, parameterKind: .executableName, mustBeEqual: true, firstFailedToCloseName: &p){
			if !success{
				log("***Failed to close conflicting processes \(p!)!!!")
				DispatchQueue.main.sync {
					//self.viewController.goToFinalScreen(title: "TINU failed to stop conflicting process \"\(p!)\"", success: false)
					self.viewController.goToFinalScreen(id: "finalScreenCFE", success: false, parseList: ["{process}" : p!])
				}
				return false
			}
		}else{
			log("***Failed to terminate conflicting process: \"" + p! + "\" because the user denid to close it\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if let success = TaskKillManager.terminateProcessWithAsk(name: sharedExecutableName){
			if !success{
				log("***Failed to close conflicting processes \(sharedExecutableName)!!!")
				DispatchQueue.main.sync {
					//self.viewController.goToFinalScreen(title: "TINU failed to stop conflicting process \"\(sharedExecutableName)\"\nTry to restart the computer and try again", success: false)
					self.viewController.goToFinalScreen(id: "finalScreenCFE", success: false, parseList: ["{process}" : sharedExecutableName])
				}
				return false
			}
		}else{
			log("***Failed to terminate conflicting process: \"" + sharedExecutableName + "\" because the user denid to close it\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
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
			the \"\(sharedExecutableName)\" operation
			
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
	
	class func unmountDiskAndGetDiskId(id: String) -> String!{
		//this code gets the bsd name of the drive from the bsd name of the partition selcted
		let tmpBSDName = dm.getDriveBSDIDFromVolumeBSDID(volumeID: id)
		
		log("Disk that will be unmounted: \(tmpBSDName)")
		
		let unmountComm = "diskutil unmountDisk " + tmpBSDName
		
		log("    Disks unmount will be done with command: \n    \(unmountComm)")
		
		if let out = getOutWithSudo(cmd: unmountComm){
			
			print(out)
			
			if out.contains("was successful"){
				return tmpBSDName
			}else{
				return ""
			}
			
		}else{
			print("Auth failed: Emergency remount")
			print(getOut(cmd: "diskutil mount " + id))
		}
		
		return nil
	}
	
	func formatTargetDrive(canFormat: Bool, useAPFS: Bool) -> Bool{
		
		if !canFormat {
			return true
		}
		
		var didChangePS = false
		
		if simulateFormatFail{
			didChangePS = false
			print("Process format fail simulation")
			if sharedInstallMac{
				//self.viewController.goToFinalScreen(title: "TINU failed to format \"\(dname)\" [SIMULATED]", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenCVE", success: false, parseList: ["{volume}" : dname])
			}
			return false
		}
		
		DispatchQueue.main.sync {
			//self.setActivityLabelText("Formatting target drive")
			self.setActivityLabelText("activityLabel6")
		}
		
		log("@@@ Starting drive format process")
		
		log("    The disk needs to be unmounted, in order to be formatted")
		
		guard let tmpBSDName = InstallMediaCreationManager.unmountDiskAndGetDiskId(id: cvm.shared.sharedBSDDrive) else {
			log("@@@ Failed to authenticate to eject the drive!!!!\n[The app made sure that the drive has been re-mounted to let the user to use it]\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if tmpBSDName.isEmpty || cvm.shared.sharedBSDDrive == nil{
			log("@@@ Failed to unmount the disk\n\n")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "Failed to unmount the chosen Disk, check log for more details", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenFUE")
			}
			return false
		}
		
		var newVolumeName = "macOS install media"
		
		if iam.shared.checkSharedBundleName() {
			newVolumeName = cvm.shared.sharedBundleName
		}
		
		//this is the command used to erase the disk and create on just one partition with the GUID table
		let cmd = "diskutil eraseDisk JHFS+ \"" + newVolumeName + "\" /dev/" + tmpBSDName
		
		log("Formatting disk and change partition scheme with the command:\n       " + cmd)
		
		//gets the output of the format script
		//out is nil only if the authentication has failed
		guard let out = getOutWithSudo(cmd: cmd) else{
			log("Failed to perform needed authentication to format target drive\n\n")
			
			print(getOut(cmd: "diskutil mount " + cvm.shared.sharedBSDDrive))
			
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			
			return false
		}
		
		print(out)
		
		//output separated in parts
		let c = out.components(separatedBy: "\n")
		//the text we are looking for
		let finishedMark = "Finished erase on disk"
		
		for _ in 0...0{
			if c.isEmpty{
				log("Failed to get outut from the format process")
				didChangePS = false
				continue
			}
			
			if (c.count <= 1 && c.first!.isEmpty){
				//too less output from the process
				log("Failed to get valid output for the format process")
				didChangePS =  false
				continue
			}
			
			//checks if the erase has been completed with success
			if !c.last!.contains(finishedMark){
				
				//the format has failed, so the boolean is false and a screen with installer creation failed will be displayed
				log("----Volume format process fail: ")
				log("         Format script output: \n" + out)
				
				didChangePS = false
				
				continue
			}
			
			//we can set this boolean to true because the process has been successfoul
			didChangePS = true
			//setup variables for the \createinstall media, the target partition is always the second partition into the drive, the first one is the EFI partition
			cvm.shared.sharedBSDDrive = "/dev/" + tmpBSDName + "s2"
			
			if sharedInstallMac{
				cvm.shared.sharedBSDDriveAPFS = nil
			}
			
			cvm.shared.sharedVolume = dm.getMountPointFromPartitionBSDID(cvm.shared.sharedBSDDrive)
			
			if cvm.shared.sharedVolume == nil{
				//cvm.shared.sharedVolume = "/Volumes/" + newVolumeName
				cvm.shared.sharedVolume = dm.getMountPointFromPartitionBSDID(cvm.shared.sharedBSDDrive)
			}
			
			DispatchQueue.main.async {
				if let name = cvm.shared.sharedVolume{
					self.viewController.driveImage.image = NSWorkspace.shared.icon(forFile: name)
					self.viewController.driveName.stringValue += "\n(" + TextManager.getViewString(context: self, stringID: "renamed") + " " + FileManager.default.displayName(atPath: name) + ")"
				}
				
				log("@@@Volume format process ended with success\n\n")
			}
		}
		
		//if the drive has benn successfully formatted, procede
		if !didChangePS {
			
			//here the format script to erase the drive has failed, we also need to realse permitions here
			
			DispatchQueue.main.sync {
				log("Process failed, drive format or partition table changement failed, please erase this drive manually with disk utility and then retry")
				//the driver format has failed, so it does setup the final windows to show the failure an the error and then it's called
				
				//if sharedInstallMac{
					//self.viewController.goToFinalScreen(title: "TINU failed to format \"\(dname)\"", success: false)
					
				self.viewController.goToFinalScreen(id: "finalScreenFFE", success: false, parseList: ["{diskName}": dname])
				
				//}
			}
			
			return false
			
		}
		
		return true
	}
	
	public func OtherOptionsBeforeformat(canFormat: inout Bool, useAPFS: inout Bool){
		log("\n\nStarting extra operations before launching the executable")
		
		//checks the options to use in this function
		if !simulateFormatSkip{
			if let s = cvm.shared.sharedVolumeNeedsPartitionMethodChange {
				canFormat = s
			}
			
			if !canFormat {
				if let o = oom.shared.otherOptions[.otherOptionForceToFormatID]?.canBeUsed(){
					if o && !simulateFormatSkip{
						canFormat = true
						log("   Forced drive erase enabled")
					}
				}
			}
		}
		
		if sharedInstallMac{
			if let o = oom.shared.otherOptions[.otherOptionDoNotUseApfsID]?.canBeUsed(){
				if o {
					useAPFS = false
					log("   Forced APFS automatic upgrade enabled")
				}
			}
		}
		
		log("Finished extra operations before launching the executable\n\n")
	}
	
	func buildCommandString(useAPFS: Bool) -> String{
		
		let isNotMojave = iam.shared.installerAppGoesUpToThatVersion(version: 14.0)!
		//let isNotCatalina = iam.shared.installerAppGoesUpToThatVersion(version: 15.0)!
		
		//this is the name of the executable we need to use now
		let pname = sharedExecutableName
		
		//this strting is used to define the main command to use, then the prefix is added
		var mainCMD = "\"\(cvm.shared.sharedApp!)/Contents/Resources/\(pname)\" --volume \"\(cvm.shared.sharedVolume!)\""
		
		//mojave instalelr do not supports this argument
		//if isNotMojave || !isNotCatalina{
			//log("This is an older macOS installer app, it needs the --applicationpath argument to use " + pname)
		mainCMD += " --applicationpath \"\(cvm.shared.sharedApp!)\""
		//}
		
		//if tinu have to create a mac os installation on the selected drive
		if sharedInstallMac{
			
			///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
			var noAPFSSupport = true
			
			//check if the version of the installer does not supports apfs
			if let ap = iam.shared.sharedAppNotSupportsAPFS(){
				noAPFSSupport = ap
			}
			
			mainCMD += " --agreetolicense"
			
			//the command is adjusted if the version of the installer supports apfs and if the user prefers to avoid upgrading to apfs
			if !noAPFSSupport || !isNotMojave{
				if useAPFS || cvm.shared.sharedBSDDriveAPFS != nil{
					mainCMD += " --converttoapfs YES"
				}else{
					mainCMD += " --converttoapfs NO"
				}
			}
			
		}else{
			//we are just on the standard createinstallmedia, so let's add what is missing
			mainCMD += " --nointeraction"
		}
		
		//this code is used to simulate results of createinstallmedia, saves time hen tesing the fial screen
		if let scf = simulateCreateinstallmediaFail{
			
			//just for debug, prints the real command generated by the code
			log("Real command: " + mainCMD)
			
			if simulateCreateinstallmediaFailCustomMessage.isEmpty{
				
				//replace with the test commands
				if !scf{
					if !isNotMojave{
						mainCMD = "echo \"Install media now available at \"\(cvm.shared.sharedVolume!)\"\""
					}else{
						mainCMD = "echo \"done test\""
					}
				}else{
					mainCMD = "echo \"failed test\""
				}
				
			}else{
				mainCMD = "echo \"\(simulateCreateinstallmediaFailCustomMessage)\""
			}
			
		}
		
		return mainCMD
	}
	
	//this function trys to unmount installesd is it'f mounted because it can create problems with the install process
	func unmountConflictingDrive() -> Bool{
		//unmount drive efi partition
		var res = true
		
		#if !macOnlyMode
		
		DispatchQueue.global(qos: .background).sync {
			
			let efiMan = EFIPartitionManager()
			
			log("    Unmounting EFI partitions")
			
			efiMan.buildPartitionsCache()
			
			if let ps = efiMan.listPartitions(){
				
				for p in ps{
					log("      Unmounting EFI partition \(p)")
					if !efiMan.unmountPartition(p){
						res = false
						log("      Unmounting EFI partition \(p) failed!!!")
					}
				}
				
			}
			
			efiMan.clearPartitionsCache()
			
			if res{
				log("    EFI partitions unmounted correctly")
			}
		}
		
		#endif
		
		
		
		let remooveHardcoded = ["InstallESD", "OS X InstallESD"]
		
		for r in remooveHardcoded{
			for i in 1...10{
				let path = "/Volumes/" + r + ((i > 1) ? (" " + String(i)) : "")
				
				log("    Unmounting \"\(path)\"")
				
				if !dm.driveHasID(path: path) {
					continue
				}
				
				if !NSWorkspace.shared.unmountAndEjectDevice(atPath: path){
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
