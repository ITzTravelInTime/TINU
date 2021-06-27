//
//  MediaCreationManagerTimers.swift
//  TINU
//
//  Created by Pietro Caruso on 08/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

extension InstallMediaCreationManager{
	
	//function that checks if the process has finished
	@objc func checkProcessFinished(_ sender: AnyObject){
		DispatchQueue.global(qos: .userInteractive).async {
			
			let diff = UInt64(abs(cvm.shared.process.startTime.timeIntervalSinceNow))
			
			print("\(diff) seconds")
			
			if cvm.shared.process.handle.process.isRunning{
				
				self.timerProgressIncrement(diff)
				
			}else{
				//cvm.shared.process.isCreationInProgress = false
				cvm.shared.process.status = .postCreation
				self.timer.invalidate()
				self.installFinished()
			}
		}
	}
	
	@inline(__always) private func timerProgressIncrement(_ secs: UInt64){
		
		let minutes: UInt64 = secs / 60
		
		let diffm = UInt64(abs(Int32(minutes - self.lastMinute)))
		if (diffm > 0){
			self.lastMinute = minutes
			for i in diffm...1{
				log("Please wait, the process is still going, minutes since process beginning: \(minutes - i + 1)")
			}
		}
		
		let diffs = (secs - self.lastSecs)
		
		if diffs < 5{
			return
		}
		
		self.lastSecs = secs
		
		DispatchQueue.main.sync {
			
			var val = self.getProgressBarValue()
			let max = Double(IMCM.cpc.pMidDuration + IMCM.cpc.pExtDuration)
			
			if val >= max{
				return
			}
			
			for _ in 1...(diffs / 5){
				
				val = self.getProgressBarValue()
				
				if val >= max{
					continue
				}
				
				if minutes <= self.processMinutesToChange{
					self.addToProgressValue(self.installerProgressValueFast)
				}else if minutes > self.processMinutesToChange{
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
	func checkBootFilesReplacementProcess(_ sender: AnyObject){
		if EFICopyEnded{
			timer.invalidate()
		}
		
		if let p = BootFilesReplacementManager.shared.replacementProcessProgress{
			self.setProgressValue(startProgress + (progressRate * p))
		}
	}*/
	
	#endif
	
}
