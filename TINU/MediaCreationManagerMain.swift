//
//  MediaCreationManager.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa
import SecurityFoundation

#if recovery

import LocalAuthentication

#endif

fileprivate let pMaxVal: Double = 1000
fileprivate let pMaxMins: UInt64 = 30
fileprivate let pMidMins: UInt64 = 15

fileprivate let uDen: Double = 5

fileprivate let pMidDuration = (pMaxVal * (1/uDen) * (uDen - 2))
fileprivate let pExtDuration = (pMaxVal * (1/uDen))

public final class InstallMediaCreationManager{
	
	public static var shared = InstallMediaCreationManager()
	
	public func reset(){
		InstallMediaCreationManager.shared = InstallMediaCreationManager()
	}
	
	//is used to determnate if old or new auth pis were used
	var usedLA = false
	
	//variables used to check the success of the authentication
	private var osStatus: OSStatus = 0
	private var osStatus2: OSStatus = 0
	
	//references we need to free the permitions later
	private var authRef2: AuthorizationRef?
	private var authFlags = AuthorizationFlags([])
	
	//timer to trace the process
	var timer = Timer()
	
	var pid = Int32()
	var output : [String] = []
	var error : [String] = []
	
	var progressMaxVal: Double{
		get{
			return pMaxVal
		}
	}
	
	var processEstimatedMinutes: UInt64{
		get{
			return pMaxMins
		}
	}
	
	var processMinutesToChange: UInt64{
		get{
			return pMidMins
		}
	}
	
	var processUnit: Double{
		get{
			return pExtDuration
		}
	}
	
	var processDenominator: Double{
		get{
			return uDen
		}
	}
	
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
	
	func askFirstAuthOldWay() -> Bool{
		let b = Bundle.main
		
		var authRef: AuthorizationRef? = nil
		
		self.osStatus = AuthorizationCreate(nil, nil, self.authFlags, &authRef)
		var myItems = [
			AuthorizationItem(name: b.bundleIdentifier! + ".sudo", valueLength: 0, value: nil, flags: 0),
			AuthorizationItem(name: b.bundleIdentifier! + ".createinstallmedia", valueLength: 0, value: nil, flags: 0)
		]
		var myRights = AuthorizationRights(count: UInt32(myItems.count), items: &myItems)
		let myFlags : AuthorizationFlags = [.interactionAllowed, .extendRights, .destroyRights, .preAuthorize]
		
		self.osStatus2 = AuthorizationCreate(&myRights, nil, myFlags, &self.authRef2)
		
		
		//simulates an uthentication fail or cancel
		if simulateFirstAuthCancel{
			self.osStatus = 1
			self.osStatus2 = 1
		}
		
		//checks if the authentication is successfoul
		/*if self.osStatus != 0 || self.osStatus2 != 0{
		//the user does not gives the authentication, so we came back to previous window
		DispatchQueue.main.sync {
		log("Authentication aborted")
		self.goBack()
		}
		return
		}*/
		
		return (self.osStatus == 0 && self.osStatus2 == 0)
	}
	
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
		
		DispatchQueue.global(qos: .background).async{
			
			//let driveID = DrivesManager.getCurrentDriveName()
			
			if simulateUseScriptAuth{
				DispatchQueue.main.sync {
					self.usedLA = false
					self.install()
				}
				return
			}
			
			if sharedIsReallyOnRecovery{
				DispatchQueue.main.sync {
					self.usedLA = false
					self.install()
				}
				return
			}else{
				DispatchQueue.main.sync {
				self.setActivityLabelText("First step authentication")
				}
				log("Asking user for autentication")
			}
			
			#if noFirstAuth
			
			DispatchQueue.main.sync {
				self.usedLA = true
				self.install()
			}
			
			return
			
			#else
			
			#if recovery
			if #available(macOS 10.11, *) {
				if !(simulateFirstAuthCancel || sharedIsOnRecovery) {
					
					log("Trying to do user authentication using local authentication APIs")
					
					let myContext = LAContext()
					
					let myLocalizedReasonString = "create a bootable bootable macOS installer"
					
					var authError: NSError?
					
					if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError){
						myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
							if success && !simulateFirstAuthCancel{
								// User authenticated successfully, take appropriate action
								log("Authentication using local authentication APIs completed with success")
								//calls the install function to start the installer creation process
								DispatchQueue.main.sync {
									self.usedLA = true
									self.install()
								}
							} else {
								// User did not authenticate successfully, look at error and take appropriate action
								var desc = ""
								if let e = evaluateError{
									desc = e.localizedDescription
								}
								
								log("Authentication fail using local authentication APIs:\n     \(desc)")
								DispatchQueue.main.sync {
									self.goBack()
								}
							}
							return
						}
						return
					}
				}
				
			}
			#endif
			
			log("Trying to do user authentication using security foundation APIs")
			
			if !self.askFirstAuthOldWay() || simulateFirstAuthCancel{
				log("Authentication fail using security foundation APIs")
				DispatchQueue.main.sync {
					self.viewController.goBack()
				}
			}else{
				log("Authentivcation with security foundation APIs completed with success")
				//calls the install function to start the installer creation process
				DispatchQueue.main.sync {
					self.usedLA = false
					self.install()
				}
			}
			return
			
			#endif
		}
	}
	
	//this functrion frees the auth from apis
	public func freeAuth(){
		//free auth is called only when the processes are finished, so let's make them false
		CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
		CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
		
		//since into the recovery we do not need the spacial authorization, we just free it when running on a normal mac os environment
		if !sharedIsOnRecovery{
			erasePassword()
			
			if !usedLA{
				if authRef2 != nil && !authFlags.isEmpty{
					//we no longer need the special authorization, so it is freed
					if AuthorizationFree(authRef2!, authFlags) == 0{
						DispatchQueue.main.async {
							log("AutorizationFree executed successfully")
						}
					}else{
						DispatchQueue.main.async {
							log("AutorizationFree failed")
						}
					}
				}
			}
		}
	}
	
	//this function stops the current executable from running and , it does runs sudo using the password stored in memory
	public func stop(mustStop: Bool) -> Bool!{
		if let success = terminateProcess(name: sharedExecutableName){
			if success{
				//if we need to stop the process ...
				if mustStop{
					//just tell to the rest of the app that the installer creation is no longer running
					CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress = false
					CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
					
					//dispose timer, bacause it's no longer needed
					timer.invalidate()
					
					//auth is no longer needed
					freeAuth()
				}
				
				return true
			}
			
		}else{
			return nil
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
		
		if dialogCriticalWarning(question: dTitle, text: text, style: .informational, proceedButtonText: "Don't Stop", cancelButtonText: "Stop" ){
			return stop(mustStop: true)
		}else{
			return true
		}
	}
	
	public func setActivityLabelText(_ text: String){
		/*DispatchQueue.global(qos: .background).sync {
			DispatchQueue.main.sync {*/
				self.viewController.setActivityLabelText(text)
			/*}
		}*/
	}
	
	func setProgressValue(_ value: Double){
		/*DispatchQueue.global(qos: .background).sync {
			DispatchQueue.main.sync {*/
				self.viewController.setProgressValue(value)
			/*}
		}*/
	}
	
	func addToProgressValue(_ value: Double){
		/*DispatchQueue.global(qos: .background).sync {
			DispatchQueue.main.sync {*/
				self.viewController.addToProgressValue(value)
			/*}
		}*/
	}
	
	func setProgressMax(_ max: Double){
		/*DispatchQueue.global(qos: .background).sync {
			DispatchQueue.main.sync {*/
				self.viewController.setProgressMax(max)
			/*}
		}*/
	}
	
}

