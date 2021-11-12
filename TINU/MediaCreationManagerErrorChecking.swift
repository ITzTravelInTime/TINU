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

import Cocoa
import TINURecovery
import Command

extension InstallMediaCreationManager{
	
	private struct CheckItem: Codable, Equatable{
		enum Operations: UInt8, Codable, Equatable{
			case contains = 0
			case equal = 1
			case different = 2
		}
		
		enum CheckValues: UInt8, Codable, Equatable{
			case fe = 0
			case me = 1
			case le = 2
			case lo = 3
			case llo = 4
			case tt = 5
			case rc = 6
			case px = 7
		}
		
		//var valuesToCheck: [String] = []
		var chackValues: [CheckValues] = []
		let stringsToCheck: [String?]
		let printMessage: String
		let message: String
		let notError: Bool
		
		var operation: Operations = .contains
		
		var isBack = false
	}
	
	private struct CheckItemCollection: CodableDefaults, Codable, Equatable{
		let itemsList: [CheckItem]
		internal static let defaultResourceFileName = "ErrorDecodingMessanges"
		internal static let defaultResourceFileExtension = "json"
	}
	
	func installFinished(){
		
		//now the installer creation process has finished running, so our boolean must be false now
		self.ref!.pointee.process.status = .postCreation
		
		DispatchQueue.global(qos: .background).async {
			
			DispatchQueue.main.async {
				
				//self.setActivityLabelText("Interpreting the results of the process")
				
				self.setActivityLabelText("activityLabel3")
				self.setProgressBarIndeterminateState(state: false)
				
			}
			
			log("process took \(UInt64(abs(self.ref!.pointee.process.startTime.timeIntervalSinceNow))) seconds to finish")
			
			//if there is a not normal code it will be logged
			log("\"\(self.ref!.pointee.actualExecutableName)\" has finished, extracting output ...")
			
			let result = self.ref!.pointee.process.handle.result()
			
			log("Output extracted: ")
			
			//logs the output of the process
			for o in result?.output ?? []{
				log("      " + o)
			}
					
			log("process error/s produced: ")
			//logs the errors produced by the process
			for o in result?.error ?? []{
				log("      " + o)
			}
			
			DispatchQueue.main.sync {
				//we have finished, so the controls opf the window are restored
				if let w = UIManager.shared.window{
					w.isMiniaturizeEnaled = true
					w.isClosingEnabled = true
					//w.canHide = true
				}
			}
			
			self.analizeError(result)
			
		}
	}
	
	
	
