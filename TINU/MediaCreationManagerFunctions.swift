/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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
import CommandSudo
import TINURecovery

extension InstallMediaCreationManager{
	
	func killConflictingPrcesses() -> Bool{
		//creates a list of processes to kill
		let processesToClose = ["InstallAssistant", "InstallAssistant_plain", "InstallAssistant_springboard"]
		
		//try to terminate a process that may be still active in backgruound, maybe for a previuos crash of the app or the system
		log("""
			
			***Trying to close conflicting processes
			If those conflicting processes are running,
			they may interfere with the success of
			the \"\(self.ref!.pointee.actualExecutableName)\" operation
			
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
		
		guard let successb = TaskKillManager.terminateProcessWithAsk(name: self.ref!.pointee.actualExecutableName) else{
			log("***Failed to terminate conflicting process: \"" + self.ref!.pointee.actualExecutableName + "\" because the user denid to close it\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		if !successb{
			log("***Failed to close conflicting processes \(self.ref!.pointee.actualExecutableName)!!!")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "TINU failed to stop conflicting process \"\(sharedExecutableName)\"\nTry to restart the computer and try again", success: false)
				self.viewController.goToFinalScreen(id: "finalScreenCFE", success: false, parseList: ["{process}" : self.ref!.pointee.actualExecutableName])
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
			the \"\(self.ref!.pointee.actualExecutableName)\" operation
			
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
			if self.ref!.pointee.installMac{
				//self.viewController.goToFinalScreen(title: "TINU failed to format \"\(dname)\" [SIMULATED]", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenCVE", success: false, parseList: ["{volume}" : self.ref!.pointee.disk.current.driveName])
			}
			return false
		}
		
		DispatchQueue.main.sync {
			//self.setActivityLabelText("Formatting target drive")
			self.setActivityLabelText("activityLabel6")
		}
		
		log("@@@ Starting drive format process")
		
		log("    The disk needs to be unmounted, in order to be formatted")
		
		guard let unmount = InstallMediaCreationManager.unmountDiskAndGetDiskId(id: self.ref!.pointee.disk.bSDDrive) else {
			log("@@@ Failed to authenticate to eject the drive!!!!\n[The app made sure that the drive has been re-mounted to let the user to use it]\n\n")
			DispatchQueue.main.sync {
				self.viewController.goBack()
			}
			return false
		}
		
		let tmpBSDName = self.ref!.pointee.disk.bSDDrive?.driveID
		
		if !unmount || tmpBSDName == nil{
			log("@@@ Failed to unmount the disk\n\n")
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "Failed to unmount the chosen Disk, check log for more details", success: false)
				
				self.viewController.goToFinalScreen(id: "finalScreenFUE")
			}
			return false
		}
		
		let newVolumeName = self.ref!.pointee.app.info.bundleName ?? (self.ref!.pointee.installMac ? "Macintosh HD" : "macOS install media")
		
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
				
				self.viewController.goToFinalScreen(id: "finalScreenFFE", success: false, parseList: ["{diskName}": self.ref!.pointee.disk.current.driveName])
				
				//}
			}
			
			return false
		}
		
		let oldPart = self.ref!.pointee.disk.current
		let newBSD = BSDID(tmpBSDName!.rawValue + "s2")
		let newPart = Part(bsdName: newBSD, fileSystem: .hFS, isGUID: true, hasEFI: true, size: oldPart!.size, isDrive: false, path: newBSD.mountPoint(), support: .ok)
		
		self.ref!.pointee.disk.current = newPart
		
		self.ref!.pointee.options.list[.forceToFormat]?.isActivated = false
		self.ref!.pointee.options.list[.forceToFormat]?.isUsable = true
		
		DispatchQueue.main.async {
			guard let name = self.ref!.pointee.disk.current else{ return }
			let old = self.viewController.driveName.stringValue
			
			sharedSetSelectedCreationUI(appName: &self.viewController.appName, appImage: &self.viewController.appImage, driveName: &self.viewController.driveName, driveImage: &self.viewController.driveImage, manager: self.ref!.pointee, useDriveName: self.ref!.pointee.disk.current.isDrive || self.ref!.pointee.disk.shouldErase)
			
			//self.viewController.driveImage.image = name.genericIcon
			self.viewController.driveName.stringValue = old + "\n(" + TextManager.getViewString(context: self, stringID: "renamed") + " " + FileManager.default.displayName(atPath: name.path!) + ")"
			
			log("@@@Volume format process ended with success\n\n")
		}
		
		return true
	}
	
	func buildCommandStringNew(process: CreationProcess) -> ExecInfo{
		var mainCMD = [String]()
		var exec = ""
		if process.app.current.status == .legacy && !process.installMac{
			mainCMD.append("restore")
			if CurrentUser.isRoot{
				mainCMD.append("--source")
				mainCMD.append(process.app.path + "/Contents/SharedSupport/InstallESD.dmg")
			}else{
				mainCMD.append("--source \"\(process.app.path + "/Contents/SharedSupport/InstallESD.dmg")\"")
			}
			
			if CurrentUser.isRoot{
				mainCMD.append("--target")
				mainCMD.append(process.disk.path!)
			}else{
				mainCMD.append("--target \"\(process.disk.path!)\"")
			}
			
			mainCMD.append("--erase")
			mainCMD.append("--noprompt")
			
			exec = "\"/usr/sbin/asr\""
			
		}else{
			
			if CurrentUser.isRoot{
				mainCMD.append("--volume")
				mainCMD.append(process.disk.path!)
			}else{
				mainCMD.append("--volume \"\(process.disk.path!)\"")
			}
			
			if process.app.info.goesUpTo(version: 14.0) {
				if CurrentUser.isRoot{
					mainCMD.append("--applicationpath")
					mainCMD.append(process.app.path!)
				}else{
					mainCMD.append("--applicationpath \"\(process.app.path!)\"")
				}
			}
			
			if process.installMac{
				
				///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
				
				mainCMD.append("--agreetolicense")
				
				//the command is adjusted if the version of the installer supports apfs and if the user prefers to avoid upgrading to apfs
				
				if !(process.app.info.notSupportsAPFS() ?? true) || !process.app.info.goesUpTo(version: 14.0){
					let shouldConvert = process.options.execution.canUseApfs || process.disk.aPFSContaninerBSDDrive != nil
					if CurrentUser.isRoot{
						mainCMD.append("--converttoapfs")
						mainCMD.append(shouldConvert ? "YES" : "NO")
					}else if shouldConvert{
						mainCMD.append("--converttoapfs YES")
					}else{
						mainCMD.append("--converttoapfs NO")
					}
				}
				
			}else{
				//we are just on the standard createinstallmedia, so let's add what is missing
				mainCMD.append("--nointeraction")
			}
			
			exec = "\"\(process.app.path!)/Contents/Resources/\(process.executableName)\""
			
		}
		
		if CurrentUser.isRoot{
			exec.removeFirst()
			exec.removeLast()
		}
		
		//this code is used to simulate results of createinstallmedia, saves time hen tesing the fial screen
		if let scf = simulateCreateinstallmediaFail{
			mainCMD = ["-c"]
			exec = "/bin/sh"
			
			//just for debug, prints the real command generated by the code
			log("Real command: " + mainCMD.stringLine())
			
			if simulateCreateinstallmediaFailCustomMessage.isEmpty{
				
				//replace with the test commands
				if !scf{
					if !process.app.info.goesUpTo(version: 14.0){
						mainCMD.append("echo \"Install media now available at \(self.ref!.pointee.disk.path!) \"")
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
	
	func buildCommandString(useAPFS: Bool) -> ExecInfo{
		
		let isNotMojave = self.ref!.pointee.app.info.goesUpTo(version: 14.0)!
		//let isNotCatalina = cvm.shared.app.info.goesUpTo(version: 15.0)!
		
		//this string is used to define the main command to use, then the prefix is added
		
		var mainCMD = [String]()
		
		if CurrentUser.isRoot{
			mainCMD.append("--volume")
			mainCMD.append(self.ref!.pointee.disk.path!)
		}else{
			mainCMD.append("--volume \"\(self.ref!.pointee.disk.path!)\"")
		}
		
		//mojave instalelr do not supports this argument
		//if isNotMojave || !isNotCatalina{
			//log("This is an older macOS installer app, it needs the --applicationpath argument to use " + pname)
		if CurrentUser.isRoot{
			mainCMD.append("--applicationpath")
			mainCMD.append(self.ref!.pointee.app.path!)
		}else{
			mainCMD.append("--applicationpath \"\(self.ref!.pointee.app.path!)\"")
		}
		//}
		
		//if tinu have to create a mac os installation on the selected drive
		if self.ref!.pointee.installMac{
			
			///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
			
			mainCMD.append("--agreetolicense")
			
			//the command is adjusted if the version of the installer supports apfs and if the user prefers to avoid upgrading to apfs
			
			if !(self.ref!.pointee.app.info.notSupportsAPFS() ?? true) || !isNotMojave{
				let shouldConvert = useAPFS || self.ref!.pointee.disk.aPFSContaninerBSDDrive != nil
				if CurrentUser.isRoot{
					mainCMD.append("--converttoapfs")
					mainCMD.append(shouldConvert ? "YES" : "NO")
				}else if shouldConvert{
					mainCMD.append("--converttoapfs YES")
				}else{
					mainCMD.append("--converttoapfs NO")
				}
			}
			
		}else{
			//we are just on the standard createinstallmedia, so let's add what is missing
			mainCMD.append("--nointeraction")
		}
		
		var exec = "\"\(self.ref!.pointee.app.path!)/Contents/Resources/\(self.ref!.pointee.executableName)\""
		
		if CurrentUser.isRoot{
			exec.removeFirst()
			exec.removeLast()
		}
		
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
						mainCMD.append("echo \"Install media now available at \(self.ref!.pointee.disk.path!) \"")
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
