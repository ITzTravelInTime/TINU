/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

extension CreationProcess{
	public class OptionsManager: CreationProcessSection {
		
		/** Values used to identify options, they are hardcoded to fixed values to prevent problems with reading values from json files*/
		public enum ID: UInt8, Codable, Equatable, CaseIterable {
			case unknown = 0
			
			case tinuCopy = 1
			case createReadme = 2
			case createIcon = 3
			case forceToFormat = 4
			case notUseApfs = 5
			
			//Not usable in mac-only mode
			case createAIBootFiles = 6
			case deleteIAPhysicalMedia = 7
			
			//usable only if efi partition mounting is enabled and if there no mac-only mode active
			case keepEFIMounted = 8
			
		}
		
		public struct Description: Codable, Equatable{
			let title: String
			let desc: String
		}
		
		public typealias DescriptionList = [ID: Description]
		
		public typealias ObjectList = [ID: Object]
		
		typealias OptionCollection = (objects: DescriptionList, tmpDict: ObjectList)
		
		let ref: CreationProcess
		let execution: Execution
		
		required init(reference: CreationProcess) {
			ref = reference
			execution = Execution(reference: reference)
		}
		
		public var list: ObjectList = [:]
		
		private var defaults: ObjectList {
			var r: OptionCollection
			
			r.objects = TextManager!.optionsDescpriptions! //= getStrings()
			r.tmpDict = [:]
			
			addOption(&r, id: .tinuCopy, activated: true, visible: true, isAdvanced: false)
			addOption(&r, id: .createIcon, activated: true, visible: true, isAdvanced: false)
			addOption(&r, id: .createReadme, activated: true, visible: true, isAdvanced: false)
			
			
			
			addOption(&r, id: .forceToFormat, activated: false, visible: true, isAdvanced: true)
			addOption(&r, id: .notUseApfs, activated: true, visible: true, isAdvanced: true)
			
			#if !macOnlyMode
			
			addOption(&r, id: .createAIBootFiles, activated: false, visible: true, isAdvanced: true)
			addOption(&r, id: .deleteIAPhysicalMedia, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			#if useEFIReplacement && !macOnlyMode
			
			addOption(&r, id: .keepEFIMounted, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			return r.tmpDict
		}
		
		public func restoreDefaults(){
			log("Trying to restore the other options to the default values")
			list.removeAll()
			list = defaults
			
			log("Other options restored to the original values")
		}
		
		@inline(__always) private func addOption(_ r: inout OptionCollection, id: ID, activated: Bool, visible: Bool, isAdvanced: Bool){
			if let t = r.objects[id]{
				//r.tmpDict[id] = Object.init(id: id, title: t.title, isActivated: activated, isVisible: visible, isUsable: visible, isAdvanced: isAdvanced, description: t.desc)
				r.tmpDict[id] = Object(id: id, description: t, isActivated: activated, isVisible: visible, isUsable: visible, isAdvanced: isAdvanced)
			}
		}
		
		//checks for the options
		public func check(){
			DispatchQueue.global(qos: .background).async{
				self.restoreDefaults()
				
				#if !macOnlyMode
				//BootFilesReplacementManager.shared.eraseReplacementFilesData()
				
				#if useEFIReplacement
				EFIFolderReplacementManager.shared.unloadEFIFolder()
				#endif
				
				#endif
				
				processLicense = ""
				
				if var item = self.list[.forceToFormat]{
					
					//if let st = self.ref.disk.shouldErase{
					item.isUsable = !self.ref.disk.shouldErase
					item.isActivated = self.ref.disk.shouldErase
					//}
					
					self.list[.forceToFormat] = item
				}
				
				if self.ref.app.path != nil{
					
					var supportsTINU = false
					
					if let st = self.ref.app.info.notSupportsTINU(){
						supportsTINU = st
					}
					
					if var item = self.ref.options.list[.tinuCopy]{
						item.isUsable = !supportsTINU
						item.isActivated = !supportsTINU
						self.list[.tinuCopy] = item
					}
					
					if cvm.shared.installMac{
						var supportsAPFS = false
						
						if let st = self.ref.app.info.notSupportsAPFS(){
							supportsAPFS = st
						}
						
						if let st = self.ref.app.info.isNotMojave(){
							if !st{
								supportsAPFS = true
							}
						}
						
						
						if var item = self.list[.notUseApfs]{
							item.isVisible = !supportsAPFS
							item.isActivated = !self.ref.disk.isAPFS
							item.isUsable = !self.ref.disk.isAPFS
							
							self.list[.notUseApfs] = item
						}
					}else{
						
						#if !macOnlyMode
						
						var needsIA = false
						
						if let na = self.ref.app.info.supportsIAEdit(){
							needsIA = na
						}
						
						if var item = self.list[.createAIBootFiles]{
							item.isActivated = false
							item.isUsable = needsIA
							self.list[.createAIBootFiles] = item
						}
						
						if var item = self.list[.deleteIAPhysicalMedia]{
							item.isActivated = false
							item.isUsable = needsIA
							self.list[.deleteIAPhysicalMedia] = item
						}
						
						#endif
					}
					
				}
				
				
				
				
			}
			
		}
		
	}
	
	//typealias oom = OtherOptionsManager
	
}