	private func analizeError(_ res: Command.Result?){
		
		DispatchQueue.main.sync {
			//self.setActivityLabelText("Checking previous operations")
			self.setActivityLabelText("activityLabel4")
		}
		
		log("Checking the \(self.ref!.pointee.actualExecutableName) process")
		
		guard let result = res else {
			DispatchQueue.main.sync {
				//self.viewController.goToFinalScreen(title: "macOS installation error: check the log for details", success: false)
				self.viewController.goToFinalScreen(id: "finalScreenFLE")
				
			}
			return
		}
		
		//gets the termination status for comparison
		let rc = simulateAbnormalExitcode ? 1 : result.exitCode
		
		if self.ref!.pointee.installMac{
			//probably this will end up never executing
			DispatchQueue.main.sync {
				//102030100
				if (rc == 0){
					//self.viewController.goToFinalScreen(title: "macOS installed successfully", success: true)
					self.viewController.goToFinalScreen(id: "finalScreenMIS", success: true)
				}else{
					//self.viewController.goToFinalScreen(title: "macOS installation error: check the log for details", success: false)
					self.viewController.goToFinalScreen(id: "finalScreenMIE")
				}
				
			}
			
			return
		}
		
		DispatchQueue.global(qos: .background).async {
			
			var px = 0, fe: String!, me: String!, le: String!, lo: String!, llo: String!, tt: String!
			
			if !simulateCreateinstallmediaFailCustomMessage.isEmpty && simulateAbnormalExitcode{
				tt = simulateCreateinstallmediaFailCustomMessage
			}
			
			fe = result.error.first
			if result.error.indices.contains(1){
				me = result.error[1]
			}else{
				me = nil
			}
			le = result.error.last
			
			
			//fo = self.output.first
			lo = result.output.last
			
			llo = result.output.last?.lowercased()
			
			var mol = 1
			var opened = false
			
			if !(le ?? "osascript").contains("osascript"){
				for c in le.reversed(){
					if c == ")"{
						px = 0
						mol = 1
						opened = true
						continue
					}
					
					if let n = Int(String(c)), opened{
						px += n * mol;
						mol *= 10
						continue
					}
					
					if c == "("{
						opened = false
						break
					}
				}
			}
			
			
			let success = ((rc == 0) && (px == 0)) || (CurrentUser.isRoot && (px == 102030100) && (rc == 0)) //add rc to the root case
			
			log("Current user:                           \(CurrentUser.name)")
			log("Main process exit code:                 \(px)")
			log("Sub process exit code produced:         \(rc)")
			log("Probable process outcome:               \(success ? "Positive" : "Negative")")
			
			let errorsList: [CheckItem] =  CodableCreation<CheckItemCollection>.createFromDefaultFile()!.itemsList
			
			var valueList: [CheckItem.CheckValues: String?] = [:]
			
			valueList[.px] = "\(px)"
			valueList[.rc] = "\(rc)"
			valueList[.fe] = fe
			valueList[.me] = me
			valueList[.le] = le
			valueList[.lo] = lo
			valueList[.llo] = llo
			valueList[.tt] = tt
			
			//sanity check print just so see how the json should look like
			//print(CodableCreation<CheckItemCollection>.getEncoded(CheckItemCollection(itemsList: errorsList))!)
			
			//checks the conditions of the errorlist array to see if the operation has been complited with success
			print("Checking errors: ")
			
			for item in errorsList{
				
				var values: [String?] = []
				
				for nvalue in item.chackValues{
					
					if let value = valueList[nvalue] {
						values.append(value)
					}
					
				}
				
				print("    Strings to check: \(item.stringsToCheck)")
				print("    Strings to check against: \"\(values)\"")
				print("    Operation to perform: \(item.operation)")
				
				if !self.checkMatch(values, item.stringsToCheck, operation: item.operation){
					continue
				}
				
				print("    Check sucess")
				
				log("\n\(self.parse(messange: item.printMessage))\n")
				
				self.performPostProcess(item)
				
				break
			}
			
		}
		
	}
	
	private func performPostProcess( _ item: CheckItem){
		
		if !item.notError{
			if item.isBack{
				DispatchQueue.main.sync {
					self.viewController.goBack()
				}
			}else{
				DispatchQueue.main.sync {
					self.viewController.goToFinalScreen(title: self.parse(messange: item.message), success: item.notError)
				}
			}
			return
		}
		
		//here createinstallmedia succedes in creating the installer
		log("\(self.ref!.pointee.actualExecutableName) process ended with success")
		
		DispatchQueue.global(qos: .background).async {
			
			Diskutil.Info.resetCache()
			
			guard let res = self.manageSpecialOperations() else {
				//operation canceled by the user
				DispatchQueue.main.sync {
					self.viewController.goBack()
				}
				return
			}
			
			if !res{
				log("Options application failed")
				
				DispatchQueue.main.sync {
					//self.viewController.goToFinalScreen(title: "Error: Failed to apply advanced options", success: false)
					self.viewController.goToFinalScreen(id: "finalScreenAOE")
				}
				
				return
			}
			
			if item.isBack{
				DispatchQueue.main.sync {
					self.viewController.goBack()
				}
			}else{
				log("Bootable macOS installer created successfully!")
				DispatchQueue.main.sync {
					self.viewController.goToFinalScreen(title: self.parse(messange: item.message), success: item.notError)
				}
			}
			
		}
	}
	
	private func checkMatch(_ stringsToCheck: [String?], _ valuesToCheck: [String?], operation: CheckItem.Operations) -> Bool{
		stringsfor: for ss in stringsToCheck{
			guard let s = ss else {
				continue stringsfor
			}
			
			if s == "" || s == " "{
				continue stringsfor
			}
			
			valuefor: for ovalueToCheck in valuesToCheck{
				
				guard let valueToCheck = ovalueToCheck else {
					continue valuefor
				}
				
				if valueToCheck == "" || valueToCheck == " "{
					continue valuefor
				}
				
				switch operation{
				case .contains:
					if s.contains(valueToCheck){
						return true
					}
					break
				case .different:
					
					if s != valueToCheck{
						return true
					}
					break
				case .equal:
					
					if s == valueToCheck{
						return true
					}
					break
				}
				
			}
		}
		
		return false
	}
	
	private func parse(messange: String) -> String{
		return TINU.parse(messange: messange, keys: ["{executable}": self.ref!.pointee.actualExecutableName, "{drive}": self.ref!.pointee.disk.current.driveName])
	}
	
}
