//
//  AppDelegate.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa
import Command
import CommandSudo

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, ViewID {
	
	let id: String = "AppDelegate"
	
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
	
	#if sudoStartup
	private var useChange = true
	#endif
	
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		return true
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		log("Should terminate called")
		
		if cvm.shared.process.status == .preCreation || cvm.shared.process.status == .postCreation {
            //msgBoxWarning("You can't quit now", "You can't quit from TINU now, wait for the first part of the process to end or press the cancel button on the windows that asks for the password, and then quit if you want")
			msgboxWithManager(self, name: "cantQuiNow")
            return NSApplication.TerminateReply.terminateCancel
		}else if cvm.shared.process.status == .creation{
			var spd: Bool!
				
			spd = InstallMediaCreationManager.shared.stopWithAsk()
				
			guard let stopped = spd else{
				print("Terminate cancelled")
				return NSApplication.TerminateReply.terminateCancel
			}
			
			if !stopped{
				print("Terminate failed")
				return NSApplication.TerminateReply.terminateCancel
			}
        }
		
        return NSApplication.TerminateReply.terminateNow
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
		
		App.Settings.check()
		LogManager.readLoggedDebugLines = false
		LogManager.showPrefixesIntoLoggedLines = false
		
		NSUserNotificationCenter.default.delegate = self
		
		toolsMenuItem.isEnabled = true
		toolsMenuItem.isHidden = false
		
		efiMounterMenuItem.isEnabled = true
		
		//focusAreaItem.isHidden = true
		//vibrantButton.isHidden = true
		
		let rec = !Recovery.status
		tinuRelated     .isEnabled = rec
		otherApps       .isEnabled = rec
		verboseItem     .isEnabled = rec
		verboseItemSudo .isEnabled = rec
		FAQItem         .isEnabled = rec
		getMacOSApp     .isEnabled = rec
		wMSDIND         .isEnabled = rec
		
		InstallMacOSItem.isHidden = rec
		
        
        if !rec{
			print("Verbose mode not usable under recovery")
        }
        
        FAQItemHelp.isEnabled = FAQItem.isEnabled
		
		#if macOnlyMode
			otherApps.isHidden = true
			otherAppsSeparator.isHidden = true
			toolsMenuItem.isHidden = true
		#endif
		
		UIManager.shared.showLicense = (Bundle.main.url(forResource: "License", withExtension: "rtf") != nil)
		
		if UIManager.shared.showLicense{
            print("License agreement file not found")
        }else{
            print("License agreement file found")
        }
		
		Command.Sudo.authNotification = Notifications.make(id: "login", icon: nil)
		
		#if demo
		demoMacroEnabled = true
		#endif
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
		if cvm.shared.process.status != .creation{
			return
		}
			
			let list = ["{executable}" : cvm.shared.executableName]
			
			guard let s = InstallMediaCreationManager.shared.stop() else{
				//msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
				
				msgboxWithManager(self, name: "stopFailed", parseList: list)
				log("Quit error 2")
				return
			}
			
			if !s{
				//msgBoxWarning("Error while trying to quit", "There was an error while trying to qui from the app: \n\nFailed to stop " + sharedExecutableName + " process")
					
				msgboxWithManager(self, name: "stopFailed", parseList: list)
				log("Quit error 1")
			}
    }
    
	
    
    @IBAction func installMacActivate(_ sender: Any) {
        swichMode(isInstall: !cvm.shared.installMac)
    }
    
    public func swichMode(isInstall: Bool){
		
		if !(cvm.shared.process.status.isBusy()){
			
			cvm.shared.installMac = isInstall
			/*
            if sharedInstallMac{
                InstallMacOSItem.title = "Use TINU to create a bootable macOS installer"
            }else{
                InstallMacOSItem.title = "Use TINU to install macOS"
            }*/
			
			InstallMacOSItem.title = TextManager.getViewString(context: self, stringID: "switchText")
			
			UIManager.shared.window.contentViewController?.swapCurrentViewController("Info")
			
            //restoreOtherOptions()
            
            //eraseReplacementFilesData()
			
			cvm.shared.disk.current = nil
        }
		
    }
    
    @IBAction func showLog(_ sender: Any) {
        if UIManager.shared.logWC == nil {
			UIManager.shared.logWC = LogWindowController()
        }
        
		UIManager.shared.logWC!.showWindow(self)
    }
    
    @IBAction func openContacts(_ sender: Any) {
        //open here a window with all the contacts inside
        
        if UIManager.shared.contactsWC == nil {
			UIManager.shared.contactsWC = ContactsWindowController()
        }
        
		UIManager.shared.contactsWC?.showWindow(self)
        
    }
    
    @IBAction func openCredits(_ sender: Any) {
        //open here a window with all the credits inside
        
        if UIManager.shared.creditsWC == nil {
			UIManager.shared.creditsWC = CreditsWindowController()
        }
        
		UIManager.shared.creditsWC?.showWindow(self)
        
    }
	
	@IBAction func openEFIPartitionTool(_ sender: Any) {
		
		#if !macOnlyMode
		
		if UIManager.shared.EFIPartitionMonuterTool == nil{
			UIManager.shared.EFIPartitionMonuterTool = EFIPartitionMounterWindowController()
		}
		
		UIManager.shared.EFIPartitionMonuterTool.showWindow(self)
		
		#endif
	}
	
	@IBAction func openWMSDIND(_ sender: Any) {
		if UIManager.shared.detectionInfoWC == nil{
			UIManager.shared.detectionInfoWC = DriveDetectInfoWindowController()
		}
		
		UIManager.shared.detectionInfoWC.showWindow(self)
	}
	
	@IBAction func openDownloadMacApp(_ sender: Any) {
		if UIManager.shared.downloadAppWC == nil{
			UIManager.shared.downloadAppWC = DownloadAppWindowController()
		}
		
		UIManager.shared.downloadAppWC.showWindow(self)
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
		guard let checkURL = NSURL(string: sURL) else {
			print("invalid url")
			return
		}
			
		if NSWorkspace.shared.open(checkURL as URL) {
			print("url successfully opened: " + String(describing: checkURL))
		}
	}
    
    @IBAction func openVerbose(_ sender: Any) {
		DiagnosticsModeManager.shared.open(withSudo: ((sender as! NSMenuItem) == verboseItemSudo))
    }
	
}

