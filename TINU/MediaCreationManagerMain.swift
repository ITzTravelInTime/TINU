//
//  MediaCreationManager.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public typealias IMCM = InstallMediaCreationManager

public final class InstallMediaCreationManager{
	
	static var cpc: ProcessConsts = ProcessConsts()
	
	public static var shared = InstallMediaCreationManager()
	var lastMinute: UInt64 = 0
	var lastSecs: UInt64 = 0

	//timer to trace the process
	var timer = Timer()
	
	var pid = Int32()
	var output : [String] = []
	var error : [String] = []
	
	var progressMaxVal: Double {return  IMCM.cpc.pMaxVal }
	var processUnit:    Double {return  IMCM.cpc.pExtDuration }
	
	var processEstimatedMinutes: UInt64 {return  IMCM.cpc.pMaxMins }
	var processMinutesToChange:  UInt64 {return  IMCM.cpc.pMidMins }
	
	//progress bar increments during installer creation
	var installerProgressValueFast: Double {return IMCM.cpc.installerProgressValueFast}
	var installerProgressValueSlow: Double {return IMCM.cpc.installerProgressValueSlow}
	
	//static let processDivisor: Double = ProcessConsts.uDen
	
	//n of pre-process operations
	static let preCount: UInt8 = 10
	
	//progress bar segments of the pre-process
	static var unit: Double = 0
	
	var viewController: InstallingViewController!
	
	var dname = ""
	
	
	//EFI copyng stuff
	#if !macOnlyMode
	
	var startProgress: Double = 0
	
	var progressRate: Double = 0
	
	var EFICopyEnded = false
	
	#endif
	
	private func reset(){
		//cleans it's won memory first
		IMCM.shared = InstallMediaCreationManager()
		//gets fresh info about the management of the progressbar
		IMCM.cpc = ProcessConsts.createFromDefaultFile()
		//claculates the division for the progrees bar usage outside the main process
		IMCM.unit = IMCM.cpc.pExtDuration / Double(IMCM.preCount)
		
	}
	
	func startInstallProcess(){
		
		reset()
		
		viewController = sharedWindow.contentViewController as? InstallingViewController
		
		if viewController == nil{
			fatalError("Can't get installing ViewController")
		}
		
		viewController.setProgressMax(IMCM.cpc.pMaxVal)
		
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
	
	func getProgressBarValue() -> Double{
		return self.viewController!.getProgressBarValue()
	}
	
}

