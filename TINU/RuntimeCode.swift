//
//  RuntimeCode.swift
//  TINU
//
//  Created by ITzTravelInTime on 17/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//functions used in in different parts of the app

//checks for the options
public func checkOtherOptions(){
	DispatchQueue.global(qos: .background).async{
		oom.shared.restoreOtherOptions()
		
		#if !macOnlyMode
		//BootFilesReplacementManager.shared.eraseReplacementFilesData()
		
		#if useEFIReplacement
		let _ = EFIFolderReplacementManager.shared.unloadEFIFolder()
		#endif
		
		#endif
		
		processLicense = ""
		
		if var item = oom.shared.otherOptions[.otherOptionForceToFormatID]{
			
			if let st = cvm.shared.sharedVolumeNeedsPartitionMethodChange{
				item.isUsable = !st
				item.isActivated = st
			}
			
			oom.shared.otherOptions[.otherOptionForceToFormatID] = item
		}
		
		if cvm.shared.sharedApp != nil{
			guard let version = iam.shared.targetAppBundleVersion(), let name = iam.shared.targetAppBundleName() else { return }
			
			cvm.shared.sharedBundleVersion = version
			cvm.shared.sharedBundleName = name
			
			var supportsTINU = false
			
			if let st = iam.shared.sharedAppNotSupportsTINU(){
				supportsTINU = st
			}
			
			if var item = oom.shared.otherOptions[.otherOptionTinuCopyID]{
				item.isUsable = !supportsTINU
				item.isActivated = !supportsTINU
				oom.shared.otherOptions[.otherOptionTinuCopyID] = item
			}
			
			if sharedInstallMac{
				var supportsAPFS = false
				
				if let st = iam.shared.sharedAppNotSupportsAPFS(){
					supportsAPFS = st
				}
				
				if let st = iam.shared.sharedAppNotIsMojave(){
					if !st{
						supportsAPFS = true
					}
				}
				
				
				if var item = oom.shared.otherOptions[.otherOptionDoNotUseApfsID]{
					item.isVisible = !supportsAPFS
					item.isActivated = !cvm.shared.sharedSVReallyIsAPFS
					item.isUsable = !cvm.shared.sharedSVReallyIsAPFS
					
					oom.shared.otherOptions[.otherOptionDoNotUseApfsID] = item
				}
			}else{
				
				#if !macOnlyMode
				
				var needsIA = false
				
				if let na = iam.shared.sharedAppSupportsIAEdit(){
					needsIA = na
				}
				
				if var item = oom.shared.otherOptions[.otherOptionCreateAIBootFID]{
					item.isActivated = false
					item.isUsable = needsIA
					oom.shared.otherOptions[.otherOptionCreateAIBootFID] = item
				}
				
				if var item = oom.shared.otherOptions[.otherOptionDeleteIAPMID]{
					item.isActivated = false
					item.isUsable = needsIA
					oom.shared.otherOptions[.otherOptionDeleteIAPMID] = item
				}
				
				#endif
			}
			
		}
		
		
		
		
	}
	
}

func checkProcessReadySate(_ useDriveIcon: inout Bool) -> Bool {
	
	let cmm = cvm.shared
	
	if let sa = cmm.sharedApp{
		print("Check installer app")
		if !FileManager.default.directoryExistsAtPath(sa){
			print("Missing installer app in the specified directory")
			return false
		}
		print("Installaer app that will be used is: " + sa)
	}else{
		print("Missing installer in memory")
		return false
	}
	
	var canFormat = false
	var apfs = false
	
	InstallMediaCreationManager.shared.OtherOptionsBeforeformat(canFormat: &canFormat, useAPFS: &apfs)
	
	if !(cvm.shared.currentPart!.isDrive || canFormat){
		print("Getting drive info about the used volume")
		if let s = cmm.sharedVolume{
			var sv = s
			
			if !FileManager.default.directoryExistsAtPath(sv){
				if let sb = cmm.sharedBSDDrive{
					if let sd = dm.getDevicePropertyInfoString(sb, propertyName: "MountPoint"){
						sv = sd
						cmm.sharedVolume = sv
						print("Corrected the name of the target volume")
					}else{
						print("Can't get the mount point!!")
						return false
					}
				}else{
					print("Can't get the device id!!")
					return false
				}
			}
			
			print("Mount point: \(sv)")
		}else{
			print("The selected volume mount point is empty")
			return false
		}
	}else{
		print("A drive has been selected or a partition that needs format")
		useDriveIcon = true
	}
	
	print("Everything is ready to start the installer creation process")
	return true
}

