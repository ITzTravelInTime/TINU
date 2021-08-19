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
		self.descriptionField.isHidden = true
		
		self.showTitleLabel()
		
		//disable the close button of the window
		if let w = UIManager.shared.window{
			w.isMiniaturizeEnaled = true
			w.isClosingEnabled = false
			//w.canHide = false
		}
		
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
		
		cancelButton.isEnabled = false
		enableItems(enabled: false)
		
		setActivityLabelText("activityLabel1")
		
		sharedSetSelectedCreationUI(appName: &appName, appImage: &appImage, driveName: &driveName, driveImage: &driveImage, manager: cvm.shared, useDriveName: cvm.shared.disk.current.isDrive || cvm.shared.disk.shouldErase)
		
		print("process window opened")
		
		DispatchQueue.global(qos: .background).async{
			var drive = false
			if (simulateInstallGetDataFail ? true : cvm.shared.checkProcessReadySate(&drive)){
				DispatchQueue.main.async {
					sharedSetSelectedCreationUI(appName: &self.appName, appImage: &self.appImage, driveName: &self.driveName, driveImage: &self.driveImage, manager: cvm.shared, useDriveName: drive)
				}
				
				log("Everything is ready to start the creation/installation process")
				
				InstallMediaCreationManager.startInstallProcess()
			}else{
				self.setActivityLabelText("activityLabel2")
				
				log("Couldn't get valid info about the installer app and/or the drive")
				
				DispatchQueue.main.sync {
					self.goBack()
				}
			}
		}
		
	}
	
	private func restoreWindow(){
		//resets window
		//spinner.isHidden = true
		//spinner.stopAnimation(self)
		if let w = UIManager.shared.window{
			w.isMiniaturizeEnaled = true
			w.isClosingEnabled = true
			//w.canHide = true
		}
		
		enableItems(enabled: true)
	}
	
	func goToFinalScreen(title: String, success: Bool = false){
		//this code opens the final window
		log("Bootable macOS installer creation process ended")
		//resets window and auths
		restoreWindow()
		
		MainCreationFinishedViewController.title = title
		
		cvm.shared.disk.current = nil
		cvm.shared.app.current = nil
		
		InstallMediaCreationManager.shared.makeProcessNotInExecution(withResult: success)
		self.swapCurrentViewController("MainDone")
	}
	
	func goToFinalScreen(id: String, success: Bool = false, parseList: [String: String]! = nil){
		//this code opens the final window
		log("Bootable macOS installer creation process ended\n\n  Ending messange id: \(id)\n  Ending success: \(success ? "Yes" : "No")")
		
		var etitle = TextManager.getViewString(context: self, stringID: id)!
		
		if let list = parseList{
			etitle = parse(messange: etitle, keys: list)
		}
		
		goToFinalScreen(title: etitle, success: success)
	}
	
	@objc func goBack(){
		//this code opens the previus window
		
		if (cvm.shared.process.status.isBusy()){
			Notifications.justSendWith(id: "goBack", icon: nil)
		}
		
		//resets window and auths
		restoreWindow()
		
		cvm.shared.process.status = .configuration
		self.swapCurrentViewController("Confirm")
	}
	
	@IBAction func cancel(_ sender: Any) {
		//displays a dialog to check if the user is sure that user wants to stop the installer creation
		
		/*
		if cvm.shared.process.status == .creation{
			spd = InstallMediaCreationManager.shared.stopWithAsk()
		}else{
			spd = true
		}*/
		
		guard let stopped = (cvm.shared.process.status == .creation ? InstallMediaCreationManager.shared.stopWithAsk() : true ) else { return }
		
		if stopped{
			goBack()
			return
		}
		
		log("Error while trying to close " + cvm.shared.executableName + " try to stop it from the termianl or from Activity monitor")
		let list = ["{executable}" : cvm.shared.executableName]
		//msgBoxWarning("Error while trying to exit from the process", "There was an error while trying to close the creation process: \n\nFailed to stop ${executable} process")
		msgboxWithManager(self, name: "stopError", parseList: list)
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
			if Recovery.status{
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
	
	func setProgressBarIndeterminateState(state: Bool){
		self.progress.isIndeterminate = state
		print("Progress bar is now \(state ? "indeterminated" : "linear")")
	}
}
