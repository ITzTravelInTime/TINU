//
//  MediaCreationManagerStart.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa
import SecurityFoundation

#if recovery

import LocalAuthentication

#endif

extension InstallMediaCreationManager{
	
	func install(){
		
		//to have an usable UI during the install we need to use a parallel thread
		DispatchQueue.global(qos: .background).async {
			
			//self.setActivityLabelText("Process started")
			//just to avoid problems, the log function in this thred is called inside the Ui thread
			log("\nStarting the process ...")
			
			CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = true
			
			var isFailed = false
			
			//chck if volume needs to be formatted, in particular if it needs to be repartitioned and completely erased
			var canFormat = false
			
			//this variables enables or not automatic apfs conversion
			var useAPFS = false
			
			let pname = sharedExecutableName
			
			let isNotMojave = iam.shared.installerAppGoesUpToThatVersion(version: 14.0)!
			
			//1
			DispatchQueue.main.sync {
			
			self.setProgressValue(0)
			
			self.addToProgressValue(self.unit)
			
			self.setActivityLabelText("Closing conflicting processes")
				
			}
			
			isFailed = self.killConflictingPrcesses()
			
			if !isFailed{
				return
			}
			
			//2
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			
			self.setActivityLabelText("Unmounting conflicting volumes")
			}
			isFailed = self.unmountConflictingVolumes()
			
			if !isFailed{
				return
			}
			
			//3
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			
			self.setActivityLabelText("Applying options")
			}
			
			self.OtherOptionsBeforeformat(canFormat: &canFormat, useAPFS: &useAPFS)
			
			//4
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			}
			
			if canFormat{
				isFailed = self.formatTargetDrive(canFormat: canFormat, useAPFS: useAPFS)
				
				if !isFailed{
					return
				}
			}
			
			//5
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			}
			
			print("Resetting license")
			
			processLicense = ""
			
			//6
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			}
			
			//if the procdess will install mac, special operations are performed before the beginning of the "startosinstall" process
			if sharedInstallMac{
				
				self.setProgressValue(1)
				
				self.setActivityLabelText("Applying options")
				
				if !self.manageSpecialOperations(false){
					return
				}
				
			}
				
			//7
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			
			self.setActivityLabelText("Building " + pname + " command string")
			}
			
			log("The application that will be used is: " + cvm.shared.sharedApp!)
			log("The target drive is: " + cvm.shared.sharedVolume!)
			
			let mainCMD = self.buildCommandString(useMojave: isNotMojave, useAPFS: useAPFS)
			
			/*if simulateUseScriptAuth{
				mainCMD = "\(mainCMD)"
			}*/
			
			//8
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			
			self.setActivityLabelText("Second step authentication")
			}
			
			
			//logs the performed script and takes care of hiding the password
			log("The script that will be performed is: " + mainCMD)
			
			
			//sswitches state because now we are starting the process of the real creation / instllation
			CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
			CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = true
			
			var startC: (process: Process, errorPipe: Pipe, outputPipe: Pipe)!
			
			var noFAuth = false
			
			#if noFirstAuth
			noFAuth = true
			#endif
			
			//9
			DispatchQueue.main.sync {
			self.addToProgressValue(self.unit)
			
			self.setProgressValue(self.processUnit)
			}
			
			if simulateCreateinstallmediaFail != nil && noFAuth{
				startC = startCommand(cmd: "/bin/sh", args: ["-c", mainCMD])
			}else{
				startC = startCommandWithSudo(cmd: "/bin/sh", args: ["-c", mainCMD])
			}
			
			/*DispatchQueue.main.async {
				self.viewController.progress.isHidden = true
				self.viewController.spinner.isHidden = false
			}*/
			
			//run the script with sudo permitions and then analyze the outputs
			if let r = startC{
				
				log("Process started, waiting for \(pname) executable to finish ...")
				
				DispatchQueue.main.sync {
				if sharedInstallMac{
					self.setActivityLabelText("Installing macOS\n(may take from 5 to 30 minutes)")
				}else{
					self.setActivityLabelText("Creating bootable macOS installer\n(may take from 5 to 30 minutes)")
				}
					//cancel button and the close button can be restored
					self.viewController.cancelButton.isEnabled = true
					
					if let ww = sharedWindow{
						//ww.isMiniaturizeEnaled = false
						ww.isClosingEnabled = true
						//ww.canHide = false
					}
				}
				
				//2 different aproces of handeling the process
				if simulateNoTimer{
					//code used if the timer is not used
					
					DispatchQueue.main.sync {
						self.timer.invalidate()
						self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.increaseProgressBar(_:)), userInfo: nil, repeats: true)
					}
					
					r.process.waitUntilExit()
					
					DispatchQueue.main.sync {
						self.installFinished()
					}
				}else{
					//here insted just uses a timer to see if the process has finished and stops this thread
					//assign processes variables
					CreateinstallmediaSmallManager.shared.process = r.process
					CreateinstallmediaSmallManager.shared.errorPipe = r.errorPipe
					CreateinstallmediaSmallManager.shared.outputPipe = r.outputPipe
					
					DispatchQueue.main.sync {
						self.timer.invalidate()
						self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkProcessFinished(_:)), userInfo: nil, repeats: true)
					}
				}
				
				return
			}else{
				
				//here the auth is failed or some execution error
				DispatchQueue.main.sync {
					log("Get password failed")
					self.viewController.goBack()
					
				}
				
				return
			}
		}
	}
	
}
