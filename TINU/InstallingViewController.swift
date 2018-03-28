//
//  InstallingViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 27/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa
import SecurityFoundation

#if recovery

    import LocalAuthentication

#endif

class InstallingViewController: GenericViewController{
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var descriptionField: NSTextField!
    @IBOutlet weak var titleField: NSTextField!
    
    @IBOutlet weak var activityLabel: NSTextField!
    
    @IBOutlet weak var cancelButton: NSButton!
	
	@IBOutlet weak var infoImageView: NSImageView!
    
    @IBOutlet weak var progress: NSProgressIndicator!
    
    //is used to determnate if old or new auth pis were used
    private var usedLA = false
    
    //variables used to check the sucess of the authentication
    private var osStatus: OSStatus = 0
    private var osStatus2: OSStatus = 0
    
    //references we need to free the permitions later
    private var authRef2: AuthorizationRef?
    private var authFlags = AuthorizationFlags([])
    
    //timer to trace the process
    private var timer = Timer()
    
    private var pid = Int32()
    private var output : [String] = []
    private var error : [String] = []
    
    private let unit: Double = 1 / 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //disable the close button of the window
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = false
            w.isClosingEnabled = false
            w.canHide = false
        }
		
		infoImageView.image = infoIcon
        
        //setup of the window if the app is in install macOS mode
        if sharedInstallMac{
            descriptionField.stringValue = "macOS installation in progress, please wait until the computer reboots and leave the windows as is, after that you should boot from \"macOS install\""
            
            titleField.stringValue = "macOS installation in progress"
        }
        
        activityLabel.stringValue = ""
        
        self.setProgressValue(0)
		
        /*if let a = NSApplication.shared().delegate as? AppDelegate{
         a.QuitMenuButton.isEnabled = false
         }*/
        
        //just prints some separators to allow me to see where this windows opens in the output
        print("*******************")
        print("* PROCESS STARTED *")
        print("*******************")
        
        setActivityLabelText("Checking installer appilcation")
        
        print("process window opened")
        //this code checks if the app and the drive provided are correct
        var notDone = false
        
        if let sa = sharedApp{
            appImage.image = getInstallerAppIcon(forApp: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installer app that will be used is: " + sa)
        }else{
            notDone = true
        }
        
        setActivityLabelText("Checking target drive")
        if let sv = sharedVolume{
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
				if sharedBSDDrive != nil{
                if let sb = sharedBSDDrive{
                    
                    sr = getDriveNameFromBSDID(sb)
                    sharedVolume = sr
                    print("Corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
				}else{
					if let sa = sharedBSDDriveAPFS{
						sr = getDriveNameFromBSDID(sa)
						sharedVolume = sr
					}else{
						notDone = true
					}
				}
            }
            
            driveImage.image = NSWorkspace.shared().icon(forFile: sr)
            driveName.stringValue = FileManager.default.displayName(atPath: sr)
            
            print("The target volume is: " + sr)
        }else{
            notDone = true
        }
        
        //used to simulate a fail to gett drive or app data
        if simulateInstallGetDataFail{
            notDone = true
        }
        
        //if it can't get usable drive and app information, it goes back to the previuos window
        if notDone {
            setActivityLabelText("Error with inst. app or target drive")
            print("Couldn't get valid info about the installer app and/or the drive")
            //temporary dialong util a soulution for the go back in the view controller problem is solved
            if !dialogYesNoWarning(question: "Quit the app?", text: "There was an error while trying to get drive or installer app data, do you want to quit the app?", style: .critical){
                NSApplication.shared().terminate(self)
            }else{
				DispatchQueue.global(qos: .background).async{
					DispatchQueue.main.async {
						self.goBack()
					}
				}
            }
        }else{
            print("Everything is ready to start the macOS install media creation process")
            
            spinner.startAnimation(self)
            
            startInstallProcess()
        }
    }
    
    //just to be sure, if the view does disappear the installer creation is stopped
    override func viewWillDisappear() {
        if sharedIsCreationInProgress || sharedIsPreCreationInProgress{
            let _ = stop()
        }
    }
    
    private func askFirstAuthOldWay() -> Bool{
        let b = Bundle.main
        
        var authRef: AuthorizationRef? = nil
        
        self.osStatus = AuthorizationCreate(nil, nil, self.authFlags, &authRef)
        var myItems = [
            AuthorizationItem(name: b.bundleIdentifier! + ".sudo", valueLength: 0, value: nil, flags: 0),
            AuthorizationItem(name: b.bundleIdentifier! + ".createinstallmedia", valueLength: 0, value: nil, flags: 0)
        ]
        var myRights = AuthorizationRights(count: UInt32(myItems.count), items: &myItems)
        let myFlags : AuthorizationFlags = [.interactionAllowed, .extendRights, .destroyRights, .preAuthorize]
        
        self.osStatus2 = AuthorizationCreate(&myRights, nil, myFlags, &self.authRef2)
        
        
        //simulates an uthentication fail or cancel
        if simulateFirstAuthCancel{
            self.osStatus = 1
            self.osStatus2 = 1
        }
        
        //checks if the authentication is sucessfoul
        /*if self.osStatus != 0 || self.osStatus2 != 0{
         //the user does not gives the authentication, so we came back to previous window
         DispatchQueue.main.sync {
         log("Authentication aborted")
         self.goBack()
         }
         return
         }*/
        
        return (self.osStatus == 0 && self.osStatus2 == 0)
    }
	
	private func startInstallProcess(){
		self.cancelButton.isEnabled = false
		self.enableItems(enabled: false)
		
		DispatchQueue.global(qos: .background).async{
			
			
			if sharedIsReallyOnRecovery{
				DispatchQueue.main.sync {
					self.usedLA = false
					self.install()
				}
				return
			}else{
				self.setActivityLabelText("First step authentication")
				log("Asking user for autentication")
			}
			
			#if noFirstAuth
				
				DispatchQueue.main.sync {
					self.usedLA = true
					self.install()
				}
				
				return
				
			#else
				
				#if recovery
					if #available(macOS 10.11, *) {
						if !(simulateFirstAuthCancel || sharedIsOnRecovery) {
							
							log("Trying to do user authentication using local authentication APIs")
							
							let myContext = LAContext()
							
							let myLocalizedReasonString = "create a bootable macOS Install media"
							
							var authError: NSError?
							
							if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError){
								myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
									if success && !simulateFirstAuthCancel{
										// User authenticated successfully, take appropriate action
										log("Authentication using local authentication APIs completed with success")
										//calls the install function to start the installer creation process
										DispatchQueue.main.sync {
											self.usedLA = true
											self.install()
										}
									} else {
										// User did not authenticate successfully, look at error and take appropriate action
										var desc = ""
										if let e = evaluateError{
											desc = e.localizedDescription
										}
										
										log("Authentication fail using local authentication APIs:\n     \(desc)")
										DispatchQueue.main.sync {
											self.goBack()
										}
									}
									return
								}
								return
							}
						}
						
					}
				#endif
				
				log("Trying to do user authentication using security foundation APIs")
				
				if !self.askFirstAuthOldWay() || simulateFirstAuthCancel{
					log("Authentication fail using security foundation APIs")
					DispatchQueue.main.sync {
						self.goBack()
					}
				}else{
					log("Authentivcation with security foundation APIs completed with success")
					//calls the install function to start the installer creation process
					DispatchQueue.main.sync {
						self.usedLA = false
						self.install()
					}
				}
				return
				
			#endif
		}
	}

    private func install(){
		
        //to have an usable UI during the install we need to use a parallel thread
        DispatchQueue.global(qos: .background).async {
			
            //self.setActivityLabelText("Process started")
            //just to avoid problems, the log function in this thred is called inside the Ui thread
            log("Starting the process ...")
			
            sharedIsPreCreationInProgress = true
			
            // variables used to determinate if the format was sucessfoul
            var didChangePS = true
            //var didChangeFS = true
			
            //chck if volume needs to be formatted, in particular if it needs to be repartitioned and completely erased
            var canFormat = false
			
            //this variables enables or not automatic apfs conversion
            var useAPFS = false
			
            //this is the name of the executable we need to use now
            let pname = sharedExecutableName
            
            self.setActivityLabelText("Closing conflicting processes")
            
            //1
            self.setProgressValue(self.unit)
            
            //creates a list of processes to kill
            let processesToClose = [pname, "InstallAssistant", "InstallAssistant_plain", "InstallAssistant_springboard"]
            
            //try to terminate a process that may be still active in backgruound, maybe for a previuos crash of the app or the system
            log("\n\n***Trying to close conflicting processes")
            
            for p in processesToClose{
                //trys to terminate the process
                if let success = terminateProcess(name: p){
                    if success{
                        log("*** \"" + p + "\" closed with sucess or already closed")
                    }else{
                        log("***Failed to close conflicting processes \(p)!!!")
                        DispatchQueue.main.sync {
                            self.goToFinalScreen(title: "TINU failed to stop conflicting process: \(p), check the log for more details", success: false)
                        }
                        return
                    }
                }else{
                    log("***Failed to terminate conflicting process: \"" + p + "\" because of a failed 2nd step authentication attempt\n\n")
                    DispatchQueue.main.sync {
                        self.goBack()
                    }
                    return
                }
            }
            log("***No conflicting processes found or confilicting processes closed with sucess")
            
            //2
            self.addToProgressValue(self.unit)
                
            self.setActivityLabelText("Unmounting \"InstallESD\"")
            
            //trys to unmount possible conficting drives that may interfear, like install esd
            log("\n\n###Trying to unmount \"InstallESD\"")
            
            //trys to unmount install esd because it can create
            if self.unmountConflictingDrive(){
                log("###\"InstallESD\" unmounted with success or already unmounted")
            }else{
                log("###Failed to unmount \"InstallESD\"!!!")
                DispatchQueue.main.sync {
                    self.goToFinalScreen(title: "TINU failed to unmount \"InstallESD\", check the log for more details", success: false)
                }
                return
            }
            
            //3
            self.progress.doubleValue += self.unit
            
            self.setActivityLabelText("Applying options")
            
            log("\n\nStarting extra opertaions before launching the executable")
            
            //checks the options to use in this function
            if !simulateFormatSkip{
                if let s = sharedVolumeNeedsPartitionMethodChange {
                    canFormat = s
                }
                
                if !canFormat {
                    if let o = otherOptions[otherOptionForceToFormatID]?.canBeUsed(){
                        if o && !simulateFormatSkip{
                            canFormat = true
                            log("   Forced drive erase enabled")
                        }
                    }
                }
            }
            
            if sharedInstallMac{
                if let o = otherOptions[otherOptionDoNotUseApfsID]?.canBeUsed(){
                    if o {
                        useAPFS = false
                        log("   Forced APFS automatic upgrade enabled")
                    }
                }
            }
            
            log("Finished extra opertaions before launching the executable\n\n")
            
            
            //4
            self.addToProgressValue(self.unit)
            
            if canFormat {
                self.setActivityLabelText("Formatting target drive")
                
                log("---Starting drive format process")
                
                //we set this to false just in case of failure
                didChangePS = false
                
                //this code gets the bsd name of the drive from the bsd name of the partition selcted
                let tmpBSDName = getDriveBSDIDFromVolumeBSDID(volumeID: sharedBSDDrive)
                
                if sharedBSDDriveAPFS != nil{
                    //NSWorkspace.shared().unmountAndEjectDevice(atPath: sharedVolume)
                    
                    let unmountComm = "diskutil unmountDisk " + tmpBSDName
                    
                    log("APFS Disks unmount will be done with coomand: \n    \(unmountComm)")
                    
                    if let out = getOutWithSudo(cmd: unmountComm){
                        
                        print(out)
                        
                        if !out.contains("was successful"){
                            DispatchQueue.main.sync {
                                log("---Filed to eject apfs volumes\n\n")
                                self.goToFinalScreen(title: "Volume format failed to unmount APFS disks, check log for more details", success: false)
                            }
                            return
                        }
                    }else{
                        print(getOut(cmd: "diskutil mount " + tmpBSDName))
                        
                        log("---Filed to authenticate to eject apfs drive\n\n")
                        DispatchQueue.main.sync {
                            self.goBack()
                        }
                        return
                    }
                }
                
                var newVolumeName = "Installer"
                
                if checkSharedBundleName() {
                    newVolumeName = sharedBundleName
                }
                
                //this is the command used to erase the disk and create on just one partition with the GUID table
                let cmd = "diskutil eraseDisk JHFS+ \"" + newVolumeName + "\" /dev/" + tmpBSDName
                
                log("Formatting disk and change partition scheme with the command:\n       " + cmd)
                
                //gets the output of the format script
                //out is nil only if the authentication has failed
                if let out = getOutWithSudo(cmd: cmd){
                    
                    //output separated in parts
                    let c = out.components(separatedBy: "\n")
                    //the text we are looking for
                    let finishedMark = "Finished erase on disk"
                    
                    if !c.isEmpty{
                        if !(c.count == 1 && (c.first?.isEmpty)!){
                            //checks if the erase has been completed with success
                            if c[c.count - 2].contains(finishedMark) || c.last!.contains(finishedMark){
                                //we can set this boolean to true because the process has been successfoul
                                didChangePS = true
                                //setup variables for the \createinstall media, the target partition is always the second partition into the drive, the first one is the EFI partition
                                sharedBSDDrive = "/dev/" + tmpBSDName + "s2"
								
								if sharedInstallMac{
									sharedBSDDriveAPFS = nil
								}
								
                                sharedVolume = getDriveNameFromBSDID(sharedBSDDrive)
								
                                if sharedVolume == nil{
                                    sharedVolume = "/Volumes/" + newVolumeName
                                }
                                
                                DispatchQueue.main.async {
                                    if let name = sharedVolume{
                                        self.driveImage.image = NSWorkspace.shared().icon(forFile: name)
                                        self.driveName.stringValue = FileManager.default.displayName(atPath: name)
                                    }
                                    
                                    log("---Volume format process ended wiuth success\n\n")
                                }
                            }else{
                                //the format has failed, so the boolean is false and a screen with installer creation failed will be displayed
                                log("----Volume format process fail: ")
                                log("         Format script output: \n" + out)
                                
                                didChangePS = false
                            }
                        }else{
                            //too less output from the process
                            log("Failed to get valid output for the format process")
                            didChangePS =  false
                        }
                    }else{
                        log("Failed to get outut from the format process")
                        didChangePS = false
                    }
                }else{
                    log("Failed to perform needed authentication to format target drive\n\n")
                    DispatchQueue.main.sync {
                        self.goBack()
                    }
                    return
                }
                
            }
            
            //this code simulates when the format has failed
            if simulateFormatFail{
                didChangePS = false
            }
            
            //if the drive has benn successfully formatted, procede
            if !didChangePS {
                
                //here the format script to erase the drive has failed, we also need to realse permitions here
                
                DispatchQueue.main.sync {
                    log("Process failed, drive format or partition table changement failed, please erase this drive manually with disk utility and then retry")
                    //the driver format has failed, so it does setup the final windows to show the failure an the error and then it's called
                    
                    if sharedInstallMac{
                        self.goToFinalScreen(title: "macOS installer process failed to format the target drive, check the log for details", success: false)
                    }else{
                        self.goToFinalScreen(title: "macOS install media creation failed to format the target drive, check the log for details", success: false)
                    }
                }
                
                return
				
			}
            
            //6
            self.addToProgressValue(self.unit)
			
			processLicense = ""
			
			//7
			self.addToProgressValue(self.unit)
            
			//if the procdess will install mac, special operations are performed before the beginning of the "startosinstall" process
			if sharedInstallMac{
				
				self.setProgressValue(1)
				
				self.setActivityLabelText("Applying options")
				
				if !self.performSpeacialOperations(){
					DispatchQueue.main.sync {
						log("Failed to perform special operations before installing macOS")
						self.goToFinalScreen(title: "macOS installer failed to apply the custom options, check the log for more details", success: false)
					}
					return
				}
				
			}else{
            
				//8
				self.addToProgressValue(self.unit)
			
			}
			
            self.setActivityLabelText("Building " + pname + " command string")
            
            log("The application that will be used is: " + sharedApp!)
            log("The target drive is: " + sharedVolume!)
            
            //this strting is used to define the main command to use, then the prefix is added
            var mainCMD = "\"\(sharedApp!)/Contents/Resources/\(pname)\" --volume \"\(sharedVolume!)\" --applicationpath \"\(sharedApp!)\""
            
            //if tinu have to create a mac os installation on the selected drive
            if sharedInstallMac{
                
                ///Volumes/Image\ Volume/Install\ macOS\ High\ Sierra.app/Contents/Resources/startosinstall --volume /Volumes/MAC --converttoapfs NO
                var noAPFSSupport = true
                
                //check if the version of the installer does not supports apfs
                if let ap = sharedAppNotSupportsAPFS(){
                    noAPFSSupport = ap
                }
                
                //the command is adjusted if the version of the installer supports apfs and if the user prefers to avoid upgrading to apfs
                if noAPFSSupport{
                    mainCMD += " --agreetolicense;exit;"
                }else{
                    if useAPFS || sharedBSDDriveAPFS != nil{
                        mainCMD += " --agreetolicense --converttoapfs YES;exit;"
                    }else{
                        mainCMD += " --agreetolicense --converttoapfs NO;exit;"
                    }
                }
            }else{
                //we are just on the standard createinstallmedia, so let's add what is missing
                mainCMD += " --nointeraction;exit;"
            }
            
            //this code is used to simulate results of createinstallmedia, saves time hen tesing the fial screen
            if let scf = simulateCreateinstallmediaFail{
                
                //just for debug, prints the real command generated by the code
                log("Real command: " + mainCMD)
                
                //replace with the test commands
                if !scf{
                    mainCMD = "echo \"done test\""
                }else{
                    mainCMD = "echo \"failed test\""
                }
                
            }
			
			self.setProgressMax(100)
			self.setProgressValue(100)
			
			self.progress.isIndeterminate = true
			
            self.setActivityLabelText("Second step authentication")
            
            //logs the performed script and takes care of hiding the password
            log("The script that will be performed is: " + mainCMD)
            
            
            //sswitches state because now we are starting the process of the real creation / instllation
            sharedIsPreCreationInProgress = false
            sharedIsCreationInProgress = true
			
			var startC: (process: Process, errorPipe: Pipe, outputPipe: Pipe)!
			
			var noFAuth = false
			
			#if noFirstAuth
				noFAuth = true
			#endif
			
			if simulateCreateinstallmediaFail != nil && noFAuth{
				startC = startCommand(cmd: "/bin/sh", args: ["-c", mainCMD])
			}else{
				if simulateUseScriptAuth{
					startC = startCommandWithAScriptSudo(cmd: "/bin/sh", args: ["-c", mainCMD])
				}else{
					startC = startCommandWithSudo(cmd: "/bin/sh", args: ["-c", mainCMD])
				}
			}
			
			DispatchQueue.main.async {
				self.progress.isHidden = true
				self.spinner.isHidden = false
			}
			
            //run the script with sudo permitions and then analyze the outputs
            if let r = startC{
                
                log("Process started, waiting for \(pname) executable to finish ...")
                
                if sharedInstallMac{
                    self.setActivityLabelText("Installing macOS (may take from 5 to 30 minutes)")
                }else{
                    self.setActivityLabelText("Creating bootable macOS installer (may take from 10 to 45 minutes)")
                }
                
                DispatchQueue.main.async {
                    //cancel button and the close button can be restored
                    self.cancelButton.isEnabled = true
                    
                    if let ww = sharedWindow{
                        //ww.isMiniaturizeEnaled = false
                        ww.isClosingEnabled = true
                        //ww.canHide = false
                    }
                }
                
                //2 different aproces of handeling the process
                if simulateNoTimer{
                    //here it stops this thread until the process ends
                    let time = NSTimeIntervalSince1970
                    //code used if the timer is not used
                    r.process.waitUntilExit()
                    
                    DispatchQueue.main.async {
                        self.seconds = UInt64(NSTimeIntervalSince1970 - time)
                        //install is finished, so we call this function
                        self.installFinished()
                    }
                }else{
                    //here insted just uses a timer to see if the process has finished and stops this thread
                    //assign processes variables
                    process = r.process
                    errorPipe = r.errorPipe
                    outputPipe = r.outputPipe
                    
                    DispatchQueue.main.async {
                        self.timer.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkProcessFinished(_:)), userInfo: nil, repeats: true)
                    }
                }
                
                return
            }else{
                //here the second authentication is failed, so we come back to the previus screen, but we need to release permitions
                self.freeAuth()
                
                //now the installer creation process has finished running, so our boolean must be false now
                sharedIsPreCreationInProgress = false
                
                DispatchQueue.main.sync {
                    log("Get password failed")
                    self.goBack()
                    
                }
                
                return
            }
        }
    }
    
	var seconds: UInt64 = 0
	//function that checks if the process has finished
	@objc func checkProcessFinished(_ sender: AnyObject){
		seconds += 1
		print(String(seconds) + " seconds passed from start")
		if process.isRunning{
			
			if seconds % 60 == 0{
				log("Please wait, the process is still going, minutes since process beginning: \(seconds / 60)")
			}
			
		}else{
			sharedIsCreationInProgress = false
			self.timer.invalidate()
			self.installFinished()
		}
	}
	
    private func installFinished(){
        //now the installer creation process has finished running, so our boolean must be false now
        sharedIsCreationInProgress = false
		
		DispatchQueue.main.async {
			self.progress.isHidden = false
			self.spinner.isHidden = true
		}
		
        self.setActivityLabelText("Interpreting the results of the process")
        
        log("process took " + String(self.seconds) + " seconds to finish")
        
        //we have finished, so the controls opf the window are restored
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
        
        //this code get's the output of teh process
        let outdata = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            self.output = string.components(separatedBy: "\n")
        }
        
        //this code gets the errors of the process
        let errdata = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            self.error = string.components(separatedBy: "\n")
        }
        
        //gets the termination status for comparison
        var rc = process.terminationStatus
        
        //code used to test if the process has exited with an abnormal code
        if simulateAbnormalExitcode{
            rc = 1
        }

        //if there is a not normal code it will be logged
        log("macOS install media creation finished, createinstallmedia has finished")
        
        //if the exit code produced is not normal, it's logged
        if rc != 0{
            log("process exit code produced: \n      \(rc)")
        }
        
        log("process output produced: ")
        
        //logs the output of the process
        for o in self.output{
            log("      " + o)
        }
        
        //if the output is empty opr if it's just the standard output of the creation process, it's not logged
        if !self.error.isEmpty{
            if !((self.error.first?.contains("Erasing Disk: 0%... 10%... 20%... 30%...100%..."))! && self.error.first == self.error.last){
                
                log("process error/s produced: ")
                //logs the errors produced by the process
                for o in self.error{
                    log("      " + o)
                }
            }
        }
        
        //in case we are installing mac
        if sharedInstallMac{
			if rc == 0{
				self.goToFinalScreen(title: "macOS installed successfully", success: true)
			}else{
				self.goToFinalScreen(title: "macOS installation error: check the log for details", success: false)
			}
			return
        }
        
        //now we checks if the installer creation has been completed sucessfully
        if (self.output.last?.lowercased().contains("done"))!{
            DispatchQueue.global(qos: .background).async {
                //here createinstall media succedes in creating the installer
                log("macOS install media created successfully!")
                
                //extra operations here
                //trys to apply special options
                
                self.setActivityLabelText("Applaying custom options")
                let ok = self.performSpeacialOperations()
                
                DispatchQueue.main.sync {
                    if ok{
                        //ok the installer creation has been completed with sucess, so it sets up the final widnow and then it's showed up
                        self.goToFinalScreen(title: "macOS install media created successfully", success: true)
                    }else{
                        //installer creation failed, bacause of an error with the advanced options
                        self.goToFinalScreen(title: "macOS install media creation failed to apply the advanced options, check the log for details", success: false)
                    }
                }
            }
            return
            
        }else if (self.error.last?.contains("A error occurred erasing the disk."))! || (self.output.last?.contains("A error occurred erasing the disk."))! {
            
            //here createinstall media failed to create the installer, bacuse of a format failure
            log("macOS install media creation failed, createinstallmedia returned an error while formatting the installer, please, erase this dirve with disk utility and retry")
            
            //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
            self.goToFinalScreen(title: "macOS install media creation failed to format the target drive, check the log for details", success: false)
            
        }else if (self.error.last?.contains("does not appear to be a valid OS installer application"))! || (self.error.last?.contains("does not appear to be a valid OS installer application"))! {
            
            //here createinstall media failed to create the installer, bacuse of the downloaded app not being a valid one
            log("macOS install media creation failed, createinstallmedia returned an error about the app you are using, please, check your mac installaltion app and if needed download it again. Many thimes this appens ,because the installer downloaded from the mac app store, does not contains all the needed files or contanins wrong or corrupted files, in many cases the mac app store on a virtual machine does not downloads the full macOS installer application")
            
            //showing tp the installer screen
            self.goToFinalScreen(title: "macOS install media creation failed: Damaged or bad macOS application, check the log for details", success: false)
            
        }else if (error.last?.contains("is not a valid volume mount point"))!{
            
            //here the process failed because it can't find the selected drive
            log("macOS install media creation failed because the selected volume is no longer available")
        
            
            self.goToFinalScreen(title: "macOS install media creation failed: The target drive is no longer available, check the log for details", success: false)
			
		}else if (error.first?.contains("The copy of the installer app failed"))! || (error.last?.contains("The copy of the installer app failed"))!{
			log("macOS install media creation failed because the process failed to copy some elements on it, mainly the installer app or it's content, can't be copied or failed to be copied, please check that your target driver is working properly and just in case erase it with disk utility")
			
			self.goToFinalScreen(title: "macOS install media creation failed: Error while copying needed files, check the log for more details", success: false)

        }else{
            //shows different screen basing on the erros
            if rc == 0{
                
                //here createinstall media failed to create the installer
                log("macOS install media creation failed, the process returned an error while creating the installer, please, erase this dirve with disk utility and retry")
                
                //the installer creation has failed, so it does setup the final windows to show the failure an the error and then it's called
                self.goToFinalScreen(title: "macOS install media creation failed, check the log for details", success: false)
                
            }else{
                
                //process exite with a not nomal exit code
                log("macOS install media creation exited with a not normal exit code, see previous lines in the log to get more info about the error")
                
                self.goToFinalScreen(title: "macOS install media creation failed (Abnormal exit code detected), check the log for details", success: false)
                
            }
        }
        
    }
    
    //this function manages some special operations done after createinstallmedia finishes
    private func performSpeacialOperations() -> Bool{
		
		self.progress.isIndeterminate = false
		
		self.setProgressValue(0)
		self.setProgressMax(100)
		
		
        //testing code, exits from the function if we are in some particolar testing conditions
        if simulateNoSpecialOperations{
            //self.goToFinalScreen(title: "macOS install media created successfully", success: true)
            return true
        }
        
        //DispatchQueue.global(qos: .background).async{
		
		var ok = true
		if sharedInstallMac{
			if let a = sharedBSDDriveAPFS{
				sharedVolume = getDriveNameFromBSDID(a)
			}else{
				sharedVolume = getDriveNameFromBSDID(sharedBSDDrive!)
			}
		}else{
			sharedVolume = getDriveNameFromBSDID(sharedBSDDrive!)
		}
		
		print(sharedVolume)
		
        //a file manager, usefoul for the operation that we need later in this function
        let manager = FileManager.default
		
		var step: Double = 50 / 3
        
        log("\n\nStarting extra operations: ")
        
        //for o in otherOptions{
        if let o = otherOptions[otherOptionCreateReadmeID]?.canBeUsed(){
        if o {
            //creates a readme file into the target drive
            do{
                log("   Creating the readme file")
                if let sv = sharedVolume{
                //trys to write the readme file on the target drive using the text stored into a special variable
                try readmeText.write(toFile: sv + "/README.txt", atomically: true, encoding: .utf8)
                
                //trys to change the file attributes of the readme file to make it visible
                let e = getErr(cmd: "chflags nohidden \"" + sv + "/README.txt\"")
                if (e != "" && e != "Password:"){
                    log("       The readme file file can'be maked visible")
                }
                }
                //error handeling
            }catch let error{
                log("  Readme file creation failed, error: \n\(error)")
                ok = false
            }
            
        }
        }
		
		self.addToProgressValue(step)
        
        if let o = otherOptions[otherOptionCreateIconID]?.canBeUsed(){
        if o{
            
            //trys to create a volumeicon on the target drive if there isn't any, it's used mainly for versions of macOS installer older than 10.13
            do{
                log("   Trying to create the icon on the macOS install media")
                let origin = sharedApp + "/Contents/Resources/ProductPageIcon.icns"
                
                if manager.fileExists(atPath: origin){
                    
                    let destination = sharedVolume + "/.VolumeIcon"
                    
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
                        log("       Existing icon file removed sucessfully")
                    }
                    
                    log("       Creating the icon file")
                    try manager.copyItem(atPath: origin, toPath: destination + ".icns")
                    
                    NSWorkspace.shared().setIcon(NSImage.init(contentsOf: URL.init(fileURLWithPath: origin)), forFile: sharedVolume, options: NSWorkspaceIconCreationOptions.excludeQuickDrawElementsIconCreationOption)
                    
                    log("   Icon file created sucessfully")
                }else{
                    log("   Icon creation failed, the original icon from the macOS installer app was not found")
                    ok = false
                }
                
                //error handeling
            }catch let error{
                log("   VolumeIcon file creation failed, error: \n\(error)")
                ok = false
            }
            
        }
        }
		
		self.addToProgressValue(step)
        
        if let o = otherOptions[otherOptionTinuCopyID]?.canBeUsed(){
        if o {
            //trys to crerate a copy of this app on the mac os install media
            do{
                log("   Trying to create a copy of this app on the macOS install media")
                
                var path = sharedVolume + "/" + (Bundle.main.bundleURL.lastPathComponent)
                
                var canCopy = true
                
                //if we have to put the app on a mac os installation, we need to use the app directory
                if sharedInstallMac{
                    try manager.createDirectory(atPath: sharedVolume + "/Applications", withIntermediateDirectories: true, attributes: [:])
                    
                    path = sharedVolume + "/Applications/" + (Bundle.main.bundleURL.lastPathComponent)
                }else{
                    canCopy = (path != sharedVolume + "/" + URL.init(fileURLWithPath: sharedApp, isDirectory: true).lastPathComponent)
                }
                
                if canCopy{
                    if manager.fileExists(atPath: path){
                        log("       Trying to remove an existing copy of the app on the macOS install media")
                        try manager.removeItem(atPath: path)
                        log("       Existing copy of the app removed sucessfully from the mac os install media")
                    }
                    
                    log("       Trying to copy this app on the macOS install media")
                    try manager.copyItem(at: Bundle.main.bundleURL, to: URL.init(fileURLWithPath: path, isDirectory: true))
                    log("   This app has been copied sucessfully on the macOS install media")
                }else{
                    log("   The name of this app and the name of the installer app are the same, it's too dangerous to contiune, this operation has been cancelled")
                    ok = false
                }
            }catch let error{
                log("   Copy of this app the macOS install media failed, error: \n\(error)")
                ok = false
            }
        }
        }
		
		self.setProgressValue(50)
		
        //}
		
		//simulates an error of the advanced options
		if simulateSpecialOpertaionsFail{
			log("\n     Simulating a failure of the advanced options\n")
			ok = false
		}
		
        if !sharedInstallMac{
			
			
			step = 50 / Double(filesToReplace.count)
			
            self.setActivityLabelText("Replacing boot files")
            
            // boot files replacemt
            for f in filesToReplace{
				
                if !f.replace() {
                    log("   File \"" + f.filename + "\" replacement failed!")
					
					ok = false
				}
				
				self.addToProgressValue(step)
            }
			
			self.setProgressValue(100)
            
            log("Extra operations finished\n\n")
            
            /*if ok{
             //ok the installer creation has been completed with sucess, so it sets up the final widnow and then it's showed up
             //self.goToFinalScreen(title: "macOS install media created successfully", success: true)
             }else*/if !ok {
                log("One or more errors detected during the execution of the advanced options, your macOS install media will probably work, but not all the features and mods you choosed in the advanced options will work, check the messages printed before this one for more details abut that erros")
                //self.goToFinalScreen(title: "macOS install media creation failed to apply the advanced options, check the log for details", success: false)
            }
			
            self.setActivityLabelText("Process ended, exiting ...")
        }else{
			
			
			
            log("Extra operations finished\n\n")
            
            if !ok{
                log("One or more errors detected during the execution of the  options, macOS installation has been canceld, check the messages printed before this one for more details abut that erros")
                
            }
        }
        return ok
    }
    
    //this functrion frees the auth from apis
    private func freeAuth(){
        //free auth is called only when the processes are finished, so let's make them false
        sharedIsPreCreationInProgress = false
        sharedIsCreationInProgress = false
        
        //since into the recovery we do not need the spacial authorization, we just free it when running on a normal mac os environment
        if !sharedIsOnRecovery{
            erasePassword()
            
            if !usedLA{
                if authRef2 != nil && !authFlags.isEmpty{
                    //we no longer need the special authorization, so it is freed
                    if AuthorizationFree(authRef2!, authFlags) == 0{
                        DispatchQueue.main.async {
                            log("AutorizationFree executed successfully")
                        }
                    }else{
                        DispatchQueue.main.async {
                            log("AutorizationFree failed")
                        }
                    }
                }
            }
        }
    }
    
    private func restoreWindow(){
        //resets window
        spinner.isHidden = true
        spinner.stopAnimation(self)
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
        
        enableItems(enabled: true)
        
        //we no longer need authorizations, so they are feed
        freeAuth()
    }
    
    private func goToFinalScreen(title: String, success: Bool){
        //this code opens the final window
        log("macOS install media creation process ended")
        //resets window and auths
        restoreWindow()
        
        if !success{
            self.setActivityLabelText("Process failure")
        }
        
        //fixes shared variables
        sharedTitle = title
        sharedIsOk = success
        
        //we no longer need that data
        eraseReplacementFilesData()
        
        //we no longer need to use customized special options
        restoreOtherOptions()
        
        self.openSubstituteWindow(windowStoryboardID: "MainDone", sender: self)
    }
    
    private func goBack(){
        //this code opens the previus window
        
        //resets window and auths
        restoreWindow()
        
        self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        //displays a dialog to check if the user is sure that user wants to stop the installer creation
        
        if let stopped = stopWithAsk(){
            if stopped{
                if !(sharedIsCreationInProgress || sharedIsPreCreationInProgress){
                    goBack()
                }
            }else{
                log("Error while trying to close " + sharedExecutableName + " try to stop it from the termianl or from Activity monitor")
                msgBoxWarning("Error while trying to exit from the process", "There was an error while trying to close the creation process: \n\nFailed to stop " + sharedExecutableName + " process")
            }
        }else{
            log("Error while trying to close " + sharedExecutableName + " : bad authentication")
            msgBoxWarning("Error while trying to exit from the process", "There was an error while trying to close the creation process: \n\nFailed to obtain authentication")
        }
    }
    
    //this function trys to unmount installesd is it'f mounted because it can create problems with the install process
    public func unmountConflictingDrive() -> Bool{
        if driveExists(path: "/Volumes/InstallESD") {
            return NSWorkspace.shared().unmountAndEjectDevice(atPath: "/Volumes/InstallESD")
        }else{
            return true
        }
    }
    
    //this function stops the current executable from running and , it does runs sudo using the password stored in memory
    public func stop(mustStop: Bool) -> Bool!{
        if let success = terminateProcess(name: sharedExecutableName){
            if success{
                //if we need to stop the process ...
                if mustStop{
                    //just tell to the rest of the app that the installer creation is no longer running
                    sharedIsPreCreationInProgress = false
                    sharedIsCreationInProgress = false
                    
                    //dispose timer, bacause it's no longer needed
                    timer.invalidate()
                    
                    //auth is no longer needed
                    freeAuth()
                }
                
                return true
            }
            
        }else{
            return nil
        }
        
        return false
    }
    
    //just stops the whole process and sets the related variables
    public func stop() -> Bool!{
        return stop(mustStop: true)
    }
    
    //asks if the suer wants to stop the process
    func stopWithAsk() -> Bool!{
        var text = "Do you want to cancel the Installer cration process?"
        
        if sharedInstallMac{
            text = "Do you want to stop the macOS installation process?"
        }
        
        if !dialogYesNoWarning(question: "Stop the process?", text: text, style: .informational){
            return stop(mustStop: true)
        }else{
            return true
        }
    }
    
    //shows the log window
    @IBAction func showLog(_ sender: Any) {
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
    }
    
    private func enableItems(enabled: Bool){
        if let apd = NSApplication.shared().delegate as? AppDelegate{
            if sharedIsOnRecovery{
                apd.InstallMacOSItem.isEnabled = enabled
            }
            apd.verboseItem.isEnabled = enabled
        }
    }
    
    func setActivityLabelText(_ text: String){
        DispatchQueue.main.async {
            self.activityLabel.stringValue = text
        }
    }
	
	func setProgressValue(_ value: Double){
		DispatchQueue.main.async {
			self.progress.doubleValue = value
		}
	}
	
	func addToProgressValue(_ value: Double){
		setProgressValue(self.progress.doubleValue + value)
	}
	
	func setProgressMax(_ max: Double){
		DispatchQueue.main.async {
			self.progress.maxValue = max
		}
	}
}
