//
//  PostCreationVariables.swift
//  TINU
//
//  Created by ITzTravelInTime on 09/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
//those variables stores the paths in which each boot file can be found
fileprivate let kernelCachePaths: [String] = ["/.IABootFiles", "/System/Library/Caches/com.apple.kext.caches/Startup"]
fileprivate let prelinkedKernelPaths: [String] = ["/.IABootFiles", "/System/Library/PrelinkedKernels", "/System/Library/Caches/com.apple.kext.caches/Startup"]
fileprivate let bootEfiPaths: [String] = ["/.IABootFiles", "/usr/standalone/i386", "/System/Library/CoreServices"]

fileprivate let comAppleBootPlistPaths: [String] = ["/.IABootFiles", /*"/System/Library/CoreServices",*/ "/Library/Preferences/SystemConfiguration"]

fileprivate let platformSupportPlistPaths: [String] = ["/.IABootFiles", "/System/Library/CoreServices"]

fileprivate let systemVersionPlistPaths: [String] = ["/System/Library/CoreServices"]

fileprivate let versionBridgeBinPaths: [String] = ["/.IABootFiles","/System/Library/CoreServices"]

fileprivate let immutablekernelPaths: [String] = ["/.IABootFiles","/System/Library/PrelinkedKernels"]

fileprivate let secureBootBundle: [String] = ["/.IABootFiles", "/usr/standalone/i386"]

public var filesToReplace: [ReplaceFileObject] = [
	
    ReplaceFileObject.init(name: "boot.efi", possiblePaths: bootEfiPaths, contentData: nil),
    ReplaceFileObject.init(name: "BridgeVersion.bin", possiblePaths: versionBridgeBinPaths, contentData: nil),
    ReplaceFileObject.init(name: "com.apple.Boot.plist", possiblePaths: comAppleBootPlistPaths, contentData: nil),
    ReplaceFileObject.init(name: "immutablekernel", possiblePaths: immutablekernelPaths, contentData: nil),
    ReplaceFileObject.init(name: "kernelcache", possiblePaths: kernelCachePaths, contentData: nil),
    ReplaceFileObject.init(name: "PlatformSupport.plist", possiblePaths: platformSupportPlistPaths, contentData: nil),
    ReplaceFileObject.init(name: "prelinkedkernel", possiblePaths: prelinkedKernelPaths, contentData: nil),
    ReplaceFileObject.init(name: "SecureBoot.bundle", possiblePaths: secureBootBundle, contentData: nil),
    ReplaceFileObject.init(name: "SystemVersion.plist", possiblePaths: systemVersionPlistPaths, contentData: nil)
	
]

//those variables manages the other options system
public let otherOptionTinuCopyID      =  "0_TINUCopy__________"
public let otherOptionCreateReadmeID  =  "1_CreateReadme______"
public let otherOptionCreateIconID    =  "2_CreateIcon________"
public let otherOptionForceToFormatID =  "3_ForceToFormat_____"
public let otherOptionDoNotUseApfsID  =  "4_DoNotUseAPFS______"

public let otherOptionCreateAIBootFID =  "5_CreateAIBootFiles_"
public let otherOptionDeleteIAPMID    =  "6_DeleteIAPM________"
public let otherOptionAddBFRScriptID  =  "7_AddBFRScript______"

public let otherOptionKeepEFIpartID   =  "8_KeepEFIMounted____"

//fileprivate var descList = [String: String]()

