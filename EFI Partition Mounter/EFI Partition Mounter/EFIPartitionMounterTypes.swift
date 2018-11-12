//
//  EFIPartitionMounterTypes.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)
public class EFIPartitionToolTypes{

    public typealias PartitionStandard = (drivePartDisplayName: String, drivePartIcon: NSImage)

    public typealias EFIPartitionStandard = (displayName: String, bsdName: String, isRemovable: Bool, isMounted: Bool, hasConfig: Bool, completeDrivePartitions: [PartitionStandard])

}
#endif
