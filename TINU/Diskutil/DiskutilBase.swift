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

import Foundation

public typealias Path = String

public protocol DiskutilDiskPointer: Codable, Equatable{
	var DeviceIdentifier: BSDID {get}
}

public protocol DiskutilObject: DiskutilDiskPointer{
	associatedtype T: RawRepresentable
	//var DeviceIdentifier: BSDID {get}
	var content: T {get}
	var contentString: String? {get}
	var Size: UInt64 {get}
	var mountPoint: Path? {get}
	var OSInternal: Bool? {get}
	func isMounted() -> Bool
	func isVolume() -> Bool
}

public extension DiskutilObject{
	var disk: Diskutil.Disk?{
		return self as? Diskutil.Disk
	}
	
	var partition: Diskutil.Partition?{
		return self as? Diskutil.Partition
	}
}

public final class Diskutil{
	
	public enum PartitionContentStrings: String, CaseIterable, RawRepresentable{
		case aPFSContainer = "Apple_APFS"
		case coreStorageContainer = "Apple_CoreStorage"
		case hFS = "Apple_HFS"
		case eFI = "EFI"
		case appleBoot = "Apple_Boot"
		case appleKernelCoreDump = "Apple_KernelCoreDump"
		case unusable = "Content not usable with this app, this will be considered just as a generic thing"
	}
	
	public enum DiskContentStrings: String, CaseIterable, RawRepresentable{
		case gUID = "GUID_partition_scheme"
		case mBR = "FDisk_partition_scheme"
		case aPPLE = "Apple_partition_scheme"
		case unusable = "Content not usable with this app, this will be considered just as a generic thing"
	}
	
	public struct APFSStore: DiskutilDiskPointer {
		public let DeviceIdentifier: BSDID
	}
	
	public struct Disk: DiskutilObject, Codable, Equatable {
		private let Content: String?
		public let DeviceIdentifier: BSDID
		public let Size: UInt64
		fileprivate var MountPoint: Path?
		public var mountPoint: Path?{
			return MountPoint
		}
		public var Partitions: [Partition]?
		public var APFSVolumes: [Partition]?
		public var APFSPhysicalStores: [APFSStore]?
		public let OSInternal: Bool?
		
		public var content: DiskContentStrings{
			
			for c in DiskContentStrings.allCases where Content != nil && c.rawValue == Content{
				
				return c
			}
			
			return .unusable
		}
		
		public var contentString: String?{
			return Content
		}
		
		public func isVolume() -> Bool{
			return Partitions == nil || MountPoint != nil
		}
		
		public func isMounted() -> Bool{
			return isVolume() && MountPoint != nil
		}
		
		public func hasEFIPartition() -> Bool{
			return getEFIPartition() != nil
		}
		
		public func getEFIPartition() -> Partition?{
			for part in Partitions ?? [] where part.content == .eFI{
				return part
			}
			
			return nil
		}
		
		public func isAPFSContainer() -> Bool{
			if isVolume() {return false}
			return Partitions!.isEmpty && (APFSVolumes != nil)
		}
		
		public func getAPFSPhysicalStore(record: List) -> Disk!{
			if !isAPFSContainer() { return nil }
			if APFSPhysicalStores == nil{ return nil }
			if APFSPhysicalStores!.isEmpty { return nil }
			
			for d in record.allDisksAndPartitions where d.DeviceIdentifier == APFSPhysicalStores!.first!.DeviceIdentifier{
					
				return d
			}
			
			return nil
		}
		
		public func eject(useAdminPrivileges: Bool = true) -> Bool?{
			for p in Partitions ?? [] where p.isMounted(){
				if !Diskutil.eject(mountedDiskAtPath: p.mountPoint!){
					return nil
				}
			}
			
			return Diskutil.eject(bsdID: DeviceIdentifier, useAdminPrivileges: useAdminPrivileges)
		}
		
		public mutating func unmount(useAdminPrivileges: Bool = false) -> Bool?{
			guard let res = Diskutil.unmount(bsdID: DeviceIdentifier, useAdminPrivileges: useAdminPrivileges) else { return nil }
			
			if !res {
				return false
			}
			
			for i in 0..<(Partitions?.count ?? 0){
				Partitions?[i].MountPoint = nil
			}
			
			return true
		}
	}
	
	public struct Partition: DiskutilObject, Codable, Equatable {
		public let OSInternal: Bool?
		
		private let Content: String?
		public let DeviceIdentifier: BSDID
		public let Size: UInt64
		public let DiskUUID: String?
		
		public let VolumeName: String?
		public let VolumeUUID: String?
		
		fileprivate var MountPoint: Path?
		
		public var mountPoint: Path?{
			return MountPoint
		}
		
		public var content: PartitionContentStrings{
			for c in PartitionContentStrings.allCases where Content != nil && Content == c.rawValue{
				return c
			}
			
			return PartitionContentStrings.unusable
		}
		
		public var contentString: String?{
			return Content
		}
		
		public func isVolume() -> Bool{
			return (VolumeName != nil) && (VolumeUUID != nil) && self.DeviceIdentifier.isVolume
		}
		
		public func isMounted() -> Bool{
			return isVolume() && MountPoint != nil
		}
		
		public func isRoot() -> Bool{
			return isMounted() ? (MountPoint == "/") : false
		}
		
		public mutating func mount(useAdminPrivileges: Bool = false) -> Bool?{
			guard let res = Diskutil.mount(bsdID: self.DeviceIdentifier, useAdminPrivileges: useAdminPrivileges) else { return nil }
			
			if !res {
				return false
			}
			
			MountPoint = DeviceIdentifier.mountPoint()
			
			return true
		}
		
		public mutating func unmount(useAdminPrivileges: Bool = false) -> Bool?{
			guard let res = Diskutil.unmount(bsdID: DeviceIdentifier, useAdminPrivileges: useAdminPrivileges) else { return nil }
			
			if !res {
				return false
			}
			
			MountPoint = nil
			
			return true
		}
		
		public var freeSpace: UInt64?{
			return DeviceIdentifier.freeSpace()
		}
		
	}

}
