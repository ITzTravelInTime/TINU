//
//  MediaCreationManagerPostProcesses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{
	
	func manageSpecialOperations() -> Bool?{
		var ret: Bool? = true
		
		//extra operations here
		//trys to apply special options
		DispatchQueue.main.sync {
			//self.setActivityLabelText("Applaying custom options")
			self.setActivityLabelText("activityLabel5")
		}
		
		DispatchQueue.main.sync {
			self.setProgressValue(self.progressMaxVal - self.processUnit)
		}
		
		DispatchQueue.global(qos: .background).sync {
			
			updateDriveMountPoint()
			
			let ok = self.performSpeacialOperations()
			
			#if !macOnlyMode
			
			if !(cvm.shared.options.list[.keepEFIMounted]?.canBeUsed() ?? false){
				DispatchQueue.main.sync {
					//self.setActivityLabelText("Unmounting partitions")
					self.setActivityLabelText("activityLabel7")
				}
				
				//the result isn't that important here since this is done mostly for cosmetical purposes to not shot the efi partition to the user
				let _ = self.unmountConflictingDrive()
			}
			
			#endif
			
			
			DispatchQueue.main.sync {
				
				self.setProgressValue(self.progressMaxVal - IMCM.unit)
				
				//self.setActivityLabelText("Process ended, exiting...")
				self.setActivityLabelText("activityLabel8")
				
			}
			
			if ok.result == nil{
				ret = nil
				return
			}
			
			if ok.result!{
				return
			}
			
			ret = false
			
			//installer creation failed, bacause of an error with the advanced options
			
			if cvm.shared.installMac{
				
				log("\nOne or more errors detected during the execution of the options, the macOS installation process has been canceld, check the messages printed before this one for more details abut that erros\n")
				
			}else{
				
				log("\nOne or more errors detected during the execution of the advanced options, your bootable macOS installer will probably not work properly, so we sugegst you to restart the whole install media creation process and eventually to format the target drive using terminal or disk utility before using TINU, check the messages printed before this one for more details abut that erros\n")
				
			}
			
			DispatchQueue.main.sync {
				
				if let msg = ok.messange{
					
					self.viewController.goToFinalScreen(title: msg, success: false)
					
				}else{
					
					//self.viewController.goToFinalScreen(title: "TINU failed to apply the advanced options on the bootable macOS installer, check the log for details", success: false)
					
					self.viewController.goToFinalScreen(id: "finalScreenAOE")
				}
			}
			
		}
		
		return ret
	}
	
	private func updateDriveMountPoint(){
		/*if cvm.shared.installMac{
			if let a = cvm.shared.disk.aPFSContaninerBSDDrive{
				cvm.shared.disk.current.path = dm.getMountPointFromPartitionBSDID(a)
			}else{
				cvm.shared.disk.current.path = dm.getMountPointFromPartitionBSDID(cvm.shared.disk.bSDDrive!)
			}
		}else{
			cvm.shared.disk.current.path = dm.getMountPointFromPartitionBSDID(cvm.shared.disk.bSDDrive!)
		}*/
		
		if let a = cvm.shared.disk.aPFSContaninerBSDDrive, cvm.shared.installMac{
			cvm.shared.disk.current.path = a.mountPoint()
		}else{
			cvm.shared.disk.current.path = cvm.shared.disk.bSDDrive?.mountPoint()
		}
		
		log("Disk path set to: " + (cvm.shared.disk.path ?? ""))
	}
	
	private func checkOperationResult(operation: SettingsRes, res: inout Bool) -> String?{
		if !(operation.result ?? false){
			res = false
			
			return operation.messange
		}
		
		return nil
	}
	
	//this function manages some special operations done after createinstallmedia finishes
	private func performSpeacialOperations() -> SettingsRes{
		
		//testing code, exits from the function if we are in some particolar testing conditions
		if simulateNoSpecialOperations != nil{
			log("\n\nSimulating state of the advanced options\n")
			return SettingsRes(result: simulateNoSpecialOperations, messange: "Settings skip test")
		}
		
		/*
		if simulateSpecialOperationsFail{
			log("\n\nSimulating a failure of the advanced options\n")
			return SettingsRes(result: false, messange: "Settings fail test")
		}
		*/
		
		var ok = true
		
		log("\n\nStarting extra operations: ")
		
		//1
		incrementProgressUnit()
		
		#if useEFIReplacement && !macOnlyMode
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = false
			
			self.startProgress = self.viewController.progress.doubleValue
			
			self.progressRate = IMCM.unit
			
			self.timer.invalidate()
			
			self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkEFIFolderCopyProcess(_:)), userInfo: nil, repeats: true)
		}
		/*
		if let m = checkOperationResult(operation: OptionalOperations.shared.mountEFIPartAndCopyEFIFolder(), res: &ok){
			return SettingsRes(result: ok, messange: m)
		}
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = true
			
			self.setProgressValue(self.startProgress + IMCM.unit)
			
		}*/
		
		//self.addToProgressValue(step)
		//#else
		//incrementProgressUnit()
		#endif
		
		var counter: UInt = 0
		
		if simulateSpecialOperationsFail{
			counter = 255
		}
		
		while (ok){
			
			if cvm.shared.process.status != .postCreation{
				log("-------- Operation canceled by user --------")
				return SettingsRes(result: nil, messange: "Operation canceld by the user")
			}
			
			var res = SettingsRes(result: true, messange: nil)
			var ammount: Double = 1
			switch counter{
			case 0:
				#if useEFIReplacement && !macOnlyMode
				log("+Performing EFI folder copy")
				res = Operations.shared.mountEFIPartAndCopyEFIFolder()
				
				if res.result ?? false{
					self.EFICopyEnded = true
					ammount = (self.startProgress + IMCM.unit) * -1
				}
				#endif
				break
			case 1:
				log("+Performing README creation")
				res = Operations.shared.createReadme()
				break
			case 2:
				log("+Performing IABootFiles folder creation")
				res = Operations.shared.createAIBootFiles()
				break
			case 3:
				log("+Performing removal of IAPhysicalMedia")
				res = Operations.shared.deleteIAPMID()
				break
			case 4:
				log("+Perofrming disk icon creation")
				res = Operations.shared.createIcon()
				break
			case 5:
				log("+Performing TINU copy")
				res = Operations.shared.createTINUCopy()
				ammount = 2
				break
			case 255:
				log("--Performing settings fail test")
				res = SettingsRes(result: false, messange: "Settings fail test")
				break
			default:
				ok = false
				break
			}
			
			if !ok{
				continue
			}
			
			counter += 1
			
			if ammount > 0{
				incrementProgressUnit(ammount)
			}else{
				DispatchQueue.main.sync {
					self.setProgressValue(ammount * -1)
				}
			}
			
			if let m = checkOperationResult(operation: res, res: &ok){
				return SettingsRes(result: false, messange: m)
			}
		}
		
		//8
		DispatchQueue.main.sync {
			self.setProgressValue(self.progressMaxVal - IMCM.unit)
			//self.setActivityLabelText("Checking partitions")
			self.setActivityLabelText("activityLabel9")
		}
		
		return SettingsRes(result: true, messange: nil)
	}
	
	private func incrementProgressUnit(_ mul: Double = 1){
		DispatchQueue.main.sync {
			self.addToProgressValue(IMCM.unit * mul)
		}
	}

}
