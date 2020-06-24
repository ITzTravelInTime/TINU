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
		
		if var item = oom.shared.otherOptions[oom.OtherOptionID.otherOptionForceToFormatID]{
			if let st = cvm.shared.sharedVolumeNeedsPartitionMethodChange{
				item.isUsable = !st
				item.isActivated = st
			}
		}
		
		if cvm.shared.sharedApp != nil{
			if let version = iam.shared.targetAppBundleVersion(), let name = iam.shared.targetAppBundleName(){
				cvm.shared.sharedBundleVersion = version
				cvm.shared.sharedBundleName = name
				
				var supportsTINU = false
				
				if let st = iam.shared.sharedAppNotSupportsTINU(){
					supportsTINU = st
				}
				
				var needsIA = false
				
				if let na = iam.shared.sharedAppNeedsIABoot(){
					needsIA = na
				}
				
				if var item = oom.shared.otherOptions[oom.OtherOptionID.otherOptionTinuCopyID]{
					item.isUsable = !supportsTINU
					item.isActivated = !supportsTINU
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
					
					
					if var item = oom.shared.otherOptions[oom.OtherOptionID.otherOptionDoNotUseApfsID]{
						item.isVisible = !supportsAPFS
						item.isActivated = !cvm.shared.sharedSVReallyIsAPFS
						item.isUsable = !cvm.shared.sharedSVReallyIsAPFS
					}
				}else{
					/*
					#if !macOnlyMode
					
					for i in 0...(BootFilesReplacementManager.shared.filesToReplace.count - 1){
						let item = BootFilesReplacementManager.shared.filesToReplace[i]
						
						switch item.filename{
						case "prelinkedkernel":
							item.visible = !supportsTINU
						case "kernelcache":
							item.visible = supportsTINU
						case "immutablekernel", "BridgeVersion.bin", "SecureBoot.bundle":
							item.visible = needsIA
						default:
							break
						}
						
					}
					
					#endif
					*/
					
					#if !macOnlyMode
					
					if var item = oom.shared.otherOptions[oom.OtherOptionID.otherOptionCreateAIBootFID]{
							item.isActivated = false
							item.isVisible = needsIA
					}
					
					if var item = oom.shared.otherOptions[oom.OtherOptionID.otherOptionDeleteIAPMID]{
							item.isActivated = false
							item.isVisible = needsIA
					}
					
					#endif
				}
				
			}
			
			
			
			
		}
	}

}

