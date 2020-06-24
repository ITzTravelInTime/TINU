//
//  MediaCreationManagerErrorChecking.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{

	func installFinished(){
		
		DispatchQueue.global(qos: .background).async {
		
		//now the installer creation process has finished running, so our boolean must be false now
		CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
		
			DispatchQueue.main.async {
			
		self.setActivityLabelText("Interpreting the results of the process")
		
			}
		
		log("process took " + String(self.seconds) + " seconds to finish")
		
		DispatchQueue.main.sync {
			//we have finished, so the controls opf the window are restored
			if let w = sharedWindow{
				w.isMiniaturizeEnaled = true
				w.isClosingEnabled = true
				w.canHide = true
			}
		}
		
		//this code get's the output of teh process
		let outdata = CreateinstallmediaSmallManager.shared.outputPipe.fileHandleForReading.readDataToEndOfFile()
		if var string = String(data: outdata, encoding: .utf8) {
			string = string.trimmingCharacters(in: .newlines)
			self.output = string.components(separatedBy: "\n")
		}
		
		//this code gets the errors of the process
		let errdata = CreateinstallmediaSmallManager.shared.errorPipe.fileHandleForReading.readDataToEndOfFile()
		if var string = String(data: errdata, encoding: .utf8) {
			string = string.trimmingCharacters(in: .newlines)
			self.error = string.components(separatedBy: "\n")
		}
		
		//if there is a not normal code it will be logged
		log("\"\(sharedExecutableName)\" has finished")
		
		log("process output produced: ")
			
			if self.output.isEmpty{
				if let data = String(data: outdata, encoding: .utf8){
					log(data)
				}
			}else if self.output.first!.isEmpty{
				if let data = String(data: outdata, encoding: .utf8){
					log(data)
				}
			}else{
			
				//logs the output of the process
				for o in self.output{
					log("      " + o)
				}
				
			}
		
		//if the output is empty opr if it's just the standard output of the creation process, it's not logged
		if !self.error.isEmpty{
			if !((self.error.first?.contains("Erasing Disk: 0%... 10%... 20%... 30%...100%"))! && self.error.first == self.error.last){
				
				log("process error/s produced: ")
				//logs the errors produced by the process
				for o in self.error{
					log("      " + o)
				}
			}
		}else{
			if let data = String(data: errdata, encoding: .utf8){
				log("process error/s produced: ")
				log(data)
			}
		}
			
		self.analizeError()
			
		}
	}
	
	private struct CheckItem{
		
		enum Operations{
			case contains
			case equal
			case different
		}
		
		let stringsToCheck: [String?]
		let valuesToCheck: [String]
		let printMessage: String
		let message: String
		let notError: Bool
		
		var operation: Operations = .contains
		
		var isBack = false
	}
	
	private func analizeError(){
		
		DispatchQueue.global(qos: .background).async {
			
			//gets the termination status for comparison
			var rc = CreateinstallmediaSmallManager.shared.process.terminationStatus
			
			//code used to test if the process has exited with an abnormal code
			if simulateAbnormalExitcode{
				rc = 1
			}
			
			//if the exit code produced is not normal, it's logged
			
			DispatchQueue.main.sync {
			self.setActivityLabelText("Checking previous operations")
			}
			log("Checking the \(sharedExecutableName) process")
			
			if sharedInstallMac{
				DispatchQueue.main.sync {
					//102030100
					if (rc == 0){
						self.viewController.goToFinalScreen(title: "macOS installed successfully", success: true)
					}else{
						self.viewController.goToFinalScreen(title: "macOS installation error: check the log for details", success: false)
					}
					
				}
				
				return
			}
			
			var px = 0, fe: String!, me: String!, le: String!, lo: String!, llo: String!, tt: String!
			
			if !simulateCreateinstallmediaFailCustomMessage.isEmpty && simulateAbnormalExitcode{
				tt = simulateCreateinstallmediaFailCustomMessage
			}
			
				fe = self.error.first
				if self.error.indices.contains(1){
					me = self.error[1]
				}else{
					me = nil
				}
				le = self.error.last
				
				
				//fo = self.output.first
				lo = self.output.last
				
				llo = self.output.last?.lowercased()
				
				var mol = 1
				
				if le != nil{
					for c in le.reversed(){
						if c == ")"{
							px = 0
							mol = 1
						}
					
						if let n = Int(String(c)){
							px += n * mol;
							mol *= 10
						}
					
						if c == "("{
							break
						}
					}
				}
			
			
			let success = ((rc == 0) && (px == 0)) || (isRootUser && (px == 102030100) && (rc == 0)) //add rc to the root case
			
			log("Current user:                       \(NSUserName())")
			log("Main process exit code:             \(px)")
			log("process exit code produced:         \(rc)")
			log("Detected process outcome:           \(success ? "Positive" : "Negative")")
			
			var errorsList: [CheckItem] = []
			
			if !success{
				
				/*


				WARNINING: do not change the text of the arrays after valuesToCheck: in the errors list append, those are essential to let the errors of createinstallmedia to be detected.


				*/
				
				//add new known errors here
				
				//   |   |   |   |   |
				//  \/  \/  \/  \/  \/
				
				
				
				//   /\  /\  /\  /\  /\
				//   |   |   |   |   |
				
				//checks for known errors first
				
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, lo], valuesToCheck: ["A error occurred erasing the disk."], printMessage: "Bootable macOS installer creation failed, createinstallmedia returned an error while formatting the installer partition, please, erase manually this dirve with disk utility and retry", message: "TINU creation failed to format \"\(self.dname)\"", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["does not appear to be a valid OS installer application"], printMessage: "macOS install media creation failed, createinstallmedia returned an error about the app you are using, please, check your mac installaltion app and if needed download it again. Many thimes this appens ,because the installer downloaded from the mac app store, does not contains all the needed files or contanins wrong or corrupted files, in many cases the mac app store on a virtual machine does not downloads the full macOS installer application", message: "Bootable macOS installer creation failed because the selected macOS installer app is damaged or invalid", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["is not a valid volume mount point"], printMessage: "Bootable macOS installer creation failed because the selected volume is no longer available", message: "Bootable macOS installer creation failed because the drive \"\(self.dname)\" is no longer available", notError: false, operation: .contains, isBack: false))
				
				if #available(OSX 10.15, *){
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["IA app name cookie write failed"], printMessage: "Bootable macOS installer creation failed because of an error while copying needed files, make sure that \"\(self.dname)\" is working correctly and that the SIP is disasbled, the SIP enabled can be the real issue in mac versions from Catalina and newer", message: "Bootable macOS installer creation failed because the SIP (System Integrity Protection) is enabled, please disable it and retry", notError: false, operation: .contains, isBack: false))
				}
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["The copy of the installer app failed"], printMessage: "Bootable macOS installer creation failed because the process failed to copy some elements on it, mainly the installer app or it's content, can't be copied or failed to be copied, please check that your target driver is working properly and just in case erase it with disk utility, if that does not work, use another working target device", message: "Bootable macOS installer creation failed because of an error while copying needed files, make sure that \"\(self.dname)\" is working correctly", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [fe, le, me, lo], valuesToCheck: ["The bless of the installer disk failed"], printMessage: "Bootable macOS installer creation failed because \"\(sharedExecutableName)\" was suddenly closed or crashed, probably due to some killing or by the computer going into a sleep state.", message: "Bootable macOS installer creation failed: The creation process was suddenly closed, make sure that the computer doesn't go in standby mode during the creation process.", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["To use this tool, you must download the macOS installer application on a Mac with"], printMessage: "Installer app not supprted by this mac os version", message: "Bootable macOS installer creation failed: The installer app seems not to be compatible with your mac os version or it wasn't properly downloaded, it's reccomended to re-download it from the App Store or to use a different macOS version", notError: false, operation: .contains, isBack: false))
				
				//To use this tool, you must download the macOS installer application on a Mac with 10.12.5 or later, or El Capitan 10.11.6. For more information, please see the following: https://support.apple.com/kb/HT201372
				
				
				//if simulateUseScriptAuth{
					/*
					//then if the proces has not been completed correclty, probably we have an error output or an unknown output
					errorsList.append(CheckItem(stringsToCheck: ["\(rc)", "\(px)"], valuesToCheck: ["0"], printMessage: "macOS install media creation failed, unknown output from \"createinstallmedia\" while creating the installer, please, erase this dirve with disk utility and retry", message: "macOS install media creation failed because of an unknown output from \"\(sharedExecutableName)\", check the log for details", notError: false, operation: .equal, isBack: false))
					*/
					
					// checks if the cancel button was pressed in the apple script auth
					errorsList.append(CheckItem(stringsToCheck: [fe], valuesToCheck: ["NO"], printMessage: "script auth cancelled by user", message: "", notError: false, operation: .contains, isBack: true))
					
					errorsList.append(CheckItem(stringsToCheck: [le], valuesToCheck: ["execution error:", "(-128)"], printMessage: "Apple script operation cancelled, going to previous screen", message: "", notError: false, operation: .contains, isBack: true))
					
				//}
				
				
				//then checks for unknown errors
				errorsList.append(CheckItem(stringsToCheck: ["\(rc)","\(px)"], valuesToCheck: ["0", "102030100"], printMessage: "Bootable macOS installer creation exited with a not normal exit code, see previous lines in the log to get more info about the error", message: "Bootable macOS installer creation failed because of an unknown error, check the log for details", notError: false, operation: .different, isBack: false))
				
				
			}else{
				
				//then checks if the process was completed correctly
				errorsList.append(CheckItem(stringsToCheck: [llo], valuesToCheck: ["done", "install media now available at "], printMessage: "Bootable macOS installer created successfully!", message: "Bootable macOS installer created successfully", notError: true, operation: .contains, isBack: false))
				
				//then if the proces has not been completed correclty, probably we have an error output or an unknown output
				errorsList.append(CheckItem(stringsToCheck: ["\(rc)", "\(px)"], valuesToCheck: ["0", "102030100"], printMessage: "Bootable macOS installer creation failed, unknown output from \"\(sharedExecutableName)\" while creating the installer, please, erase this dirve with disk utility and retry", message: "Bootable macOS installer creation failed because of an unknown error, chech the log for details", notError: false, operation: .equal, isBack: false))
				
			}
			
			//checks the conditions of the errorlist array to see if the operation has been complited with success
			for item in errorsList{
				for value in item.valuesToCheck{
					
					if self.checkMatch(item.stringsToCheck, value, operation: item.operation){
						
						log("\n\(item.printMessage)\n")
						
						if item.notError{
							var res = false
							
							/*DispatchQueue.main.async {
								self.viewController.progress.isHidden = false
								self.viewController.spinner.isHidden = true
							}*/
							
							DispatchQueue.global(qos: .background).sync {
								//here createinstall media succedes in creating the installer
								log("\(sharedExecutableName) process ended with success")
								log("Bootable macOS installer created successfully!")
								
								//extra operations here
								//trys to apply special options
								DispatchQueue.main.sync {
									self.setActivityLabelText("Applaying custom options")
								}
								
								res = self.manageSpecialOperations(true)
							}
							
							if res{
								
							}else{
								print("Advanced options fails")
								return
							}
							
						}
						
						if item.isBack{
							DispatchQueue.main.sync {
								self.viewController.goBack()
							}
						}else{
							DispatchQueue.main.sync {
								self.viewController.goToFinalScreen(title: item.message, success: item.notError)
							}
						}
						
						
						return
					}
				}
			}
			
		}
		
	}
	
	private func checkMatch(_ stringsToCheck: [String?], _ valueToCheck: String, operation: CheckItem.Operations) -> Bool{
		var ret = false
		
		for ss in stringsToCheck{
			if let s = ss{
				switch operation{
				case .different:
					
					if s != valueToCheck{
						ret = true
					}
					
				case .equal:
					
					if s == valueToCheck{
						ret = true
					}
					
				default:
					
					if s.contains(valueToCheck){
						ret = true
					}
				}
				
			}
		}
		
		return ret
	}
	
}
