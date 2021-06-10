//
//  OtherOptionsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public class OtherOptionsManager{
	
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
	
	public typealias OtherOptionsStringList = [OtherOptionID: OtherOptionString]
	
	public typealias OtherOptionsList = [OtherOptionID: OtherOptionsObject]
	
	typealias OtherOptionRaps = (objects: OtherOptionsStringList, tmpDict: OtherOptionsList)
	
	let ref: CreationVariablesManager
	
	init(_ reference: CreationVariablesManager) {
		ref = reference
	}
	
	public var list: OtherOptionsList = [:]
	
	public func restoreOtherOptions(){
		log("Trying to restore the other options to the default values")
		list.removeAll()
		list = otherOptionsDefault
		
		log("Other options restored to the original values")
	}
	
	@inline(__always) private func addOtheroOption(_ r: inout OtherOptionRaps, id: OtherOptionID, activated: Bool, visible: Bool, isAdvanced: Bool){
		if let t = r.objects[id]{
			r.tmpDict[id] = OtherOptionsObject.init(id: id, title: t.title, isActivated: activated, isVisible: visible, isUsable: visible, isAdvanced: isAdvanced, description: t.desc)
		}
	}
	
	private var otherOptionsDefault: OtherOptionsList {
		get{
			
			var r: OtherOptionRaps
			
			r.objects = TextManager!.optionsDescpriptions! //= getStrings()
			r.tmpDict = [:]
			
			addOtheroOption(&r, id: .otherOptionTinuCopyID, activated: true, visible: true, isAdvanced: false)
			addOtheroOption(&r, id: .otherOptionCreateIconID, activated: true, visible: true, isAdvanced: false)
			addOtheroOption(&r, id: .otherOptionCreateReadmeID, activated: true, visible: true, isAdvanced: false)
			
			
			
			addOtheroOption(&r, id: .otherOptionForceToFormatID, activated: false, visible: true, isAdvanced: true)
			addOtheroOption(&r, id: .otherOptionDoNotUseApfsID, activated: true, visible: true, isAdvanced: true)
			
			#if !macOnlyMode
				
			addOtheroOption(&r, id: .otherOptionCreateAIBootFID, activated: false, visible: true, isAdvanced: true)
			addOtheroOption(&r, id: .otherOptionDeleteIAPMID, activated: false, visible: true, isAdvanced: true)
				
			#endif
			
			#if useEFIReplacement && !macOnlyMode
			
			addOtheroOption(&r, id: .otherOptionKeepEFIpartID, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			return r.tmpDict
			
		}
	}
	
	//checks for the options
	public func checkOtherOptions(){
		DispatchQueue.global(qos: .background).async{
			self.restoreOtherOptions()
			
			#if !macOnlyMode
			//BootFilesReplacementManager.shared.eraseReplacementFilesData()
			
			#if useEFIReplacement
			let _ = EFIFolderReplacementManager.shared.unloadEFIFolder()
			#endif
			
			#endif
			
			processLicense = ""
			
			if var item = self.list[.otherOptionForceToFormatID]{
				
				if let st = self.ref.sharedVolumeNeedsPartitionMethodChange{
					item.isUsable = !st
					item.isActivated = st
				}
				
				self.list[.otherOptionForceToFormatID] = item
			}
			
			if self.ref.sharedApp != nil{
				
				var supportsTINU = false
				
				if let st = self.ref.app.sharedAppNotSupportsTINU(){
					supportsTINU = st
				}
				
				if var item = self.ref.options.list[.otherOptionTinuCopyID]{
					item.isUsable = !supportsTINU
					item.isActivated = !supportsTINU
					self.list[.otherOptionTinuCopyID] = item
				}
				
				if sharedInstallMac{
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
						item.isActivated = !self.ref.sharedSVReallyIsAPFS
						item.isUsable = !self.ref.sharedSVReallyIsAPFS
						
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
