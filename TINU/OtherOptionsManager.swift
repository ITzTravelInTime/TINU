//
//  OtherOptionsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

extension CreationVariablesManager{
	public class OtherOptionsManager: CreationVariablesManagerSection {
		
		/** Values used to identify options, they are hardcoded to fixed values to prevent problems with reading values from json files*/
		public enum OtherOptionID: UInt8, Codable, Equatable, CaseIterable {
			case unknown = 0
			
			case otherOptionTinuCopyID = 1
			case otherOptionCreateReadmeID = 2
			case otherOptionCreateIconID = 3
			case otherOptionForceToFormatID = 4
			case otherOptionDoNotUseApfsID = 5
			
			//Not usable in mac-only mode
			case otherOptionCreateAIBootFID = 6
			case otherOptionDeleteIAPMID = 7
			
			//usable only if efi partition mounting is enabled and if there no mac-only mode active
			case otherOptionKeepEFIpartID = 8
			
		}
		
		public struct OtherOptionString: Codable, Equatable{
			let title: String
			let desc: String
		}
		
		public typealias StringList = [OtherOptionID: OtherOptionString]
		
		public typealias OptionsListType = [OtherOptionID: OtherOptionsObject]
		
		typealias OptionListTypeAssociation = (objects: StringList, tmpDict: OptionsListType)
		
		let ref: CreationVariablesManager
		
		required init(reference: CreationVariablesManager) {
			ref = reference
		}
		
		public var list: OptionsListType = [:]
		
		private var defaults: OptionsListType {
			var r: OptionListTypeAssociation
			
			r.objects = TextManager!.optionsDescpriptions! //= getStrings()
			r.tmpDict = [:]
			
			addOption(&r, id: .otherOptionTinuCopyID, activated: true, visible: true, isAdvanced: false)
			addOption(&r, id: .otherOptionCreateIconID, activated: true, visible: true, isAdvanced: false)
			addOption(&r, id: .otherOptionCreateReadmeID, activated: true, visible: true, isAdvanced: false)
			
			
			
			addOption(&r, id: .otherOptionForceToFormatID, activated: false, visible: true, isAdvanced: true)
			addOption(&r, id: .otherOptionDoNotUseApfsID, activated: true, visible: true, isAdvanced: true)
			
			#if !macOnlyMode
			
			addOption(&r, id: .otherOptionCreateAIBootFID, activated: false, visible: true, isAdvanced: true)
			addOption(&r, id: .otherOptionDeleteIAPMID, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			#if useEFIReplacement && !macOnlyMode
			
			addOption(&r, id: .otherOptionKeepEFIpartID, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			return r.tmpDict
		}
		
		public func restoreDefaults(){
			log("Trying to restore the other options to the default values")
			list.removeAll()
			list = defaults
			
			log("Other options restored to the original values")
		}
		
		@inline(__always) private func addOption(_ r: inout OptionListTypeAssociation, id: OtherOptionID, activated: Bool, visible: Bool, isAdvanced: Bool){
			if let t = r.objects[id]{
				r.tmpDict[id] = OtherOptionsObject.init(id: id, title: t.title, isActivated: activated, isVisible: visible, isUsable: visible, isAdvanced: isAdvanced, description: t.desc)
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
				
				if var item = self.list[.otherOptionForceToFormatID]{
					
					//if let st = self.ref.disk.shouldErase{
					item.isUsable = !self.ref.disk.shouldErase
					item.isActivated = self.ref.disk.shouldErase
					//}
					
					self.list[.otherOptionForceToFormatID] = item
				}
				
				if self.ref.app.path != nil{
					
					var supportsTINU = false
					
					if let st = self.ref.app.sharedAppNotSupportsTINU(){
						supportsTINU = st
					}
					
					if var item = self.ref.options.list[.otherOptionTinuCopyID]{
						item.isUsable = !supportsTINU
						item.isActivated = !supportsTINU
						self.list[.otherOptionTinuCopyID] = item
					}
					
					if cvm.shared.installMac{
						var supportsAPFS = false
						
						if let st = self.ref.app.sharedAppNotSupportsAPFS(){
							supportsAPFS = st
						}
						
						if let st = self.ref.app.sharedAppNotIsMojave(){
							if !st{
								supportsAPFS = true
							}
						}
						
						
						if var item = self.list[.otherOptionDoNotUseApfsID]{
							item.isVisible = !supportsAPFS
							item.isActivated = !self.ref.disk.isAPFS
							item.isUsable = !self.ref.disk.isAPFS
							
							self.list[.otherOptionDoNotUseApfsID] = item
						}
					}else{
						
						#if !macOnlyMode
						
						var needsIA = false
						
						if let na = self.ref.app.sharedAppSupportsIAEdit(){
							needsIA = na
						}
						
						if var item = self.list[.otherOptionCreateAIBootFID]{
							item.isActivated = false
							item.isUsable = needsIA
							self.list[.otherOptionCreateAIBootFID] = item
						}
						
						if var item = self.list[.otherOptionDeleteIAPMID]{
							item.isActivated = false
							item.isUsable = needsIA
							self.list[.otherOptionDeleteIAPMID] = item
						}
						
						#endif
					}
					
				}
				
				
				
				
			}
			
		}
		
	}
	
	//typealias oom = OtherOptionsManager
	
}
