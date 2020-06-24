//
//  MediaCreationManager.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate let pMaxVal: Double = 1000
fileprivate let pMaxMins: UInt64 = 40
fileprivate let pMidMins: UInt64 = 30

fileprivate let uDen: Double = 5

fileprivate let pMidDuration = ((pMaxVal * (uDen - 2)) / uDen)
fileprivate let pExtDuration = (pMaxVal / uDen)

public final class InstallMediaCreationManager{
	
	public static var shared = InstallMediaCreationManager()
	
	public func reset(){
		InstallMediaCreationManager.shared = InstallMediaCreationManager()
	}

	//timer to trace the process
	var timer = Timer()
	
	var pid = Int32()
	var output : [String] = []
	var error : [String] = []
	
	let  progressMaxVal: Double = pMaxVal
	
	let processEstimatedMinutes: UInt64 = pMaxMins
	
	let processMinutesToChange: UInt64 = pMidMins
	
	let processUnit: Double = pExtDuration
	
	let processDenominator: Double = uDen
	
	let unit: Double = pExtDuration / 9
	
	let installerProgressValueFast: Double = ( pMidDuration / Double(pMidMins)) / 12
	let installerProgressValueSlow: Double = ( pMidDuration / Double(pMaxMins - pMidMins)) / 12
	
	var viewController: InstallingViewController!
	
	var seconds: UInt64 = 0
	
	var dname = ""
	
	#if !macOnlyMode
	
	var startProgress: Double = 0
	
	var progressRate: Double = 0
	
	var EFICopyEnded = false
	
	#endif
	
	func startInstallProcess(){
		
		if pMaxMins <= pMidMins{
			fatalError("pMaxMins can't be smaller or equal to pMidMins")
		}
		
		viewController = sharedWindow.contentViewController as? InstallingViewController
		
		if viewController == nil{
			print("Can't get installing ViewController")
			return
		}
		
		viewController.cancelButton.isEnabled = false
		viewController.enableItems(enabled: false)
		
		self.install()
	}
	
	//this functrion just sets those 2 long ones to false
	public func makeProcessNotInExecution(){
		CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
		CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
	}
	
	//this function stops the current executable from running and , it does runs sudo using the password stored in memory
	public func stop(mustStop: Bool) -> Bool!{
		if let success = TaskKillManager.terminateProcess(PID: CreateinstallmediaSmallManager.shared.process.processIdentifier){
			if success{
				//if we need to stop the process ...
				if mustStop{
					
					CreateinstallmediaSmallManager.shared.process.terminate()
					//just tell to the rest of the app that the installer creation is no longer running
					CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
					CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
					
					//dispose timer, bacause it's no longer needed
					timer.invalidate()
					
					//auth is no longer needed
					makeProcessNotInExecution()
				}
				
				return true
			}
			
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
		
		if !dialogCritical(question: dTitle, text: text, style: .informational, proceedButtonText: "Don't Stop", cancelButtonText: "Stop" ){
			return stop(mustStop: true)
		}else{
			return nil
		}
	}
	
	public func setActivityLabelText(_ text: String){
		self.viewController.setActivityLabelText(text)
	}
	
	func setProgressValue(_ value: Double){
		self.viewController.setProgressValue(value)
	}
	
	func addToProgressValue(_ value: Double){
		self.viewController.addToProgressValue(value)
	}
	
	func setProgressMax(_ max: Double){
		self.viewController.setProgressMax(max)
	}
	
}