fileprivate var otherOptionsDefault: [String: OtherOptionsObject] {
    get{
		var d: [String: String] = getDescList()
		
		var dict: [String: OtherOptionsObject] = [
            otherOptionTinuCopyID: OtherOptionsObject.init(objectID: otherOptionTinuCopyID, objectMessage: "Create a copy of TINU on the target drive", objectDescription: d[otherOptionTinuCopyID], objectIsActivated: true, objectIsVisible: true),
            
            otherOptionCreateIconID: OtherOptionsObject.init(objectID: otherOptionCreateIconID, objectMessage: "Apply the icon of the installer to the target drive", objectDescription: d[otherOptionCreateIconID],objectIsActivated: true, objectIsVisible: true),
            
             otherOptionCreateReadmeID: OtherOptionsObject.init(objectID: otherOptionCreateReadmeID, objectMessage: "Create the \"README\" file on the target drive", objectDescription: d[otherOptionCreateReadmeID], objectIsActivated: true, objectIsVisible: true),
             
             otherOptionForceToFormatID: OtherOptionsObject.init(objectID: otherOptionForceToFormatID, objectMessage: "Force format the entire target drive", objectDescription: d[otherOptionForceToFormatID])/*,
             otherOptionDoNotUseApfsID: OtherOptionsObject.init(objectID: otherOptionDoNotUseApfsID, objectMessage: "Install macOS avoiding automatic APFS upgrade", objectIsActivated: true, objectIsVisible: false)*/
        ]
		
        if sharedInstallMac{
            dict[otherOptionDoNotUseApfsID] = OtherOptionsObject.init(objectID: otherOptionDoNotUseApfsID, objectMessage: "Install macOS avoiding automatic APFS upgrade", objectDescription: d[otherOptionDoNotUseApfsID], objectIsActivated: true, objectIsVisible: true)
		}else{
			#if !macOnlyMode
				
			dict[otherOptionCreateAIBootFID] = OtherOptionsObject.init(objectID: otherOptionCreateAIBootFID, objectMessage: "Create the .AIBootFiles folder, if it's not present", objectDescription: d[otherOptionCreateAIBootFID], objectIsActivated: false, objectIsVisible: true)
			
			dict[otherOptionDeleteIAPMID] = OtherOptionsObject.init(objectID: otherOptionDeleteIAPMID, objectMessage: "Delete the .IAPhisicalMedia file", objectDescription: d[otherOptionDeleteIAPMID], objectIsActivated: false, objectIsVisible: true)
			
			#endif
			
			//dict[otherOptionAddBFRScriptID] = OtherOptionsObject.init(objectID: otherOptionAddBFRScriptID, objectMessage: "Add a script to replace boot files in the macOS system", objectIsActivated: true, objectIsVisible: true)
		}
		
		#if useEFIReplacement && !macOnlyMode
			dict[otherOptionKeepEFIpartID] = OtherOptionsObject.init(objectID: otherOptionKeepEFIpartID, objectMessage: "Don't unmount the EFI partition of the target drive", objectDescription: d[otherOptionKeepEFIpartID], objectIsActivated: false, objectIsVisible: true)
		#endif
		
		return dict
        
    }
}

public func restoreOtherOptions(){
    log("Trying to restore the other options to the default values")
    otherOptions.removeAll()
    otherOptions = otherOptionsDefault
	
    log("Other options restored to the original values")
}

public var otherOptions: [String: OtherOptionsObject] = [:]

public func getCorrectedDescription(normal: String, altered: String, conditionOfAltering: Bool) -> String{
	if conditionOfAltering{
		return altered
	}else{
		return normal
	}
}

fileprivate func getDescList() -> [String: String]{
	let c = sharedInstallMac
	
	var list = [String: String]()
	
	list[otherOptionTinuCopyID]   = getCorrectedDescription(normal: "Creates a copy of this application inside target drive choosen.\nOnce you boot into the USB installer you can open TINU by performing this command into the terminal:\n\n/Volumes/Image\\ Volume/TINU.app/Contents/MacOS/TINU\n\nUsing TINU in this way allows you to create bootable macOS installers from a macOS installer or allows you to install macOS from TINU.", altered: "Installs a copy of TINU in the /Applications folder of the newly installed macOS system.", conditionOfAltering: c)
	list[otherOptionCreateIconID] = "Applys the icon of the macOS version of the macOS installer app to the target drive."
	list[otherOptionCreateReadmeID] = "Creates a README file on the target drive. The content of this file is just a thank you messange and in some situations a reminder for the user."
	list[otherOptionForceToFormatID] = getCorrectedDescription(
		normal: "Erases all the contentent of the target drive, and formats it using a main macOS Extended (Journaled) (HFS+) partition with the GUID partition table.\nNormally, only the chosen partition of the target drive is formatted, but if the target drive does not uses the GUID partition table, this operation is performed anyway.",
		altered: "Erases all the contentent of the target drive, and formats it using a main macOS Extended (Journaled) (HFS+) partition with the GUID partition table (note that the macOS installer may convert it in APFS if the option to avoid the APFS conversion operation, is not enabled).\nNormally, if the target drive does not uses the GUID partition table or does not uses APFS or macOS extended (journaled) (HFS+) as file system, this operation is performed anyway.",
		conditionOfAltering: c)
	
	if sharedInstallMac{
		
		list[otherOptionDoNotUseApfsID] = "Forces the macOS installer to not convert the target volume to the APFS file system."
		
	}else{
		#if !macOnlyMode
			list[otherOptionCreateAIBootFID] = "For hackintosh usage, older version of Clover may not recognize the bootable macOS USB installer without the .AIBootFiles folder, so then this option copies the files from the bootable stick and puts them in the .IABootfiles folder, which has just been created, to make the USB installer bootable from older versions of Clover."
			
			list[otherOptionDeleteIAPMID] = "For hackintosh usage, some older version of Clover may not detect USB installers without the .IABootFiles folder and with the .IAPhysicalMedia file, so to let that versions of Clover to detect those isntallers, this option does deletes the .IAPhysicalMedia file from the bootable installer drive."
		#endif
	}
	
	#if useEFIReplacement && !macOnlyMode
		list[otherOptionKeepEFIpartID] = getCorrectedDescription(normal: "While creating the bootable installer, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes creating the bootable installer.", altered: "While installing macOS on the target drive, TINU may mount it's EFI partition, this option prevents TINU from unmounting it after it finishes to install macOS on the target drive.", conditionOfAltering: c)
	#endif
	
	return list
}


