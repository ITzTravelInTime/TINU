//
//  OtherOptionsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class OtherOptionsManager{
	//those variables manages the other options system
	
	public struct OtherOptionIDs{
		public let otherOptionTinuCopyID      =  "0_TINUCopy__________"
		public let otherOptionCreateReadmeID  =  "1_CreateReadme______"
		public let otherOptionCreateIconID    =  "2_CreateIcon________"
		public let otherOptionForceToFormatID =  "3_ForceToFormat_____"
		public let otherOptionDoNotUseApfsID  =  "4_DoNotUseAPFS______"
		
		#if !macOnlyMode
		public let otherOptionCreateAIBootFID =  "5_CreateAIBootFiles_"
		public let otherOptionDeleteIAPMID    =  "6_DeleteIAPM________"
		public let otherOptionAddBFRScriptID  =  "7_AddBFRScript______"
		#endif
		
		#if useEFIReplacement && !macOnlyMode
		public let otherOptionKeepEFIpartID   =  "8_KeepEFIMounted____"
		#endif
	}
	
	public let ids: OtherOptionIDs = OtherOptionIDs.init()
	
	static let shared = OtherOptionsManager()
	
	public var otherOptions: [String: OtherOptionsObject] = [:]
	
	@inline(__always)private func addOtheroOption(descList: [String:
		String], titleList: [String: String], id: String, activated: Bool, visible: Bool){
		if let t = titleList[id]{
			tmpDict[id] = OtherOptionsObject.init(objectID: id, objectMessage: t, objectDescription: descList[id], objectIsActivated: activated, objectIsVisible: visible)
		}
	}
	
	@inline(__always) public func getCorrectedDescription(normal: String, altered: String, conditionOfAltering: Bool) -> String{
		if conditionOfAltering{
			return altered
		}else{
			return normal
		}
	}
	
	private var tmpDict: [String: OtherOptionsObject]!
	
	private var otherOptionsDefault: [String: OtherOptionsObject] {
		get{
			let d: [String: String] = getDescList()
			
			let t: [String: String] = getTitleList()
			
			tmpDict = [:]
			
			addOtheroOption(descList: d, titleList: t, id: ids.otherOptionTinuCopyID, activated: true, visible: true)
			addOtheroOption(descList: d, titleList: t, id: ids.otherOptionCreateIconID, activated: true, visible: true)
			addOtheroOption(descList: d, titleList: t, id: ids.otherOptionCreateReadmeID, activated: true, visible: true)
			addOtheroOption(descList: d, titleList: t, id: ids.otherOptionForceToFormatID, activated: false, visible: true)
			
			if sharedInstallMac{
				addOtheroOption(descList: d, titleList: t, id: ids.otherOptionDoNotUseApfsID, activated: true, visible: true)
			}else{
				#if !macOnlyMode
				
				addOtheroOption(descList: d, titleList: t, id: ids.otherOptionCreateAIBootFID, activated: false, visible: true)
				addOtheroOption(descList: d, titleList: t, id: ids.otherOptionDeleteIAPMID, activated: false, visible: true)
				
				#endif
			}
			
			#if useEFIReplacement && !macOnlyMode
			addOtheroOption(descList: d, titleList: t, id: ids.otherOptionKeepEFIpartID, activated: false, visible: true)
			#endif
			
			print(tmpDict)
			
			let dict = tmpDict!
			
			tmpDict.removeAll()
			
			tmpDict = nil
			
			return dict
			
		}
	}
	
	public func restoreOtherOptions(){
		log("Trying to restore the other options to the default values")
		otherOptions.removeAll()
		otherOptions = otherOptionsDefault
		
		log("Other options restored to the original values")
	}
	
	fileprivate func getDescList() -> [String: String]{
		let c = sharedInstallMac
		
		var list = [String: String]()
		
		list[ids.otherOptionTinuCopyID]   = getCorrectedDescription(
			normal: "Creates a copy of this application inside target drive choosen.\nOnce you boot into the USB installer you can open TINU by performing this command into the terminal:\n\n/Volumes/Image\\ Volume/TINU.app/Contents/MacOS/TINU\n\nUsing TINU in this way it allows you to create bootable macOS installers from a macOS installer/recovery or allows you to install macOS from TINU.\n\nWorks only with Mac OS X El Capitan or newer versions of the macOS installer/macOS recovery",
			altered: "Installs a copy of TINU in the /Applications folder of the newly installed macOS system.\n\nRequires Mac OS X El Capitan or newer versions of macOS",
			conditionOfAltering: c)
		
		list[ids.otherOptionCreateIconID] = "Applys the macOS icon from the macOS installer app to the target drive."
		list[ids.otherOptionCreateReadmeID] = "Creates a README file on the target drive. The content of this file is just a thank you messange a reminder for some users."
		list[ids.otherOptionForceToFormatID] = getCorrectedDescription(
			normal: "Erases all the contentent of the target drive, and then formats it using a macOS Extended Journaled (HFS+) main partition with the GUID partition table for the drive.\nNormally, only the chosen partition is formatted, but if the target drive does not use the GUID partition table, this operation is performed anyway.",
			altered: "Erases all the contentent of the target drive, and then formats it using a macOS Extended Journaled (HFS+) main partition with the GUID partition table for the drive (note that the macOS installer may convert it in APFS if the option to avoid the APFS conversion operation, is not enabled, or if you use Mojave or a newer macOS version).\nNormally, if the target drive does not use the GUID partition table or does not use the APFS or macOS extended journaled (HFS+) file systems, this operation is performed anyway.",
			conditionOfAltering: c)
		
		if sharedInstallMac{
			
			list[ids.otherOptionDoNotUseApfsID] = "Forces the macOS installer to not convert the target volume to the APFS file system (Available only with macOS High Sierra)."
			
		}else{
			#if !macOnlyMode
			list[ids.otherOptionCreateAIBootFID] = "For hackintosh usage, older version of Clover may not recognize the bootable macOS installer without the .IABootFiles folder, so this option copies the system files from the bootable installer and then puts them in the newly created .IABootfiles folder."
			
			list[ids.otherOptionDeleteIAPMID] = "For hackintosh usage, some older version of Clover may not detect bootale macOS installers which contain the .IAPhysicalMedia file, so to let that versions of Clover to detect those isntallers, this option deletes the .IAPhysicalMedia file."
			#endif
		}
		
		#if useEFIReplacement && !macOnlyMode
		list[ids.otherOptionKeepEFIpartID] = getCorrectedDescription(
			normal: "While creating the bootable macOS installer, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes creating the bootable installer.",
			altered: "While installing macOS on the target drive, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes to install macOS on the target drive.",
			conditionOfAltering: c)
		#endif
		
		return list
	}
	
	fileprivate func getTitleList() -> [String: String]{
		var list = [String: String]()
		
		list[ids.otherOptionTinuCopyID] = "Create a copy of TINU on the target drive"
		
		list[ids.otherOptionCreateIconID] = "Apply the icon of the installer to the target drive"
		
		list[ids.otherOptionCreateReadmeID] = "Create the \"README\" file on the target drive"
		
		list[ids.otherOptionForceToFormatID] = "Force format the entire target drive"
		
		if sharedInstallMac{
			list[ids.otherOptionDoNotUseApfsID] = "Install macOS avoiding automatic APFS upgrade"
		}else{
			#if !macOnlyMode
			
			list[ids.otherOptionCreateAIBootFID] = "Create the .AIBootFiles folder, if it's not present"
			
			list[ids.otherOptionDeleteIAPMID] = "Delete the .IAPhisicalMedia file"
			
			#endif
		}
		
		#if useEFIReplacement && !macOnlyMode
		
		list[ids.otherOptionKeepEFIpartID] = "Don't unmount the EFI partition of the target drive"
		
		#endif
		
		return list
	}
	
}

typealias oom = OtherOptionsManager
