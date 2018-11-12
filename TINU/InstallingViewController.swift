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
	
	#if !installManager
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
	#endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //disable the close button of the window
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = false
            w.isClosingEnabled = false
            w.canHide = false
        }
		
		infoImageView.image = IconsManager.shared.infoIcon
        
        //setup of the window if the app is in install macOS mode
        if sharedInstallMac{
            descriptionField.stringValue = "macOS installation in progress, please wait until the computer reboots and leave the windows as is, after that you should boot from \"macOS install\""
            
            titleField.stringValue = "macOS installation in progress"
        }
        
        activityLabel.stringValue = ""
		
		#if installManager
			self.setProgressMax(InstallMediaCreationManager.shared.progressMaxVal)
		#endif
        
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
        
        if let sa = cvm.shared.sharedApp{
            appImage.image = IconsManager.shared.getInstallerAppIcon(forApp: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installer app that will be used is: " + sa)
        }else{
            notDone = true
        }
        
        setActivityLabelText("Checking target drive")
        if let sv = cvm.shared.sharedVolume{
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
				if cvm.shared.sharedBSDDrive != nil{
                if let sb = cvm.shared.sharedBSDDrive{
                    
                    sr = dm.getDriveNameFromBSDID(sb)
                    cvm.shared.sharedVolume = sr
                    print("Corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
				}else{
					if let sa = cvm.shared.sharedBSDDriveAPFS{
						sr = dm.getDriveNameFromBSDID(sa)
						cvm.shared.sharedVolume = sr
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
            /*if !dialogYesNoWarning(question: "Quit the app?", text: "There was an error while trying to get drive or installer app data, do you want to quit the app?", style: .critical){
                NSApplication.shared().terminate(self)
            }else{*/
				DispatchQueue.global(qos: .background).async{
					DispatchQueue.main.async {
						self.goBack()
					}
				}
            //}
        }else{
            print("Everything is ready to start the creation/installation process")
			
			#if installManager
			InstallMediaCreationManager.shared.reset()
			InstallMediaCreationManager.shared.startInstallProcess()
			#else
			spinner.startAnimation(self)
            startInstallProcess()
			#endif
        }
    }
    
    //just to be sure, if the view does disappear the installer creation is stopped
    override func viewWillDisappear() {
        if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
			#if installManager
				let _ = InstallMediaCreationManager.shared.stop()
			#else
            	let _ = stop()
			#endif
        }
    }
	
	#if !installManager
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
	#endif
	
	#if !installManager
	private func startInstallProcess(){
		self.cancelButton.isEnabled = false
		self.enableItems(enabled: false)
		
		DispatchQueue.global(qos: .background).async{
			
			if simulateUseScriptAuth{
				DispatchQueue.main.sync {
					self.usedLA = false
					self.install()
				}
				return
			}
			
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
							
							let myLocalizedReasonString = "Create a bootable macOS Installer"
							
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
	#endif

	#if !installManager
    private func install(){
		
        //to have an usable UI during the install we need to use a parallel thread
        DispatchQueue.global(qos: .background).async {
			
            //self.setActivityLabelText("Process started")
            //just to avoid problems, the log function in this thred is called inside the Ui thread
            log("\nStarting the process ...")
			
            CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = true
			
            // variables used to determinate if the format was sucessfoul
            var didChangePS = true
            //var didChangeFS = true
			
            //chck if volume needs to be formatted, in particular if it needs to be repartitioned and completely erased
            var canFormat = false
			
            //this variables enables or not automatic apfs conversion
            var useAPFS = false
			
            //this is the name of the executable we need to use now
            let pname = sharedExecutableName
			
			let isNotMojave = iam.shared.installerAppGoesUpToThatVersion(version: 14.0)!
            
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
            log("***No conflicting processes found or conflicting processes closed with sucess")
            
            //2
            self.addToProgressValue(self.unit)
                
            self.setActivityLabelText("Unmounting conflicting volumes")
            
            //trys to unmount possible conficting drives that may interfear, like install esd
            log("\n\n###Trying to unmount conficting volumes")
            
            //trys to unmount install esd because it can create
            if self.unmountConflictingDrive(){
                log("###Conflicting volumes unmounted with success or already unmounted")
            }else{
                log("###Failed to unmount conflicting volumes!!!")
                DispatchQueue.main.sync {
                    self.goToFinalScreen(title: "TINU failed to unmount conflicting volumes, check the log for more details", success: false)
                }
                return
            }
            
            //3
			
            self.addToProgressValue(self.unit)
            
            self.setActivityLabelText("Applying options")
            
            log("\n\nStarting extra opertaions before launching the executable")
            
            //checks the options to use in this function
            if !simulateFormatSkip{
                if let s = cvm.shared.sharedVolumeNeedsPartitionMethodChange {
                    canFormat = s
                }
                
                if !canFormat {
                    if let o = oom.shared.otherOptions[oom.shared.ids.otherOptionForceToFormatID]?.canBeUsed(){
                        if o && !simulateFormatSkip{
                            canFormat = true
                            log("   Forced drive erase enabled")
                        }
                    }
                }
            }
            
            if sharedInstallMac{
                if let o = oom.shared.otherOptions[oom.shared.ids.otherOptionDoNotUseApfsID]?.canBeUsed(){
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
                let tmpBSDName = dm.shared.getDriveBSDIDFromVolumeBSDID(volumeID: cvm.shared.sharedBSDDrive)
                
                if cvm.shared.sharedBSDDriveAPFS != nil{
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
                
                if iam.shared.checkSharedBundleName() {
                    newVolumeName = cvm.shared.sharedBundleName
                }
                
                //this is the command used to erase the disk and create on just one partition with the GUID table
                let cmd = "diskutil eraseDisk JHFS+ \"" + newVolumeName + "\" /dev/" + tmpBSDName
                
                log("Formatting disk and change partition scheme with the command:\n       " + cmd)
                
                //gets the output of the format script
                //out is nil only if the authentication has failed
                if let out = getOutWithSudo(cmd: cmd){
					
					print(out)
					
                    //output separated in parts
                    let c = out.components(separatedBy: "\n")
                    //the text we are looking for
                    let finishedMark = "Finished erase on disk"
                    
                    if !c.isEmpty{
                        if !(c.count <= 1 && (c.first?.isEmpty)!){
                            //checks if the erase has been completed with success
                            if c.last!.contains(finishedMark){
                                //we can set this boolean to true because the process has been successfoul
                                didChangePS = true
                                //setup variables for the \createinstall media, the target partition is always the second partition into the drive, the first one is the EFI partition
                                cvm.shared.sharedBSDDrive = "/dev/" + tmpBSDName + "s2"
								
								if sharedInstallMac{
									cvm.shared.sharedBSDDriveAPFS = nil
								}
								
                                cvm.shared.sharedVolume = dm.shared.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive)
								
                                if cvm.shared.sharedVolume == nil{
                                    cvm.shared.sharedVolume = "/Volumes/" + newVolumeName
                                }
                                
                                DispatchQueue.main.async {
                                    if let name = cvm.shared.sharedVolume{
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
                        self.goToFinalScreen(title: "Bootable macOS installer creation failed to format the target drive, check the log for details", success: false)
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
				
				if !self.manageSpecialOperations(false){
					return
				}
				
			}else{
            
				//8
				self.addToProgressValue(self.unit)
			
			}
			
            self.setActivityLabelText("Building " + pname + " command string")
            
            log("The application that will be used is: " + cvm.shared.sharedApp!)
            log("The target drive is: " + cvm.shared.sharedVolume!)
            
            //this strting is used to define the main command to use, then the prefix is added
            var mainCMD = "\"\(cvm.shared.sharedApp!)/Contents/Resources/\(pname)\" --volume \"\(cvm.shared.sharedVolume!)\""
			
			//mojave instalelr do not supports this argument
			if isNotMojave{
				log("This is an older macOS installer app, it needs the --applicationpath argument to use " + pname)
				mainCMD += " --applicationpath \"\(cvm.shared.sharedApp!)\""
			}
            
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
                if noAPFSSupport && !isNotMojave{
                    mainCMD += ";exit;"
                }else{
                    if useAPFS || cvm.shared.sharedBSDDriveAPFS != nil{
                        mainCMD += " --converttoapfs YES;exit;"
                    }else{
                        mainCMD += " --converttoapfs NO;exit;"
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
			
			self.setProgressMax(100)
			self.setProgressValue(100)
			
			DispatchQueue.main.sync {
				self.progress.isIndeterminate = true
			}
			
            self.setActivityLabelText("Second step authentication")
			
            
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
			
			if simulateCreateinstallmediaFail != nil && noFAuth{
				startC = startCommand(cmd: "/bin/sh", args: ["-c", mainCMD])
			}else{
				startC = startCommandWithSudo(cmd: "/bin/sh", args: ["-c", mainCMD])
			}
			
			DispatchQueue.main.async {
				self.progress.isHidden = true
				self.spinner.isHidden = false
			}
			
            //run the script with sudo permitions and then analyze the outputs
            if let r = startC{
                
                log("Process started, waiting for \(pname) executable to finish ...")
                
                if sharedInstallMac{
                    self.setActivityLabelText("Installing macOS\n(may take from 5 to 30 minutes)")
                }else{
                    self.setActivityLabelText("Creating bootable macOS installer\n(may take from 5 to 30 minutes)")
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
                    CreateinstallmediaSmallManager.shared.process = r.process
                    CreateinstallmediaSmallManager.shared.errorPipe = r.errorPipe
                    CreateinstallmediaSmallManager.shared.outputPipe = r.outputPipe
                    
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
                CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
                
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
		if CreateinstallmediaSmallManager.shared.process.isRunning{
			
			if seconds % 60 == 0{
				log("Please wait, the process is still going, minutes since process beginning: \(seconds / 60)")
			}
			
		}else{
			CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
			self.timer.invalidate()
			self.installFinished()
		}
	}
	
	#if useEFIReplacement && !macOnlyMode
	
	private var startProgress: Double = 0
	
	private var progressRate: Double = 0
	
	private var EFICopyEnded = false
	
		@objc func checkEFIFolderCopyProcess(_ sender: AnyObject){
			if EFICopyEnded{
				timer.invalidate()
			}
			
			if let p = EFIFolderReplacementManager.shared.copyProcessProgress{
				self.progress.doubleValue = startProgress + (progressRate * p)
			}
		}
	
	#endif
	
    private func installFinished(){
        //now the installer creation process has finished running, so our boolean must be false now
        CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
		
        self.setActivityLabelText("Interpreting the results of the process")
        
        log("process took " + String(self.seconds) + " seconds to finish")
        
        //we have finished, so the controls opf the window are restored
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
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
		log("The process of \(sharedExecutableName) has finished")
        
        log("process output produced: ")
        
        //logs the output of the process
        for o in self.output{
            log("      " + o)
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
        }
		
		
		self.analizeError()
		
		/*
		
		DispatchQueue.main.async {
		self.progress.isHidden = false
		self.spinner.isHidden = true
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
		
		let out = self.output.last?.lowercased()
		
        if (out?.contains("done"))! || (out?.contains("install media now available at "))!{
            DispatchQueue.global(qos: .background).async {
                //here createinstall media succedes in creating the installer
                log("macOS install media created successfully!")
                
                //extra operations here
                //trys to apply special options
                
                self.setActivityLabelText("Applaying custom options")
				
				let res = self.manageSpecialOperations(false)
				
				if !res{
					print("Advanced options fails")
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
			
		}else if (error.first?.contains("The copy of the installer app failed"))! || (error.last?.contains("The copy of the installer app failed"))! || (error[1].contains("The copy of the installer app failed")){
			log("macOS install media creation failed because the process failed to copy some elements on it, mainly the installer app or it's content, can't be copied or failed to be copied, please check that your target driver is working properly and just in case erase it with disk utility, if that does not work, use another working target device")
			
			self.goToFinalScreen(title: "macOS install media creation failed: Error while copying files, check that you usb thumb drive is working correctly, more details in the log", success: false)

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
        */
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
			if rc != 0{
				log("process exit code produced: \n      \(rc)")
			}
			
			var dname = dm.getCurrentDriveName()
			
			self.setActivityLabelText("Checking previous operations")
			log("cheking the \(sharedExecutableName) process")
			
			if sharedInstallMac{
				DispatchQueue.main.sync {
					
					if rc == 0{
						self.goToFinalScreen(title: "macOS installed successfully", success: true)
					}else{
						self.goToFinalScreen(title: "macOS installation error: check the log for details", success: false)
					}
					
				}
				
				return
			}
			
			var fe: String!
			var me: String!
			var le: String!
			
			//let fo = ""
			var lo: String!
			
			var llo: String!
			
			var tt: String!
			
			if !simulateCreateinstallmediaFailCustomMessage.isEmpty && simulateAbnormalExitcode{
				tt = simulateCreateinstallmediaFailCustomMessage
			}
			
			DispatchQueue.main.sync{
				
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
				
			}
			
			var errorsList: [CheckItem] = []
	
			if rc != 0 || simulateUseScriptAuth{
				
				//add new known errors here
				
				//   |   |   |   |   |
				//  \/  \/  \/  \/  \/
				
				
				
				//   /\  /\  /\  /\  /\
				//   |   |   |   |   |
				
				//checks for known errors first
				
				if simulateUseScriptAuth{
					errorsList.append(CheckItem(stringsToCheck: [fe], valuesToCheck: ["NO"], printMessage: "script auth cancelled by user", message: "", notError: false, operation: .contains, isBack: true))
					
					if rc != 0{
					errorsList.append(CheckItem(stringsToCheck: [le], valuesToCheck: ["execution error:", "(-128)"], printMessage: "Apple script operation cancelled, going to previous screen", message: "", notError: false, operation: .contains, isBack: true))
					}
					
					//then checks if the process was completed correctly
					errorsList.append(CheckItem(stringsToCheck: [llo], valuesToCheck: ["done", "install media now available at "], printMessage: "Bootable macOS installer created successfully!", message: "Bootable macOS installer created successfully", notError: true, operation: .contains, isBack: false))
				}
				
				errorsList.append(CheckItem(stringsToCheck: [tt, le, lo], valuesToCheck: ["A error occurred erasing the disk."], printMessage: "Bootable macOS installer creation failed, createinstallmedia returned an error while formatting the target drive, please, erase this dirve with disk utility and retry", message: "TINU failed to format \"\(dname)\"", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["does not appear to be a valid OS installer application"], printMessage: "bootable macOS installer creation failed, createinstallmedia returned an error about the app you are using, please, check your mac installaltion app and if needed download it again. Many thimes this appens ,because the installer downloaded from the mac app store, does not contains all the needed files or contanins wrong or corrupted files, in many cases the mac app store on a virtual machine does not downloads the full macOS installer application", message: "Bootable macOS installer creation failed because the selected macOS installer app is damaged", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["is not a valid volume mount point"], printMessage: "Bootable macOS installer creation failed because the selected volume is no longer available", message: "Bootable macOS installer creation failed because the drive \"\(dname)\" is no longer available", notError: false, operation: .contains, isBack: false))
				
				errorsList.append(CheckItem(stringsToCheck: [tt, fe, le, me, lo], valuesToCheck: ["The copy of the installer app failed"], printMessage: "Bootable macOS installer creation creation failed because the process failed to copy some elements on it, mainly the installer app or it's content, can't be copied or failed to be copied, please check that your target driver is working properly and just in case erase it with disk utility, if that does not work, use another drive which is known to be working", message: "Bootable macOS installer creation failed because of an error while copying needed files, check if \"\(dname)\" is working correctly", notError: false, operation: .contains, isBack: false))
				
				//then checks for unknown errors
				errorsList.append(CheckItem(stringsToCheck: ["\(rc)"], valuesToCheck: ["0"], printMessage: "Bootable macOS installer creation creation exited with a not normal exit code, see previous lines in the log to get more info about the error", message: "Bootable macOS installer creation creation failed because of an unknown error, check the log for details", notError: false, operation: .different, isBack: false))
				
				if simulateUseScriptAuth{
					//then if the proces has not been completed correclty, probably we have an error output or an unknown output
					errorsList.append(CheckItem(stringsToCheck: ["\(rc)"], valuesToCheck: ["0"], printMessage: "Bootable macOS installer creation failed, unknown output from \"createinstallmedia\" while creating the installer, please, erase this dirve with disk utility and retry", message: "Bootable macOS installer creation failed because of an unknown output from \"\(sharedExecutableName)\", check the log for details", notError: false, operation: .equal, isBack: false))
				}
				
			}else{
				
				//then checks if the process was completed correctly
				errorsList.append(CheckItem(stringsToCheck: [llo], valuesToCheck: ["done", "install media now available at "], printMessage: "macOS install media created successfully!", message: "macOS install media created successfully", notError: true, operation: .contains, isBack: false))
				
				//then if the proces has not been completed correclty, probably we have an error output or an unknown output
				errorsList.append(CheckItem(stringsToCheck: ["\(rc)"], valuesToCheck: ["0"], printMessage: "macOS install media creation failed, unknown output from \"\(sharedExecutableName)\" while creating the installer, please, erase this dirve with disk utility and retry", message: "Bootable macOS installer creation failed because of an unknown output from \"\(sharedExecutableName)\", check the log for details", notError: false, operation: .equal, isBack: false))
				
			}
			
			//checks the conditions of the errorlist array to see if the operation has been complited with success
			for item in errorsList{
				for value in item.valuesToCheck{
					
					if self.checkMatch(item.stringsToCheck, value, operation: item.operation){
						
						log("\n\(item.printMessage)\n")
						
						if item.notError{
							var res = false
							
							DispatchQueue.main.async {
								self.progress.isHidden = false
								self.spinner.isHidden = true
							}
							
							DispatchQueue.global(qos: .background).sync {
								//here createinstall media succedes in creating the installer
								log("\(sharedExecutableName) process ended with success")
								log("Bootable macOS installer created successfully!")
								
								//extra operations here
								//trys to apply special options
								
								self.setActivityLabelText("Applaying custom options")
								
								res = self.manageSpecialOperations(true)
							}
							
							if !res{
								print("Advanced options fails")
								return
							}
							
						}
						
						if item.isBack{
							DispatchQueue.main.sync {
								self.goBack()
							}
						}else{
							DispatchQueue.main.sync {
								self.goToFinalScreen(title: item.message, success: item.notError)
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
	
	private func manageSpecialOperations(_ usesNewMethod: Bool) -> Bool{
		var ret = true
		DispatchQueue.global(qos: .background).sync {
			
			prepareToPerformSpecialOperations()
			
			let ok = self.performSpeacialOperations()
			
			#if !macOnlyMode
			
			var unmount = true
			
			if let o = oom.shared.otherOptions[oom.shared.ids.otherOptionKeepEFIpartID]?.canBeUsed(){
				unmount = !o
			}
			
			if unmount{
				self.setActivityLabelText("Unmounting partitions")
				DispatchQueue.global(qos: .background).sync {
					let _ = self.unmountConflictingDrive()
				}
			}
			
			#endif
			
			self.setActivityLabelText("Process ended, exiting ...")
			
			DispatchQueue.main.sync {
				if ok.success{
					//ok the installer creation has been completed with sucess, so it sets up the final widnow and then it's showed up
					if !sharedInstallMac && !usesNewMethod{
						self.goToFinalScreen(title: "Bootable macOS installer created successfully", success: true)
					}
					
				}else{
					
					ret = false
					
					//installer creation failed, bacause of an error with the advanced options
					
					if sharedInstallMac{
						
						log("\nOne or more errors detected during the execution of the options, the macOS installation process has been canceld, check the messages printed before this one for more details abut that erros\n")
						
					}else{
						
						log("\nOne or more errors detected during the execution of the advanced options, the bootable macOS installer will probably not work properly, so we sugegst you to restart the whole install media creation process and eventually to format the target drive using terminal or disk utility before using TINU, check the messages printed before this one for more details about that erros\n")
						
					}
					
					
					if let msg = ok.errorMessage{
						
						self.goToFinalScreen(title: msg, success: false)
						
					}else{
						
						self.goToFinalScreen(title: "Bootable macOS installer creation failed to apply the advanced options, check the log for details", success: false)
					}
				}
			}
			
		}
		
		return ret
	}
	
	private func prepareToPerformSpecialOperations(){
		if sharedInstallMac{
			if let a = cvm.shared.sharedBSDDriveAPFS{
				cvm.shared.sharedVolume = dm.shared.getDriveNameFromBSDID(a)
			}else{
				cvm.shared.sharedVolume = dm.shared.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive!)
			}
		}else{
			cvm.shared.sharedVolume = dm.shared.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive!)
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
		
		DispatchQueue.main.sync {
			self.progress.isIndeterminate = false
		}
		
		self.setProgressValue(0)
		self.setProgressMax(100)
		
		
		//testing code, exits from the function if we are in some particolar testing conditions
		if simulateNoSpecialOperations{
			return (true, nil)
		}
		
		//DispatchQueue.global(qos: .background).async{
		
		var ok = true
		
		let baseDivision: Double = 80
		
		var step: Double = baseDivision / 6
		
		log("\n\nStarting extra operations: ")
		
		if simulateSpecialOpertaionsFail{
			log("\n     Simulating a failure of the advanced options\n")
			ok = false
		}
		
		#if useEFIReplacement && !macOnlyMode
			step = baseDivision / 8
		
		DispatchQueue.main.sync {
			
			self.setProgressValue(step)
			
			self.EFICopyEnded = false
			
			self.startProgress = self.progress.doubleValue
			
			self.progressRate = step
			
			self.timer.invalidate()
			self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkEFIFolderCopyProcess(_:)), userInfo: nil, repeats: true)
		}
		
		if let m = checkOperationResult(operation: OptionalOperations.shared.mountEFIPartAndCopyEFIFolder(), res: &ok){
			return (ok, m)
		}
		
		DispatchQueue.main.sync {
			
			self.EFICopyEnded = false
			
		}
			//self.addToProgressValue(step)
		#else
			self.setProgressValue(step * 2)
			self.addToProgressValue(step)
		#endif
		
		self.addToProgressValue(step)
		
		//create readme
		if let m = checkOperationResult(operation: OptionalOperations.shared.createReadme(), res: &ok){
			return (ok, m)
		}
		
		self.addToProgressValue(step)
		
		#if !macOnlyMode
		//create IABootFiles folder
		if let m = checkOperationResult(operation: OptionalOperations.shared.createAIBootFiles(), res: &ok){
			return (ok, m)
		}
		#endif
		
		self.addToProgressValue(step)
		
		#if !macOnlyMode
		//delete the IAPhysicalMedia file
		if let m = checkOperationResult(operation: OptionalOperations.shared.deleteIAPMID(), res: &ok){
			return (ok, m)
		}
		#endif
		
		self.addToProgressValue(step)
		
		//gives to the install media the icon of the mac os installer app
		if let m = checkOperationResult(operation: OptionalOperations.shared.createIcon(), res: &ok){
			return (ok, m)
		}
		
		self.addToProgressValue(step)
		
		//copyes this app on the mac os install media
		if let m = checkOperationResult(operation: OptionalOperations.shared.createTINUCopy(), res: &ok){
			return (ok, m)
		}
		
		self.setProgressValue(baseDivision)
		
		#if !macOnlyMode
		
		step = (100 - baseDivision) / Double(BootFilesReplacementManager.shared.filesToReplace.count)
		
		self.setActivityLabelText("Replacing boot files")
		
		
		if let m = checkOperationResult(operation: OptionalOperations.shared.replaceBootFiles(step: step), res: &ok){
			return (ok, m)
		}
		
		#endif
		
		self.setProgressValue(100)
		
		self.setActivityLabelText("Checking partitions")
		
        return (ok, nil)
    }
    
    //this functrion frees the auth from apis
    private func freeAuth(){
        //free auth is called only when the processes are finished, so let's make them false
        CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
        CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
        
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
	#endif
    
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
		
		#if !installManager
        	//we no longer need authorizations, so they are feed
        	freeAuth()
		#else
			InstallMediaCreationManager.shared.freeAuth()
		#endif
    }
    
	func goToFinalScreen(title: String, success: Bool){
        //this code opens the final window
        log("Bootable macOS installer creation process ended")
        //resets window and auths
        restoreWindow()
        
        if !success{
            self.setActivityLabelText("Process failure")
        }
        
        //fixes shared variables
        FinalScreenSmallManager.shared.sharedTitle = title
        FinalScreenSmallManager.shared.sharedIsOk = success
		
		CreationVariablesManager.shared.currentPart = Part()
		
		InstallerAppManager.shared.resetCachedAppInfo()
		
        checkOtherOptions()
		
        self.openSubstituteWindow(windowStoryboardID: "MainDone", sender: self)
    }
    
    func goBack(){
        //this code opens the previus window
		
		if (CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress) && !sharedIsOnRecovery{
		
		let notification = NSUserNotification()
		
		notification.title = "TINU: bootable macOS installer creation calnceled"
		notification.informativeText = "The creation of the bootable macOS installer has been canceled, please check the tinu window if you want to try again"
		notification.contentImage = NSImage(named: "AppIcon")
		
		notification.hasActionButton = true
		
		notification.actionButtonTitle = "Close"
		
		notification.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.default.deliver(notification)
		
		}
		
        //resets window and auths
        restoreWindow()
		
        self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        //displays a dialog to check if the user is sure that user wants to stop the installer creation
		
		var spd: Bool!
		
		#if installManager
		spd = InstallMediaCreationManager.shared.stopWithAsk()
		#else
		spd = stopWithAsk()
		#endif
        
        if let stopped = spd{
            if stopped{
                if !(CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress){
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
	
	#if !installManager
    //this function trys to unmount installesd is it'f mounted because it can create problems with the install process
    public func unmountConflictingDrive() -> Bool{
		//unmount drive efi partition
		var res = true
		
		#if !macOnlyMode
		
		DispatchQueue.global(qos: .background).sync {
		
			let efiMan = EFIPartitionManager.shared
			
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
		
		log("    Unmounting \"InstallESD\"")
        if dm.shared.driveExists(path: "/Volumes/InstallESD") {
			if !NSWorkspace.shared().unmountAndEjectDevice(atPath: "/Volumes/InstallESD"){
				res = false
			}else{
				log("    \"InstallESD\" unmounted correctly or already unmounted")
			}
        }
		
		return res
    }
    
    //this function stops the current executable from running and , it does runs sudo using the password stored in memory
    public func stop(mustStop: Bool) -> Bool!{
        if let success = terminateProcess(name: sharedExecutableName){
            if success{
                //if we need to stop the process ...
                if mustStop{
                    //just tell to the rest of the app that the installer creation is no longer running
                    CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
                    CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
                    
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
		var dTitle = "Stop the bootable macOS installer creation?"
        var text = "Do you want to cancel the bootable macOS installer cration process?"
        
        if sharedInstallMac{
			dTitle = "Stop the macOS installation?"
            text = "Do you want to stop the macOS installation process?"
        }
        
		if dialogCustomWarning(question: dTitle, text: text, style: .informational, mainButtonText: "Continue", secondButtonText: "Stop" ){
            return stop(mustStop: true)
        }else{
            return true
        }
    }
	#endif
    //shows the log window
    @IBAction func showLog(_ sender: Any) {
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
    }
    
	func enableItems(enabled: Bool){
        if let apd = NSApplication.shared().delegate as? AppDelegate{
            if sharedIsOnRecovery{
                apd.InstallMacOSItem.isEnabled = enabled
            }
            apd.verboseItem.isEnabled = enabled
			apd.toolsMenuItem.isEnabled = enabled
        }
		
		#if !macOnlyMode
		if let tool = EFIPartitionMonuterTool{
			tool.close()
		}
		#endif
    }
	
	#if installManager
	public func setActivityLabelText(_ text: String){
		self.activityLabel.stringValue = text
		print("Set activity label text: \(text)")
	}
	
	func setProgressValue(_ value: Double){
		self.progress.doubleValue = value
		print("Set progress value: \(value)")
	}
	
	func addToProgressValue(_ value: Double){
		self.setProgressValue(self.progress.doubleValue + value)
	}
	
	func setProgressMax(_ max: Double){
		self.progress.maxValue = max
		print("Set progress max: \(max)")
	}
	#else
	public func setActivityLabelText(_ text: String){
		DispatchQueue.main.async{
			self.activityLabel.stringValue = text
			print("Set activity label text: \(text)")
		}
	}
	
	func setProgressValue(_ value: Double){
		DispatchQueue.main.async{
			self.progress.doubleValue = value
			print("Set progress value: \(value)")
		}
	}
	
	func addToProgressValue(_ value: Double){
		DispatchQueue.main.async{
			self.setProgressValue(self.progress.doubleValue + value)
		}
	}
	
	func setProgressMax(_ max: Double){
		DispatchQueue.main.async{
			self.progress.maxValue = max
			print("Set progress max: \(max)")
		}
	}
	#endif
}
