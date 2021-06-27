//
//  MediaCreationManager.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public typealias IMCM = InstallMediaCreationManager

public final class InstallMediaCreationManager: ViewID{
	
	public let id: String = "InstallMediaCreationManager"
	
	static var cpc: ProcessConsts = CodableCreation<ProcessConsts>.createFromDefaultFile(false)!
	
	public static var shared = InstallMediaCreationManager()
	
	
	var lastMinute: UInt64 = 0
	var lastSecs: UInt64 = 0

	//timer to trace the process
	var timer = Timer()
	
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
	
	//EFI copying stuff
	#if !macOnlyMode
	
	var startProgress: Double = 0
	
	var progressRate: Double = 0
	
	var EFICopyEnded = false
	
	#endif
	
	init(){
		DispatchQueue.global(qos: .userInteractive).sync {
			//gets fresh info about the management of the progressbar
			IMCM.cpc = CodableCreation<ProcessConsts>.createFromDefaultFile(false)!
		
			if !ProcessConsts.checkInstance(IMCM.cpc){
				fatalError("Bad progress bar settings")
			}
		
			//claculates the division for the progrees bar usage outside the main process
			IMCM.unit = IMCM.cpc.pExtDuration / Double(IMCM.preCount)
		}
	}
	
	/** Prepares the UI to then start the creation process, this function needs to be executed into the main thread because if it's usage of UI */
	class func startInstallProcess(){
		//cleans it's own memory first
		IMCM.shared = InstallMediaCreationManager()
		
		IMCM.shared.viewController = UIManager.shared.window.contentViewController as? InstallingViewController
		
		if IMCM.shared.viewController == nil{
			fatalError("Can't get installing ViewController")
		}
		
		IMCM.shared.viewController.setProgressMax(IMCM.cpc.pMaxVal)
		
		IMCM.shared.install()
	}
	
	//this functrion just sets those 2 long ones to false
	public func makeProcessNotInExecution(withResult res: Bool){
		//cvm.shared.process.isPreCreationInProgress = false
		//cvm.shared.process.isCreationInProgress = false
		
		cvm.shared.process.status = res ? .doneSuccess : .doneFailure
	}
	
	//this function stops the current executable from running and , it does runs sudo using the password stored in memory
	public func stop(mustStop: Bool) -> Bool!{
		guard let success = TaskKillManager.terminateProcess(PID: cvm.shared.process.handle.process.processIdentifier) else { return false }
		
		if !success{
			return false
		}
			
		//if we need to stop the process...
		if mustStop{
				
			cvm.shared.process.handle.process.terminate()
				
			//dispose timer, bacause it's no longer needed
			timer.invalidate()
			
			makeProcessNotInExecution(withResult: true)
		}
			
		return true
		
	}
	
	//just stops the whole process and sets the related variables
	public func stop() -> Bool!{
		return stop(mustStop: true)
	}
	
	//asks if the suer wants to stop the process
	func stopWithAsk() -> Bool!{/*
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
		}*/
		
		if dialogGenericWithManagerBool(self, name: "stop", parseList: nil, style: .informational, icon: nil){
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

