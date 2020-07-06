//
//  EFIPartitionMounterTypes.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)
public final class EFIPartitionToolTypes{

	public struct PartitionStandard {var drivePartDisplayName: String = ""; var drivePartIcon: NSImage = NSImage()}

	public struct EFIPartitionStandard {var displayName: String = ""; var bsdName: String = ""; var isRemovable: Bool = false; var isMounted: Bool = false; var hasConfig: Bool = false; var completeDrivePartitions: [PartitionStandard] = []}
	
	public struct VolumeStandard {var id: String = ""; var isEFI: Bool = false}
	
	static public let cloverConfigLocation = "/EFI/CLOVER/config.plist"
	static public let openCoreConfigLocation = "/EFI/OC/config.plist"
}



#endif
