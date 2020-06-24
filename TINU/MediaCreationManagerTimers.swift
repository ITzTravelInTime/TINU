//
//  MediaCreationManagerTimers.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate let minutesRatio: UInt64 = 60

extension InstallMediaCreationManager{
	
	@objc func increaseProgressBar(_ sender: AnyObject){
		DispatchQueue.global(qos: .userInteractive).async {
			self.seconds += 1
			print(String(self.seconds) + " sec")
		if CreateinstallmediaSmallManager.shared.process.isRunning{
			
			self.timerProgressIncrement()
			
		}else{
			CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
			self.timer.invalidate()
		}
		}
	}
	
	//function that checks if the process has finished
	@objc func checkProcessFinished(_ sender: AnyObject){
		DispatchQueue.global(qos: .userInteractive).async {
		self.seconds += 1
		print(String(self.seconds) + " sec")
			
		if CreateinstallmediaSmallManager.shared.process.isRunning{
			
			self.timerProgressIncrement()
			
		}else{
			CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress = false
			self.timer.invalidate()
			self.installFinished()
		}
		}
	}
	
	@inline(__always) private func timerProgressIncrement(){
		if self.seconds % 5 == 0{
			
			let minutes = self.seconds / minutesRatio
			
			if self.seconds % minutesRatio == 0{
				log("Please wait, the process is still going, minutes since process beginning: \(minutes)")
			}
			
			if minutes <= self.processMinutesToChange{
				DispatchQueue.main.sync {
					self.addToProgressValue(self.installerProgressValueFast)
				}
			}else if minutes > self.processMinutesToChange{
				DispatchQueue.main.sync {
					self.addToProgressValue(self.installerProgressValueSlow)
				}
			}
			
		}
	}
	
	#if !macOnlyMode
	
	@objc func checkEFIFolderCopyProcess(_ sender: AnyObject){
		if EFICopyEnded{
			timer.invalidate()
		}
		
		if let p = EFIFolderReplacementManager.shared.copyProcessProgress{
			self.setProgressValue(startProgress + (progressRate * p))
		}
	}
	/*
	@objc func checkBootFilesReplacementProcess(_ sender: AnyObject){
		if EFICopyEnded{
			timer.invalidate()
		}
		
		if let p = BootFilesReplacementManager.shared.replacementProcessProgress{
			self.setProgressValue(startProgress + (progressRate * p))
		}
	}*/
	
	#endif
	
}
