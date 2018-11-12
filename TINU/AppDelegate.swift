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
    @IBOutlet weak var verboseItem: NSMenuItem!
    @IBOutlet weak var vibrantButton: NSMenuItem!
    @IBOutlet weak var tinuRelated: NSMenuItem!
    @IBOutlet weak var otherApps: NSMenuItem!
    @IBOutlet weak var QuitMenuButton: NSMenuItem!
    @IBOutlet weak var focusAreaItem: NSMenuItem!
    @IBOutlet weak var FAQItem: NSMenuItem!
    @IBOutlet weak var FAQItemHelp: NSMenuItem!
    @IBOutlet weak var InstallMacOSItem: NSMenuItem!
	
	@IBOutlet weak var getMacOSApp: NSMenuItem!
	@IBOutlet weak var wMSDIND: NSMenuItem!
	
	@IBOutlet weak var otherAppsSeparator: NSMenuItem!
	
	@IBOutlet weak var toolsMenuItem: NSMenuItem!
	@IBOutlet weak var efiMounterMenuItem: NSMenuItem!
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        if CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
            msgBoxWarning("You can't quit now", "You can't quit from TINU now, wait for the first part of the process to end or press the cancel button on the windows that asks for the password, and then quit if you want")
            return NSApplicationTerminateReply.terminateCancel
        }
        
        
        if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress{
           // if !dialogYesNoWarning(question: "Installer creation in progress in progess", text: "The installer creation is inprogress do you want to quit?", style: .warning){
			#if installManager
			if let s = InstallMediaCreationManager.shared.stopWithAsk(){
				if s{
					msgBoxWarning("Error while trying to quit", "There was an error while trying to quit from the app: \n\nFailed to stop " + sharedExecutableName + " process")
					return NSApplicationTerminateReply.terminateCancel
				}
			}else{
				return NSApplicationTerminateReply.terminateCancel
			}
			#else
                if let i = sharedWindow.contentViewController as? InstallingViewController{
					
					if let s = i.stopWithAsk(){
						if s{
                        msgBoxWarning("Error while trying to quit", "There was an error while trying to quit from the app: \n\nFailed to stop " + sharedExecutableName + " process")
                        return NSApplicationTerminateReply.terminateCancel
						}
					}else{
						return NSApplicationTerminateReply.terminateCancel
					}
                }
			#endif
            //}else{
                //return NSApplicationTerminateReply.terminateCancel
            //}
        }
        
        erasePassword()
        return NSApplicationTerminateReply.terminateNow
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        /*
        if #available(OSX 10.12.2, *) {
            NSApplication.shared().isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        */
 
        //checkUser()
        //checkAppMode()
        
        //vibrantButton.isHidden = true
        //vibrantSeparator.isHidden = true
        focusAreaItem.isHidden = true
		
		toolsMenuItem.isEnabled = true
		toolsMenuItem.isHidden = false
		
		efiMounterMenuItem.isEnabled = true
        
        if sharedIsOnRecovery{
			print("Verbose mode not usable under recovery")
			
			tinuRelated.isEnabled = false
			otherApps.isEnabled = false
			verboseItem.isEnabled = false
			
			InstallMacOSItem.isHidden = false
			
            vibrantButton.isEnabled = false
            vibrantButton.state = 0
            
            focusAreaItem.isEnabled = false
            focusAreaItem.state = 0
            
            FAQItem.isEnabled = false
			
			getMacOSApp.isEnabled = false
			wMSDIND.isEnabled = false
        }else{
			verboseItem.isEnabled = true
			tinuRelated.isEnabled = true
			otherApps.isEnabled = true
			
			InstallMacOSItem.isHidden = true
			
            vibrantButton.isEnabled = true
			
            if sharedUseVibrant{
                focusAreaItem.isEnabled = true
                vibrantButton.state = 1
            }else{
                focusAreaItem.isEnabled = false
                vibrantButton.state = 0
            }
            
            if sharedUseFocusArea{
                focusAreaItem.state = 1
            }else{
                focusAreaItem.state = 0
            }
            
            FAQItem.isEnabled = true
			
			getMacOSApp.isEnabled = true
			wMSDIND.isEnabled = true
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
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress{
			#if installManager
			if let s = InstallMediaCreationManager.shared.stop(){
				if s{
					msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
				}
			}else{
				msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
			}
			#else
            if let i = sharedWindow.contentViewController as? InstallingViewController{
                if let s = i.stop(){
					if s{
						msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
					}
				}else{
					msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
				}
            }
			#endif
        }
    }
    
	
    
    @IBAction func installMacActivate(_ sender: Any) {
        /*
        if !(sharedIsCreationInProgress || sharedIsPreCreationInProgress){
            sharedInstallMac = !sharedInstallMac
            
            if sharedInstallMac{
                InstallMacOSItem.title = "Use TINU to create a macOS install media"
            }else{
                InstallMacOSItem.title = "Use TINU to install macOS"
            }
            
            sharedWindow.contentViewController?.openSubstituteWindow(windowStoryboardID: "Info", sender: sender)
            
            restoreOtherOptions()
            
            eraseReplacementFilesData()
            
            sharedApp = nil
            sharedBSDDrive = nil
            sharedVolume = nil
        }
        */
        
        swichMode(isInstall: !sharedInstallMac)
    }
    
    public func swichMode(isInstall: Bool){
		let cim = CreateinstallmediaSmallManager.shared
		
		print("got createinstallmedia manager")
		
        if !(cim.sharedIsCreationInProgress || cim.sharedIsPreCreationInProgress){
			
			print("conditions matches")
			
            sharedInstallMac = isInstall
			
			print("sharedInstallMac set")
            
            if sharedInstallMac{
                InstallMacOSItem.title = "Use TINU to create a bootable macOS installer"
            }else{
                InstallMacOSItem.title = "Use TINU to install macOS"
            }
			
			print("menu item title set")
            
            sharedWindow.contentViewController?.openSubstituteWindow(windowStoryboardID: "Info", sender: self)
			
			print("Window switched")
			
            //restoreOtherOptions()
            
            //eraseReplacementFilesData()
			
			cvm.shared.currentPart = Part()
			
			print("Variables reset")
			
        }
		
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
	}
	
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
			/*
            if let b = Bundle.main.resourcePath{
                let f = b + "/DebugScript.sh"
                if FileManager.default.fileExists(atPath: f){
                    print("Trying to fix script permitions")
                    if let e = getOutWithSudo(cmd: "chmod -R 771 \"" + f + "\""){
                        if e == "" || e == "Password:\n" || e == "Password:" {
                            print("Script permitions fixed with success")
                            print("Restarting app with log in the terminal")
                            NSWorkspace.shared().openFile(f, withApplication: "Terminal")
                            NSApplication.shared().terminate(self)
                        }else{
                            print("Script permitions fix failed")
                            print("Application not opened: " + e)
                        }
                    }else{
                        print("Script permitions not fixed, switch to diagnostics mode aborted")
                        msgBox("Impossible to switch mode!", "The needed script to run TINU in diagnostics mode is not usable, try to downlaod again the app", .warning)
                    }
                }else{
                    
                    if !dialogYesNoWarning(question: "Diagnostics mode script missing", text: "The needed script to run TINU in diagnoistics mode is missing, do you want to create a new one?", style: .warning){
                        do {
                            try verboseScript.write(toFile: f, atomically: true, encoding: .utf8)
                            return openVerbose(_: sender)
                        }catch{
                            msgBox("Impossible to switch mode!", "The needed script to run TINU in diagnostics mode can't be written, try to downlaod again the app", .warning)
                        }
                    }
                    
                    /*
                     verboseItem.isEnabled = false
                     msgBox("Impossible to switch mode!", "The needed script to run TINU in diagnostics mode is missing, try to downlaod again the app", .warning)
                     */
                }
            }*/
			
			print("trying to use diagnostics mode")
			if let scriptPath = Bundle.main.url(forResource: "DebugScript", withExtension: "sh") {
				let theScript = "do shell script \"chmod -R 771 \'" + scriptPath.path + "\'\" with administrator privileges"
				
				print(theScript)
				
				let appleScript = NSAppleScript(source: theScript)
				
				if let eventResult = appleScript?.executeAndReturnError(nil){
					if let result = eventResult.stringValue{
						if result.isEmpty || result == "\n" || result == "Password:"{
							NSWorkspace.shared().openFile(scriptPath.path, withApplication: "Terminal")
							NSApplication.shared().terminate(self)
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
				print("no debug file found!")
				
				msgBoxWarning("Impossible to use diagnostics mode", "Needed files inside TINU are missing, so the diagnostics mode can't be used, try to download again this app and then retry.")
			}
			
        }else{
            if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
                msgBox("You can't switch mode now", "The bootable macOS installer creation process is currenly running, please cancel the operation or wait the end of the operation before switching mode", .warning)
            }else if sharedIsOnRecovery{
                msgBoxWarning("You can't switch mode now", "Switching the mode in witch TINU is running, is not allowed while running TINU on a Mac recovery/istaller")
            }
        }
    }
	
}

