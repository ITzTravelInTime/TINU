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


public var filesToReplace: [ReplaceFileObject] = [
    ReplaceFileObject.init(name: "kernelcache", possiblePaths: kernelCachePaths, contentData: nil),
    ReplaceFileObject.init(name: "prelinkedkernel", possiblePaths: prelinkedKernelPaths, contentData: nil),
    ReplaceFileObject.init(name: "boot.efi", possiblePaths: bootEfiPaths, contentData: nil),
    ReplaceFileObject.init(name: "com.apple.Boot.plist", possiblePaths: comAppleBootPlistPaths, contentData: nil),
    ReplaceFileObject.init(name: "PlatformSupport.plist", possiblePaths: platformSupportPlistPaths, contentData: nil),
    ReplaceFileObject.init(name: "SystemVersion.plist", possiblePaths: systemVersionPlistPaths, contentData: nil)
]

//those variables manages the other options system
public let otherOptionTinuCopyID      =  "0_TINUCopy__________"
public let otherOptionCreateReadmeID  =  "1_CreateReadme______"
public let otherOptionCreateIconID    =  "2_CreateIcon________"
public let otherOptionForceToFormatID =  "3_ForceToFormat_____"
public let otherOptionDoNotUseApfsID  =  "4_DoNotUseAPFS______"

fileprivate var otherOptionsDefault: [String: OtherOptionsObject] {
    get{
		var dict: [String: OtherOptionsObject] = [
            otherOptionTinuCopyID: OtherOptionsObject.init(objectID: otherOptionTinuCopyID, objectMessage: "Create a copy of TINU on the target drive", objectIsActivated: true, objectIsVisible: true),
            otherOptionCreateIconID: OtherOptionsObject.init(objectID: otherOptionCreateIconID, objectMessage: "Apply the icon of the installer to the target drive", objectIsActivated: true, objectIsVisible: true),
             otherOptionCreateReadmeID: OtherOptionsObject.init(objectID: otherOptionCreateReadmeID, objectMessage: "Create the \"README\" file on the target drive", objectIsActivated: true, objectIsVisible: true),
             otherOptionForceToFormatID: OtherOptionsObject.init(objectID: otherOptionForceToFormatID, objectMessage: "Force to format the entire target drive before starting")/*,
             otherOptionDoNotUseApfsID: OtherOptionsObject.init(objectID: otherOptionDoNotUseApfsID, objectMessage: "Install macOS avoiding automatic APFS upgrade", objectIsActivated: true, objectIsVisible: false)*/
        ]
		
		
        if sharedInstallMac{
            dict[otherOptionDoNotUseApfsID] = OtherOptionsObject.init(objectID: otherOptionDoNotUseApfsID, objectMessage: "Install macOS avoiding automatic APFS upgrade", objectIsActivated: true, objectIsVisible: true)
        }
        
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


