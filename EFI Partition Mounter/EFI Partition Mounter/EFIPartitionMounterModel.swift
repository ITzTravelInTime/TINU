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
		
		for disk in diskutilData.allDisksAndPartitions where disk.APFSVolumes == nil{
			
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
		
		if result == nil{
			return nil
		}
		
		for disk in diskutilData.allDisksAndPartitions where disk.APFSVolumes != nil{
			
			guard let store = disk.APFSPhysicalStores?.first?.DeviceIdentifier.driveID else { continue }
			if result[store] == nil{ continue }
			
			for apfsVolume in disk.APFSVolumes ?? [] where !(apfsVolume.OSInternal ?? false){
				
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
