//
//  InstallingViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 27/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa
import SecurityFoundation

class InstallingViewController: GenericViewController{
	@IBOutlet weak var driveName: NSTextField!
	@IBOutlet weak var driveImage: NSImageView!
	
	@IBOutlet weak var appImage: NSImageView!
	@IBOutlet weak var appName: NSTextField!
	
	@IBOutlet weak var spinner: NSProgressIndicator!
	
	@IBOutlet weak var descriptionField: NSTextField!
	
	@IBOutlet weak var activityLabel: NSTextField!
	
	@IBOutlet weak var cancelButton: NSButton!
	
	@IBOutlet weak var infoImageView: NSImageView!
	
	@IBOutlet weak var progress: NSProgressIndicator!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		
		self.setTitleLabel(text: "Bootable macOS installer creation")
		self.showTitleLabel()
		
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
			
			titleLabel.stringValue = "macOS installation in progress"
		}
		
		activityLabel.stringValue = ""
		
		self.setProgressMax(InstallMediaCreationManager.shared.progressMaxVal)
		
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
			appImage.image = IconsManager.shared.getInstallerAppIconFrom(path: sa)
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
			
			InstallMediaCreationManager.shared.reset()
			InstallMediaCreationManager.shared.startInstallProcess()
		}
	}
	
	//just to be sure, if the view does disappear the installer creation is stopped
	override func viewWillDisappear() {
		/*if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
			let _ = InstallMediaCreationManager.shared.stop()
		}*/
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
		
		//no more need for auth
		InstallMediaCreationManager.shared.makeProcessNotInExecution()
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
		FinalScreenSmallManager.shared.title = title
		FinalScreenSmallManager.shared.isOk = success
		
		CreationVariablesManager.shared.currentPart = Part()
		
		InstallerAppManager.shared.resetCachedAppInfo()
		
		checkOtherOptions()
		
		self.sawpCurrentViewController(with: "MainDone", sender: self)
	}
	
	func goBack(){
		//this code opens the previus window
		
		if (CreateinstallmediaSmallManager.shared.sharedIsBusy) && !sharedIsOnRecovery{
			
			let notification = NSUserNotification()
			
			notification.title = "TINU: bootable macOS installer creation canceled"
			notification.informativeText = "The creation of the bootable macOS installer has been canceled, please check the TINU window if you want to try again"
			notification.contentImage = IconsManager.shared.warningIcon
			
			notification.hasActionButton = true
			
			notification.actionButtonTitle = "Close"
			
			notification.soundName = NSUserNotificationDefaultSoundName
			NSUserNotificationCenter.default.deliver(notification)
			
		}
		
		//resets window and auths
		restoreWindow()
		
		self.sawpCurrentViewController(with: "Confirm", sender: self)
	}
	
	@IBAction func cancel(_ sender: Any) {
		//displays a dialog to check if the user is sure that user wants to stop the installer creation
		
		var spd: Bool!
		
		spd = InstallMediaCreationManager.shared.stopWithAsk()
		
		if let stopped = spd{
			if stopped{
				if !(CreateinstallmediaSmallManager.shared.sharedIsBusy){
					goBack()
				}
			}else{
				log("Error while trying to close " + sharedExecutableName + " try to stop it from the termianl or from Activity monitor")
				msgBoxWarning("Error while trying to exit from the process", "There was an error while trying to close the creation process: \n\nFailed to stop " + sharedExecutableName + " process")
			}
		}
	}
	
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
			apd.verboseItemSudo.isEnabled = enabled
			apd.toolsMenuItem.isEnabled = enabled
		}
		
		#if !macOnlyMode
		if let tool = EFIPartitionMonuterTool{
			tool.close()
		}
		#endif
	}
	
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
}
