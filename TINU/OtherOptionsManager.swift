//
//  OtherOptionsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class OtherOptionsManager{
	public enum OtherOptionID: UInt8, CaseIterable {
		case unknown = 0
		
		case otherOptionTinuCopyID      =  1
		case otherOptionCreateReadmeID
		case otherOptionCreateIconID
		case otherOptionForceToFormatID
		case otherOptionDoNotUseApfsID
		
		#if !macOnlyMode
		case otherOptionCreateAIBootFID
		case otherOptionDeleteIAPMID
		case otherOptionAddBFRScriptID
		#endif
		
		#if useEFIReplacement && !macOnlyMode
		case otherOptionKeepEFIpartID
		#endif
	}
	
	typealias OtherOptionString = (title: String, desc: String)
	typealias OtherOptionsStringList = [OtherOptionID: OtherOptionString]
	
	public typealias OtherOptionsList = [OtherOptionID: OtherOptionsObject]
	
	typealias OtherOptionRaps = (objects: OtherOptionsStringList, tmpDict: OtherOptionsList)
	
	
	static let shared = OtherOptionsManager()
	
	public var otherOptions: OtherOptionsList = [:]
	
	public func restoreOtherOptions(){
		log("Trying to restore the other options to the default values")
		otherOptions.removeAll()
		otherOptions = otherOptionsDefault
		
		log("Other options restored to the original values")
	}
	
	@inline(__always) private func addOtheroOption(_ r: inout OtherOptionRaps, id: OtherOptionID, activated: Bool, visible: Bool, isAdvanced: Bool){
		if let t = r.objects[id]{
			r.tmpDict[id] = OtherOptionsObject.init(id: id, title: t.title, isActivated: activated, isVisible: visible, isUsable: visible, isAdvanced: isAdvanced, description: t.desc)
		}
	}
	
	@inline(__always) private func getCorrectedDescription(title: String, normal: String, altered: String) -> OtherOptionString{
		return (title: title, desc: sharedInstallMac ? altered : normal)
	}
	
	private var otherOptionsDefault: OtherOptionsList {
		get{
			
			var r: OtherOptionRaps
			
			r.objects = getStrings()
			r.tmpDict = [:]
			
			addOtheroOption(&r, id: OtherOptionID.otherOptionTinuCopyID, activated: true, visible: true, isAdvanced: false)
			addOtheroOption(&r, id: OtherOptionID.otherOptionCreateIconID, activated: true, visible: true, isAdvanced: false)
			addOtheroOption(&r, id: OtherOptionID.otherOptionCreateReadmeID, activated: true, visible: true, isAdvanced: false)
			addOtheroOption(&r, id: OtherOptionID.otherOptionForceToFormatID, activated: false, visible: true, isAdvanced: true)
			
			addOtheroOption(&r, id: OtherOptionID.otherOptionDoNotUseApfsID, activated: true, visible: true, isAdvanced: true)
			
			#if !macOnlyMode
				
			addOtheroOption(&r, id: OtherOptionID.otherOptionCreateAIBootFID, activated: false, visible: true, isAdvanced: true)
			addOtheroOption(&r, id: OtherOptionID.otherOptionDeleteIAPMID, activated: false, visible: true, isAdvanced: true)
				
			#endif
			
			
			#if useEFIReplacement && !macOnlyMode
			
			addOtheroOption(&r, id: OtherOptionID.otherOptionKeepEFIpartID, activated: false, visible: true, isAdvanced: true)
			
			#endif
			
			return r.tmpDict
			
		}
	}
	
	fileprivate func getStrings() -> OtherOptionsStringList{
		
		var list = OtherOptionsStringList()
		
		list[OtherOptionID.otherOptionTinuCopyID] = getCorrectedDescription(
			title: "Create a copy of TINU on the USB installer",
			normal: "Creates a copy of this application inside the choosen drive.\nOnce you boot into the USB installer you can open TINU by performing this command into the terminal:\n\n/Volumes/Image\\ Volume/TINU.app/Contents/MacOS/TINU\n\nUsing TINU in this way it allows you to create bootable macOS installers from a macOS installer/recovery or allows you to install macOS from TINU.\n\nWorks only with Mac OS X El Capitan or newer versions of the macOS installer/macOS recovery",
			altered: "Installs a copy of TINU in the /Applications folder of the newly installed macOS system.\n\nRequires Mac OS X El Capitan or newer versions of macOS"
		)
		
		list[OtherOptionID.otherOptionForceToFormatID] = getCorrectedDescription(
			title: sharedInstallMac ? "Format the choosen drive entirely" : "Format the entire USB drive",
			normal: "Erases all the contentent of the choosen storage device, and then formats it using a macOS Extended Journaled (HFS+) main partition with the GUID partition table for the drive.\nThis operation is mandatory (and it will be performed automatically) if the choosen drive does not use GUID, because GUID is needed to allow the macOS installer to boot.",
			altered: "Erases all the contentent of the target drive, and then formats it using a macOS Extended Journaled (HFS+) main partition with the GUID partition table for the drive (note that the macOS installer may convert it in APFS if the option to avoid the APFS conversion operation, is not enabled, or if you use Mojave or a newer macOS version).\nThis operation is mandatory (and it will be performed automatically) if the choosen drive does not use GUID, because GUID is needed to install macOS and to make it work properly."
		)
		
		#if useEFIReplacement && !macOnlyMode
		list[OtherOptionID.otherOptionKeepEFIpartID] = getCorrectedDescription(
			title: "Don't unmount the EFI partition",
			normal: "While creating the bootable macOS installer, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes creating the bootable installer.",
			altered: "While installing macOS on the target drive, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes to install macOS on the target drive."
		)
		#endif
		
		//descriptions for objects with only ust one
		
		list[OtherOptionID.otherOptionCreateIconID] = (title: "Apply the macOS installer's icon to the usb drive", desc: "Applys the macOS icon from the macOS installer app to the target drive.")
		list[OtherOptionID.otherOptionCreateReadmeID] = (title: "Create the \"README\" file on the usb installer", desc: "Creates a README file on the target drive. The content of this file is just a thank you messange and a reminder for some users.")
		
		if sharedInstallMac{
			
			list[OtherOptionID.otherOptionDoNotUseApfsID] = (title: "Install macOS avoiding automatic APFS upgrade", desc: "Forces the macOS installer to not convert the target volume to the APFS file system (Available only with macOS High Sierra).")
			
		}else{
			#if !macOnlyMode
			list[OtherOptionID.otherOptionCreateAIBootFID] = (title: "Create the .AIBootFiles folder, if it's not present", desc: "For hackintosh usage, older version of Clover may not recognize the bootable macOS installer without the .IABootFiles folder, so this option copies the system files from the bootable installer and then puts them in the newly created .IABootfiles folder.")
			
			list[OtherOptionID.otherOptionDeleteIAPMID] = (title: "Delete the .IAPhisicalMedia file from the installer", desc: "For hackintosh usage, some older version of Clover may not detect bootable macOS installers which contain the .IAPhysicalMedia file, so to let that versions of Clover to detect those isntallers, this option deletes the .IAPhysicalMedia file.")
			#endif
		}
		
		return list
	}
	
}

typealias oom = OtherOptionsManager
