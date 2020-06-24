//
//  MediaCreationManagerPostProcesses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{

	func manageSpecialOperations(_ usesNewMethod: Bool) -> Bool{
		var ret = true
		
		DispatchQueue.main.sync {
		self.setProgressValue(self.progressMaxVal - self.processUnit)
		}
		
		DispatchQueue.global(qos: .background).sync {
			
			prepareToPerformSpecialOperations()
			
			let ok = self.performSpeacialOperations()
			
			#if !macOnlyMode
			
			var unmount = true
			
			if let o = oom.shared.otherOptions[oom.OtherOptionID.otherOptionKeepEFIpartID]?.canBeUsed(){
				unmount = !o
			}
			
			if unmount{
				DispatchQueue.main.sync {
				self.setActivityLabelText("Unmounting partitions")
				}
				let _ = self.unmountConflictingDrive()
			}
			
			DispatchQueue.main.sync {
			self.setProgressValue(self.progressMaxVal - self.unit)
			}
			
			#endif
			DispatchQueue.main.sync {
			self.setActivityLabelText("Process ended, exiting ...")
			
				if ok.success{
					//ok the installer creation has been completed with success, so it sets up the final widnow and then it's showed up
					if !sharedInstallMac && !usesNewMethod{
						self.viewController.goToFinalScreen(title: "Bootable macOS installer created successfully", success: true)
					}
					
				}else{
					
					ret = false
					
					//installer creation failed, bacause of an error with the advanced options
					
					if sharedInstallMac{
						
						log("\nOne or more errors detected during the execution of the options, the macOS installation process has been canceld, check the messages printed before this one for more details abut that erros\n")
						
					}else{
						
						log("\nOne or more errors detected during the execution of the advanced options, your bootable macOS installer will probably not work properly, so we sugegst you to restart the whole install media creation process and eventually to format the target drive using terminal or disk utility before using TINU, check the messages printed before this one for more details abut that erros\n")
						
					}
					
					
					if let msg = ok.errorMessage{
						
						self.viewController.goToFinalScreen(title: msg, success: false)
						
					}else{
						
						self.viewController.goToFinalScreen(title: "TINU failed to apply the advanced options on the bootable macOS installer, check the log for details", success: false)
					}
				}
			}
			
		}
		
		return ret
	}
	
	private func prepareToPerformSpecialOperations(){
		if sharedInstallMac{
			if let a = cvm.shared.sharedBSDDriveAPFS{
				cvm.shared.sharedVolume = dm.getDriveNameFromBSDID(a)
			}else{
				cvm.shared.sharedVolume = dm.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive!)
			}
		}else{
			cvm.shared.sharedVolume = dm.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive!)
		}
		
		print(cvm.shared.sharedVolume)
	}
	
	private func checkOperationResult(operation: (result: Bool, message: String?), res: inout Bool) -> String?{
		if !operation.result{
			res = false
			
			return operation.message
		}
		
		return nil
	}
	
	//this function manages some special operations done after createinstallmedia finishes
	private func performSpeacialOperations() -> (success: Bool, errorMessage: String?){
		/*DispatchQueue.main.sync {
			self.viewController.progress.isIndeterminate = false
		}*/
		
		//testing code, exits from the function if we are in some particolar testing conditions
		if simulateNoSpecialOperations{
			return (true, nil)
		}
		
		//DispatchQueue.global(qos: .background).async{
		
		var ok = true
		
		log("\n\nStarting extra operations: ")
		
		if simulateSpecialOperationsFail{
			log("\n     Simulating a failure of the advanced options\n")
			ok = false
		}
		
		//1
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit)
		}
		
		#if useEFIReplacement && !macOnlyMode
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = false
			
			self.startProgress = self.viewController.progress.doubleValue
			
			self.progressRate = self.unit
			
			self.timer.invalidate()
			self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkEFIFolderCopyProcess(_:)), userInfo: nil, repeats: true)
		}
		
		if let m = checkOperationResult(operation: OptionalOperations.shared.mountEFIPartAndCopyEFIFolder(), res: &ok){
			return (ok, m)
		}
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = true
			
			self.setProgressValue(self.startProgress + self.unit)
			
		}
		
		//self.addToProgressValue(step)
		#else
		DispatchQueue.main.sync {
		self.viewController.addToProgressValue(self.unit)
		}
		#endif
		
		//create readme
		if let m = checkOperationResult(operation: OptionalOperations.shared.createReadme(), res: &ok){
			return (ok, m)
		}
		
		//3
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit)
		}
		
		#if !macOnlyMode
		//create IABootFiles folder
		if let m = checkOperationResult(operation: OptionalOperations.shared.createAIBootFiles(), res: &ok){
			return (ok, m)
		}
		#endif
		
		//4
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit)
		}
		
		#if !macOnlyMode
		//delete the IAPhysicalMedia file
		if let m = checkOperationResult(operation: OptionalOperations.shared.deleteIAPMID(), res: &ok){
			return (ok, m)
		}
		#endif
		
		//5
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit)
		}
		
		//gives to the install media the icon of the mac os installer app
		if let m = checkOperationResult(operation: OptionalOperations.shared.createIcon(), res: &ok){
			return (ok, m)
		}
		
		
		//6
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit)
		}
		
		//copyes this app on the mac os install media
		if let m = checkOperationResult(operation: OptionalOperations.shared.createTINUCopy(), res: &ok){
			return (ok, m)
		}
		
		//7 + 8
		DispatchQueue.main.sync {
		self.addToProgressValue(self.unit * 2)
		}
		
		/*
		#if !macOnlyMode
		DispatchQueue.main.sync {
		self.setActivityLabelText("Replacing boot files")
			
			self.EFICopyEnded = false
			
			self.startProgress = self.viewController.progress.doubleValue
			
			self.progressRate = self.unit
			
			self.timer.invalidate()
			self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkBootFilesReplacementProcess(_:)), userInfo: nil, repeats: true)
		}
		
		if let m = checkOperationResult(operation: OptionalOperations.shared.replaceBootFiles(), res: &ok){
			return (ok, m)
		}
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = true
			
			self.setProgressValue(self.startProgress + self.unit)
			
		}
		#endif
*/
		
		//8
		DispatchQueue.main.sync {
		self.setProgressValue(self.progressMaxVal - self.unit)
		
		self.setActivityLabelText("Checking partitions")
		}
		
		return (ok, nil)
	}

}
