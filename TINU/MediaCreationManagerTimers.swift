/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Foundation
import Cocoa
import Command

extension InstallMediaCreationManager{
	
	//function that checks if the process has finished
	@objc func checkProcessFinished(_ sender: AnyObject){
		DispatchQueue.global(qos: .userInteractive).async {
			
			let diff = UInt64(abs(self.ref!.pointee.process.startTime.timeIntervalSinceNow))
			
			print("\(diff) seconds")
			
			if self.ref!.pointee.process.handle.process.isRunning{
				
				self.timerProgressIncrement(diff)
				
			}else{
				//cvm.shared.process.isCreationInProgress = false
				self.ref!.pointee.process.status = .postCreation
				self.timer.invalidate()
				self.installFinished()
			}
		}
	}
	
	@inline(__always) private func timerProgressIncrement(_ secs: UInt64){
		
		let minutes: UInt64 = secs / 60
		
		let diffm = UInt64(abs(Int32(minutes - self.lastMinute)))
		if (diffm >= 1){
			self.lastMinute = minutes
			for i in 1...diffm{
				log("Please wait, the process is still going, minutes since process beginning: \(minutes - i + 1)")
			}
		}
		
		let diffs = (secs >= self.lastSecs) ? (secs - self.lastSecs) : (self.lastSecs - secs)
		
		if diffs < 5{
			return
		}
		
		self.lastSecs = secs
		
		DispatchQueue.main.sync {
			
			var val = self.getProgressBarValue()
			let max = Double(IMCM.cpc.pMidDuration + IMCM.cpc.pExtDuration)
			
			if val >= max{
				if !getProgressBarIndeterminateState(){
					setProgressBarIndeterminateState(state: true)
				}
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
