/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa
import Command
import CommandSudo

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, ViewID {
	
	let id: String = "AppDelegate"
	
    @IBOutlet weak var verboseItemSudo: NSMenuItem!
	@IBOutlet weak var verboseItem: NSMenuItem!
    //@IBOutlet weak var vibrantButton: NSMenuItem!
    @IBOutlet weak var contactUS: NSMenuItem!
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
	
	func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification){
		
		if (notification.userInfo?["shouldOpenUpdateLinks"] as? String) == "true"{
			if notification.additionalActivationAction?.identifier == "DIRECT_DOWNLOAD"{
				UpdateManager.UpdateStruct.getUpdateData().update.openDirectDownloadOrWebpage()
			}else if notification.activationType == .contentsClicked || notification.activationType == .actionButtonClicked{
				UpdateManager.UpdateStruct.getUpdateData().update.openWebPageOrDirectDownload()
			}
		}
		
		NSUserNotificationCenter.default.removeDeliveredNotification(notification)
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
				
			//spd = InstallMediaCreationManager.shared.stopWithAsk()
				
			spd = (cvm.shared.maker != nil) ? cvm.shared.maker?.stopWithAsk() : true
			
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
		contactUS       .isEnabled = rec
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
		
		UIManager.shared.showLicense = false//(Bundle.main.url(forResource: "License", withExtension: "rtf") != nil)
		
		/*
		if UIManager.shared.showLicense{
            print("License agreement file not found")
        }else{
            print("License agreement file found")
        }
		*/
		
		Command.Sudo.authNotification = Notifications.make(id: "login", icon: nil)
		
		#if demo
		demoMacroEnabled = true
		#endif
        
		UpdateManager.UpdateStruct.getUpdateData(forceRefetch: true)?.update.checkAndSendUpdateNotification()
    }
	
	
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
		if cvm.shared.process.status != .creation || cvm.shared.maker == nil{
			return
		}
			
			let list = ["{executable}" : cvm.shared.executableName]
			
			//guard let s = InstallMediaCreationManager.shared.stop() else{
		
			guard let s = cvm.shared.maker?.stop() else{
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
    
    @IBAction func openVerbose(_ sender: Any) {
		DiagnosticsModeManager.shared.open(withSudo: ((sender as! NSMenuItem) == verboseItemSudo))
    }
	
}

