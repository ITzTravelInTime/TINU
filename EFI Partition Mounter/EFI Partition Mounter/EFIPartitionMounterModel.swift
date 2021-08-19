//
//  EFIPartitionMounterModel.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import AppKit
import Command

#if (!macOnlyMode && TINU) || (!TINU && isTool)

public final class EFIPartitionMounterModel{
	static let shared = EFIPartitionMounterModel()
	
	/*
	private struct VirtualDisk: Equatable{
	
	}*/
	
	//new efi partition mounter system draft
	public func getEFIPartitionsAndSubprtitionsNew() -> [EFIPartitionToolTypes.EFIPartitionStandard]? {
		
		var result: [BSDID: EFIPartitionToolTypes.EFIPartitionStandard]! = nil
		
		guard let diskutilData = Diskutil.List() else {
			print("No diskutil data!")
			return nil
		}
		
		print("Looking for drives with EFI partitions")
		
		for disk in diskutilData.allDisksAndPartitions{
			
			if disk.APFSVolumes	!= nil{
				continue
			}
			
			print("  Scanning disk \(disk.DeviceIdentifier)")
			
			if !disk.hasEFIPartition() {
				print("  Disk doesn't have an EFI partition")
				continue
			}
			
			print("  Disk has EFI partition")
			
			guard let name = disk.DeviceIdentifier.driveName() else { continue }
			
			print("  Disk is named: \(name)")
			
			var res = EFIPartitionToolTypes.EFIPartitionStandard()
			
			res.displayName = name
			
			guard let removable: Bool = disk.DeviceIdentifier.isRemovable() else { continue }
			
			print("  Disk is " + (removable ? "removable" : "unremovable"))
			
			res.isRemovable = removable
			
			for partition in disk.Partitions ?? []{
				
				print("    Scanning disk's partition: \(partition.DeviceIdentifier)")
				
				if partition.content == .eFI {
					print("    Partition is an EFI partition, getting info for disk and continuing")
					res.isMounted = partition.isMounted()
					res.bsdName = partition.DeviceIdentifier
					res.configType = res.isMounted ? EFIPartitionToolTypes.ConfigLocations.init(partition.mountPoint!) : nil
					continue
				}
				
				var part = EFIPartitionToolTypes.PartitionStandard()
				
				if !partition.isVolume(){ continue }
				
				part.drivePartDisplayName = partition.VolumeName!
				print("    Partition display name is: \(part.drivePartDisplayName)")
				
				if !partition.isMounted(){ continue }
				
				print("    Partition is mounted, getting the correct icon")
				
				part.drivePartIcon = IconsManager.shared.getCorrectDiskIcon(partition.DeviceIdentifier)//NSWorkspace.shared.icon(forFile: partition.MountPoint!)
				
				print("    Got partition icon")
				
				res.completeDrivePartitions.append(part)
			}
			
			if result == nil{
				result = [:]
			}
			
			result[disk.DeviceIdentifier] = res
		}
		
		for disk in diskutilData.allDisksAndPartitions{
			
			if disk.APFSVolumes	== nil{
				continue
			}
			
			guard let store = disk.APFSPhysicalStores?.first?.DeviceIdentifier.driveID else { continue }
			if result[store] == nil{ continue }
			
			for apfsVolume in disk.APFSVolumes ?? []{
				
				if apfsVolume.OSInternal ?? false{
					continue
				}
				
				var part = EFIPartitionToolTypes.PartitionStandard()
				
				if !apfsVolume.isVolume(){ continue }
				
				part.drivePartDisplayName = apfsVolume.VolumeName!
				
				if !apfsVolume.isMounted(){ continue }
				
				if apfsVolume.mountPoint?.starts(with: "/System") ?? false { continue }
				
				part.drivePartIcon = IconsManager.shared.getCorrectDiskIcon(apfsVolume.DeviceIdentifier)
				
				result[store]?.completeDrivePartitions.append(part)
			}
		}
		
		if result == nil{
			return nil
		}
		
		var ret: [EFIPartitionToolTypes.EFIPartitionStandard] = []
		
		for r in result{
			ret.append(r.value)
		}
		
		return ret.sorted(by: { $0.bsdName.driveNumber ?? 0 < $1.bsdName.driveNumber ?? 0 })
	}
	
}

#endif
