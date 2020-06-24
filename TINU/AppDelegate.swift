//
//  AppDelegate.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var verboseItemSudo: NSMenuItem!
	@IBOutlet weak var verboseItem: NSMenuItem!
    //@IBOutlet weak var vibrantButton: NSMenuItem!
    @IBOutlet weak var tinuRelated: NSMenuItem!
    @IBOutlet weak var otherApps: NSMenuItem!
    @IBOutlet weak var QuitMenuButton: NSMenuItem!
    //@IBOutlet weak var focusAreaItem: NSMenuItem!
    @IBOutlet weak var FAQItem: NSMenuItem!
    @IBOutlet weak var FAQItemHelp: NSMenuItem!
    @IBOutlet weak var InstallMacOSItem: NSMenuItem!
    
    @IBOutlet weak var LogItem: NSMenuItem!
	
	@IBOutlet weak var getMacOSApp: NSMenuItem!
	@IBOutlet weak var wMSDIND: NSMenuItem!
	
	@IBOutlet weak var otherAppsSeparator: NSMenuItem!
	
	@IBOutlet weak var toolsMenuItem: NSMenuItem!
	@IBOutlet weak var efiMounterMenuItem: NSMenuItem!
	
	func getVerboseItem(isSudo: Bool) -> NSMenuItem!{
		if isSudo{
			return verboseItemSudo
		}else{
			return verboseItem
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
		print("Should terminate called")
        if CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
            msgBoxWarning("You can't quit now", "You can't quit from TINU now, wait for the first part of the process to end or press the cancel button on the windows that asks for the password, and then quit if you want")
            return NSApplicationTerminateReply.terminateCancel
        }else if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress{
			var spd: Bool!
				
			spd = InstallMediaCreationManager.shared.stopWithAsk()
				
			if let stopped = spd{
				if !stopped{
					print("Terminate failed")
					return NSApplicationTerminateReply.terminateCancel
				}
			}else{
				print("Terminate cancelled")
				return NSApplicationTerminateReply.terminateCancel
			}
        }
		
        return NSApplicationTerminateReply.terminateNow
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
		
		toolsMenuItem.isEnabled = true
		toolsMenuItem.isHidden = false
		
		efiMounterMenuItem.isEnabled = true
		
		//focusAreaItem.isHidden = true
		//vibrantButton.isHidden = true
		
		tinuRelated     .isEnabled = !sharedIsOnRecovery
		otherApps       .isEnabled = !sharedIsOnRecovery
		verboseItem     .isEnabled = !sharedIsOnRecovery
		verboseItemSudo .isEnabled = !sharedIsOnRecovery
		FAQItem         .isEnabled = !sharedIsOnRecovery
		getMacOSApp     .isEnabled = !sharedIsOnRecovery
		wMSDIND         .isEnabled = !sharedIsOnRecovery
		
		InstallMacOSItem.isHidden =  !sharedIsOnRecovery
		
        
        if sharedIsOnRecovery{
			print("Verbose mode not usable under recovery")
        }
        
        FAQItemHelp.isEnabled = FAQItem.isEnabled
		
		#if macOnlyMode
			otherApps.isHidden = true
			otherAppsSeparator.isHidden = true
			toolsMenuItem.isHidden = true
		#endif
		
        if Bundle.main.url(forResource: "License", withExtension: "rtf") == nil{
            sharedShowLicense = false
            print("License agreement file not found")
        }else{
            sharedShowLicense = true
            print("License agreement file found")
        }
		
		#if demo
		demoMacroEnabled = true
		#endif
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress{
			if let s = InstallMediaCreationManager.shared.stop(){
				if s{
					msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
				}
			}else{
				msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
			}
        }
    }
    
	
    
    @IBAction func installMacActivate(_ sender: Any) {
        swichMode(isInstall: !sharedInstallMac)
    }
    
    public func swichMode(isInstall: Bool){
		
        if !(CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress){
			
            sharedInstallMac = isInstall
			
            if sharedInstallMac{
                InstallMacOSItem.title = "Use TINU to create a bootable macOS installer"
            }else{
                InstallMacOSItem.title = "Use TINU to install macOS"
            }
            sharedWindow.contentViewController?.sawpCurrentViewController(with: "Info", sender: self)
			
            //restoreOtherOptions()
            
            //eraseReplacementFilesData()
			
			cvm.shared.currentPart = Part()
        }
		
    }
    
    @IBAction func showLog(_ sender: Any) {
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
    }
    
    @IBAction func openContacts(_ sender: Any) {
        //open here a window with all the contacts inside
        
        if contactsWindowController == nil {
            contactsWindowController = ContactsWindowController()
        }
        
        contactsWindowController?.showWindow(self)
        
    }
    
    @IBAction func openCredits(_ sender: Any) {
        //open here a window with all the credits inside
        
        if creditsWindowController == nil {
            creditsWindowController = CreditsWindowController()
        }
        
        creditsWindowController?.showWindow(self)
        
    }
	
	/*
	@IBAction func checkVibrantLook(_ sender: Any) {
		if sharedUseVibrant{
			sharedUseVibrant = false
			vibrantButton.state = 0
		}else{
			sharedUseVibrant = true
			vibrantButton.state = 1
		}
		
		focusAreaItem.isEnabled = sharedUseVibrant
		
	}
	
	@IBAction func checkFocusArea(_ sender: Any) {
		if canUseVibrantLook{
			if sharedUseFocusArea{
				focusAreaItem.state = 0
			}else{
				focusAreaItem.state = 1
			}
			sharedUseFocusArea = !sharedUseFocusArea
		}
	}*/
	
	@IBAction func openEFIPartitionTool(_ sender: Any) {
		
		#if !macOnlyMode
		
		if EFIPartitionMonuterTool == nil{
			EFIPartitionMonuterTool = EFIPartitionMounterWindowController()
		}
		
		EFIPartitionMonuterTool.showWindow(self)
		
		#endif
	}
	
	@IBAction func openWMSDIND(_ sender: Any) {
		if wMSDINDWindow == nil{
			wMSDINDWindow = DriveDetectInfoWindowController()
		}
		
		wMSDINDWindow.showWindow(self)
	}
	
	@IBAction func openDownloadMacApp(_ sender: Any) {
		if downloadAppWindow == nil{
			downloadAppWindow = DownloadAppWindowController()
		}
		
		downloadAppWindow.showWindow(self)
	}
	
	@IBAction func openFAQs(_ sender: Any) {
		openURl("https://github.com/ITzTravelInTime/TINU/wiki/FAQs")
	}
	
	@IBAction func OpenGithub(_ sender: Any) {
		openURl("https://github.com/ITzTravelInTime/TINU")
	}
	
	@IBAction func InsanelyMacThread(_ sender: Any) {
		openURl("http://www.insanelymac.com/forum/topic/326959-tinu-the-macos-installer-creator-app-mac-app/")
	}
	
	@IBAction func InsanelyMacThreadIta(_ sender: Any) {
		openURl("https://www.insanelymac.com/forum/forums/topic/333261-tinu-app-per-creare-chiavette-di-installazione-di-macos-thread-in-italiano/")
	}
	
    @IBAction func VoodooTSCSyncConfigurator(_ sender: Any) {
		openURl("http://www.insanelymac.com/forum/files/file/744-voodootscsync-configurator/")
    }
	
	private func openURl(_ sURL: String){
		if let checkURL = NSURL(string: sURL) {
			if NSWorkspace.shared().open(checkURL as URL) {
				print("url successfully opened: " + String(describing: checkURL))
			}
		} else {
			print("invalid url")
		}
	}
    
    @IBAction func openVerbose(_ sender: Any) {
        if !(CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress || sharedIsOnRecovery){
			
			print("trying to use diagnostics mode")
			
			let isSudo = (sender as? NSMenuItem) == verboseItemSudo
			
			let resourceName = isSudo ? "DebugScriptSudo" : "DebugScript"
			
			if let scriptPath = Bundle.main.url(forResource: resourceName, withExtension: "sh")?.path {
				
				var val: Int16 = 1;
				
				do{
					if let perm = (try FileManager.default.attributesOfItem(atPath: scriptPath)[FileAttributeKey.posixPermissions] as? NSNumber)?.int16Value{
						val = perm
					}
					
				}catch let err{
					print(err)
				}
				
				if val != 0o771{
					
					let theScript = "do shell script \"chmod -R 771 \'" + scriptPath + "\'\" with administrator privileges"
					
					print(theScript)
					
					let appleScript = NSAppleScript(source: theScript)
					
					if let eventResult = appleScript?.executeAndReturnError(nil){
						if let result = eventResult.stringValue{
							if result.isEmpty || result == "\n" || result == "Password:"{
								val = 0;
							}else{
								print("error with the script output: " + result)
								msgBoxWarning("Impossible to use diagnostics mode", "Something went wrong when preparing TINU to be run in diagnostics mode.\n\n[error code: 0]\n\nScript output: \(result)")
							}
						}
					}else{
						print("impossible to execute the apple script to prepare the app")
						
						msgBoxWarning("Impossible to use diagnostics mode", "Impossible to prepare TINU to run in diagnostics mode.\n\n[error code: 1]")
					}
					
				}else{
					val = 0
				}
				
				if val == 0{
					NSWorkspace.shared().openFile(scriptPath, withApplication: "Terminal")
					NSApplication.shared().terminate(self)
				}
			}else{
				print("no debug file found!")
				
				msgBoxWarning("Impossible to use diagnostics mode", "Needed files inside TINU are missing, so the diagnostics mode can't be used. Download this app again and then try again.")
			}
			
        }else{
			if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
				msgBox("You can't switch mode now", "The bootable macOS installer creation process is currenly running. Please cancel the operation or wait for the operation to end before switching the mode.", .warning)
			}else if sharedIsOnRecovery{
				msgBoxWarning("You can't switch the mode right now", "Switching the mode in which TINU is running is not possible while running TINU from this recovery/installer system.")
			}
        }
    }
	
}

