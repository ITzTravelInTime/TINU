//
//  InstallingViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 27/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class InstallingViewController: GenericViewController, ViewID{
	let id: String = "InstallingViewController"
	
	@IBOutlet weak var driveName: NSTextField!
	@IBOutlet weak var driveImage: NSImageView!
	
	@IBOutlet weak var appImage: NSImageView!
	@IBOutlet weak var appName: NSTextField!
	
	//@IBOutlet weak var spinner: NSProgressIndicator!
	
	@IBOutlet weak var descriptionField: NSTextField!
	
	@IBOutlet weak var activityLabel: NSTextField!
	
    @IBOutlet weak var showLogButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
	
	//@IBOutlet weak var infoImageView: NSImageView!
	
	@IBOutlet weak var progress: NSProgressIndicator!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		
		//self.setTitleLabel(text: "Bootable macOS installer creation")
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
		self.cancelButton.title = TextManager.getViewString(context: self, stringID: "cancelButton")
        self.showLogButton.title = TextManager.getViewString(context: self, stringID: "showLogButton")
        self.descriptionField.stringValue = TextManager.getViewString(context: self, stringID: "descriptionField")
		
		self.showTitleLabel()
		
		//disable the close button of the window
		if let w = UIManager.shared.window{
			w.isMiniaturizeEnaled = false
			w.isClosingEnabled = false
			w.canHide = false
		}
		
		//infoImageView.image = IconsManager.shared.infoIcon
		
		//setup of the window if the app is in install macOS mode
		//if sharedInstallMac{
			//descriptionField.stringValue = "macOS installation in progress, please wait until the computer reboots and leave the windows as is, after that you should boot from \"macOS install\""
			
			//titleLabel.stringValue = "macOS installation in progress"
		//}
		
		//initialization
		activityLabel.stringValue = ""
		
		//placeholder values
		self.setProgressMax(1000)
		
		self.setProgressValue(0)
		
		/*if let a = NSApplication.shared().delegate as? AppDelegate{
		a.QuitMenuButton.isEnabled = false
		}*/
		
		//just prints some separators to allow me to see where this windows opens in the output
		print("*******************")
		print("* PROCESS STARTED *")
		print("*******************")
		
		setActivityLabelText("activityLabel1")
		
		//setActivityLabelText("Checking installer appilcation")
		
		print("process window opened")
		
		setUI()
	}
	
	func setUI(){
		var drive = false
		var state = false
		
		if !simulateInstallGetDataFail{
			state = !cvm.shared.checkProcessReadySate(&drive)
		}else{
			state = true
		}
		
		if state {
			setActivityLabelText("activityLabel2")
			
			log("Couldn't get valid info about the installer app and/or the drive")
			
			DispatchQueue.global(qos: .background).async{
				DispatchQueue.main.async {
					self.goBack()
				}
			}
			
			return
		}
		
		let cm = cvm.shared
		
		driveImage.image = IconsManager.shared.getCorrectDiskIcon(cvm.shared.disk.bSDDrive)
		
		if drive{
			driveImage.image = IconsManager.shared.getCorrectDiskIcon(cvm.shared.disk.bSDDrive)
			driveName.stringValue = cvm.shared.disk.driveName()!
			//self.setTitleLabel(text: "The drive and macOS installer below will be used, are you sure?")
		}else{
			let sv = cm.disk.path!
			//driveImage.image = NSWorkspace.shared.icon(forFile: sv)
			driveName.stringValue = FileManager.default.displayName(atPath: sv)
		}
		
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			driveImage.contentTintColor = .systemGray
			driveImage.image = driveImage.image?.withSymbolWeight(.thin)
		}
		
		let sa = cm.app.path!
		
		if look.usesSFSymbols(){
			appImage.image = IconsManager.shared.genericInstallerAppIcon
			if #available(macOS 11.0, *){
				appImage.contentTintColor = .systemGray
				appImage.image = appImage.image?.withSymbolWeight(.thin)
			}
		}else{
			appImage.image = IconsManager.shared.getInstallerAppIconFrom(path: sa)
		}
		
		appName.stringValue = FileManager.default.displayName(atPath: sa)
		
		log("Everything is ready to start the creation/installation process")
		
		//InstallMediaCreationManager.shared.reset()
		InstallMediaCreationManager.shared.startInstallProcess()
	}
	
	//just to be sure, if the view does disappear the installer creation is stopped
	override func viewWillDisappear() {
		/*if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
			let _ = InstallMediaCreationManager.shared.stop()
		}*/
	}
	
	private func restoreWindow(){
		//resets window
		//spinner.isHidden = true
		//spinner.stopAnimation(self)
		if let w = UIManager.shared.window{
			w.isMiniaturizeEnaled = true
			w.isClosingEnabled = true
			w.canHide = true
		}
		
		enableItems(enabled: true)
	}
	
	func goToFinalScreen(title: String, success: Bool = false){
		//this code opens the final window
		log("Bootable macOS installer creation process ended")
		//resets window and auths
		restoreWindow()
		
		FinalScreenSmallManager.shared.title = title
		//FinalScreenSmallManager.shared.isOk = success
		
		CreationVariablesManager.shared.disk.part = Part()
		
		cvm.shared.app.resetCachedAppInfo()
		cvm.shared.options.checkOtherOptions()
		
		InstallMediaCreationManager.shared.makeProcessNotInExecution(withResult: success)
		self.swapCurrentViewController("MainDone")
	}
	
	func goToFinalScreen(id: String, success: Bool = false, parseList: [String: String]! = nil){
		//this code opens the final window
		log("Bootable macOS installer creation process ended\n\n  Ending messange id: \(id)\n  Ending success: \(success ? "Yes" : "No")")
		//resets window and auths
		restoreWindow()
		
		var etitle = TextManager.getViewString(context: self, stringID: id)!
		
		if let list = parseList{
			etitle = parse(messange: etitle, keys: list)
		}
		
		goToFinalScreen(title: etitle, success: success)
	}
	
	@objc func goBack(){
		//this code opens the previus window
		
		if (cvm.shared.process.status.isBusy()){
			/*
			let notification = NSUserNotification()
			
			notification.title = "TINU: bootable macOS installer creation canceled"
			notification.informativeText = "The creation of the bootable macOS installer has been canceled, please check the TINU window if you want to try again"
			notification.contentImage = IconsManager.shared.warningIcon
			
			notification.soundName = NSUserNotificationDefaultSoundName
			NSUserNotificationCenter.default.deliver(notification)
			*/
			
			let _ = NotificationsManager.sendWith(id: "goBack", image: nil)
		}
		
		//resets window and auths
		restoreWindow()
		
		cvm.shared.process.status = .configuration
		self.swapCurrentViewController("Confirm")
	}
	
	@IBAction func cancel(_ sender: Any) {
		//displays a dialog to check if the user is sure that user wants to stop the installer creation
		
		var spd: Bool!
		
		if cvm.shared.process.status == .creation{
			spd = InstallMediaCreationManager.shared.stopWithAsk()
		}else{
			spd = true
		}
		
		if let stopped = spd{
			if stopped{
				goBack()
			}else{
				log("Error while trying to close " + cvm.shared.executableName + " try to stop it from the termianl or from Activity monitor")
				let list = ["{executable}" : cvm.shared.executableName]
				//msgBoxWarning("Error while trying to exit from the process", "There was an error while trying to close the creation process: \n\nFailed to stop ${executable} process")
				
				msgboxWithManager(self, name: "stopError", parseList: list)
			}
		}
	}
	
	//shows the log window
	@IBAction func showLog(_ sender: Any) {
		if UIManager.shared.logWC == nil {
			UIManager.shared.logWC = LogWindowController()
		}
		
		UIManager.shared.logWC?.showWindow(self)
	}
	
	func enableItems(enabled: Bool){
		if let apd = NSApplication.shared.delegate as? AppDelegate{
			if sharedIsOnRecovery{
				apd.InstallMacOSItem.isEnabled = enabled
			}
			apd.verboseItem.isEnabled = enabled
			apd.verboseItemSudo.isEnabled = enabled
			apd.toolsMenuItem.isEnabled = enabled
		}
		
		#if !macOnlyMode
		if let tool = UIManager.shared.EFIPartitionMonuterTool{
			tool.close()
		}
		#endif
	}
	
	public func setActivityLabelText(_ texta: String){
		let list = ["{executable}" : cvm.shared.executableName]
		let text = parse(messange: TextManager.getViewString(context: self, stringID: texta)!, keys: list)
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
	
	func getProgressBarValue() -> Double{
		return self.progress.doubleValue
	}
	
	func setProgressMax(_ max: Double){
		self.progress.maxValue = max
		print("Set progress max: \(max)")
	}
}
