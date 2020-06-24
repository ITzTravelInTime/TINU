//
//  MediaCreationManagerStart.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{
	
	func install(){
		
		log("\nStarting the process ...")
		
		//to have an usable UI during the install we need to use a parallel thread
		DispatchQueue.global(qos: .background).async {
			CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = true
			
			var canFormat = false //chck if volume needs to be formatted, in particular if it needs to be repartitioned and completely erased
			var useAPFS = false //this variables enables or not automatic apfs conversion
			
			var tCMD = ""
			
			let pname = sharedExecutableName
			
			self.dname = dm.getCurrentDriveName()
			
			DispatchQueue.main.sync {
				self.setProgressValue(0)
			}
			
			for i in 1...9{
				var userText = ""
				var isFailed = true
				
				switch i{
				case 1:
					userText = "Closing conflicting processes"
				case 2:
					userText = "Unmounting conflicting volumes"
				case 3:
					userText = "Applying options"
				case 7:
					userText = "Building " + pname + " command string"
				default:
					break
				}
				
				DispatchQueue.main.sync {
					self.addToProgressValue(self.unit)
					if !userText.isEmpty{
						self.setActivityLabelText(userText)
					}
				}
				
				switch i{
				case 1:
					isFailed = self.killConflictingPrcesses()
				case 2:
					isFailed = self.unmountConflictingVolumes()
				case 3:
					self.OtherOptionsBeforeformat(canFormat: &canFormat, useAPFS: &useAPFS)
				case 4:
					isFailed = canFormat ? self.formatTargetDrive(canFormat: canFormat, useAPFS: useAPFS) : isFailed
				case 5:
					processLicense = ""
				case 6:
					//if the process will install mac, special operations are performed before the beginning of the "startosinstall" process
					if sharedInstallMac{
						self.setProgressValue(1)
						self.setActivityLabelText("Applying options")
						if !self.manageSpecialOperations(false){
							return
						}
					}
				case 7:
					tCMD = self.buildCommandString(useAPFS: useAPFS)
					
					log("The application that will be used is: " + cvm.shared.sharedApp!)
					log("The target drive is: " + cvm.shared.sharedVolume!)
					log("The script that will be performed is (including quotes): " + tCMD)
					
					//switches state because now we are starting the process of the real creation / instllation
					CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
					CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = true
					
				default:
					break
				}
				
				if !isFailed{
					return
				}
			}
			
			DispatchQueue.main.sync {
				self.setProgressValue(self.processUnit)
			}
			
			let args = ["-c", tCMD]
			let exec = "/bin/zsh"
			
			#if noFirstAuth
			let noFAuth = true
			#else
			let noFAuth = false
			#endif
			
			let startC = (simulateCreateinstallmediaFail != nil && noFAuth) ? startCommand(cmd: exec, args: args) : startCommandWithSudo(cmd: exec, args: args)
			
			if let r = startC{
				
				if sharedInstallMac{
					log("\n\nmacOS installation process started\n")
				}else{
					log("\n\nInstaller creation process started\n")
				}
				
				log(TextManager.helpfoulMessage)
					
				log("""
					
					Waiting for the \(pname) executable to finish ...
					
					""")
				
				//UI setup
				DispatchQueue.main.sync {
				if sharedInstallMac{
					self.setActivityLabelText("Installing macOS\n(may take from 5 to 50 minutes)")
				}else{
					self.setActivityLabelText("Creating bootable macOS installer\n(may take from 5 to 50 minutes)")
				}
					//cancel button and the close button can be restored
					self.viewController.cancelButton.isEnabled = true
					
					if let ww = sharedWindow{
						//ww.isMiniaturizeEnaled = false
						ww.isClosingEnabled = true
						//ww.canHide = false
					}
				}
				
				//2 different aproces of handeling the process end detection
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
				
			}else{
				
				//here the auth is failed or some execution error
				DispatchQueue.main.sync {
					log("User authentication failed or aborted")
					self.viewController.goBack()
				}
			}
		}
	}
	
}
