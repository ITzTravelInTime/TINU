//
//  DiskutilListCodable.swift
//  TINU
//
//  Created by Pietro Caruso on 06/12/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Cocoa

protocol DiskutilDiskPointer: Codable, Equatable{
	var DeviceIdentifier: String {get}
}

protocol DiskutilObject{
	var DeviceIdentifier: String {get}
	var Content: String? {get}
	var Size: UInt64 {get}
	var MountPoint: String? {get}
	func isMounted() -> Bool
	func isVolume() -> Bool
}

public final class DiskutilManagement{
	
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
	
public struct Disk: DiskutilObject, Codable, Equatable {
	let Content: String?
	let DeviceIdentifier: String
	let Size: UInt64
	let MountPoint: String?
	let Partitions: [Partition]?
	let APFSVolumes: [Partition]?
	var APFSPhysicalStores: [APFSStore]?
	
	func isVolume() -> Bool{
		return Partitions == nil || MountPoint != nil
	}
	
	func isMounted() -> Bool{
		return isVolume() && MountPoint != nil
	}
	
	func getUsableContent() -> DiskContentStrings{
		if Content != nil{
			for c in DiskContentStrings.allCases{
				if c.rawValue == Content{
					return c
				}
			}
		}
		return .unusable
	}
	
	func hasEFIPartition() -> Bool{
		if isVolume() {return false}
		for part in Partitions!{
			if part.getUsableType() == .eFI{
				return true
			}
		}
		
		return false
	}
	
	func isAPFSContainer() -> Bool{
		if isVolume() {return false}
		return Partitions!.isEmpty && (APFSVolumes != nil)
	}
	
	func getAPFSPhysicalStore(record: DiskutilList) -> Disk!{
		if !isAPFSContainer() { return nil }
		if APFSPhysicalStores != nil{
			if !APFSPhysicalStores!.isEmpty{
				for d in record.AllDisksAndPartitions{
					if d.DeviceIdentifier == APFSPhysicalStores!.first!.DeviceIdentifier{
						return d
					}
				}
			}
		}
		
		return nil
	}
}

public struct APFSStore: DiskutilDiskPointer, Codable, Equatable {
	let DeviceIdentifier: String
}

public struct Partition: DiskutilObject, Codable, Equatable {
	let Content: String?
	let DeviceIdentifier: String
	let Size: UInt64
	let DiskUUID: String?
	
	let VolumeName: String?
	let VolumeUUID: String?

	let MountPoint: String?
	
	func isVolume() -> Bool{
		return (VolumeName != nil) && (VolumeUUID != nil)
	}
	
	func getUsableType() -> PartitionContentStrings{
		
		if Content != nil{
			for c in PartitionContentStrings.allCases{
				if Content == c.rawValue{
					return c
				}
			}
		}
		
		return PartitionContentStrings.unusable
	}
	
	func isMounted() -> Bool{
		return isVolume() && MountPoint != nil
	}
	
	func isRoot() -> Bool{
		return isMounted() ? (MountPoint == "/") : false
	}
	
}

public struct DiskutilList: Codable, Equatable{
	
	let AllDisks: [String]
	var AllDisksAndPartitions: [Disk]
	let VolumesFromDisks: [String]
	let WholeDisks: [String]
	
	var apfsContainersPool: [String]!
	var coreStorageContainersPool: [String]!
	
	static func readFromTerminal() -> DiskutilList!{
		
		log("Getting diskutil data to detect storage devices")
		
		let out = getOut(cmd: "diskutil list -plist")
		print(out)
		
		log("Got diskutil data? " + (!out.isEmpty ? "YES" : "NO") )
		
		if out.isEmpty { return nil }
		
		if let outData = out.data(using: .utf8) {
			do{
				var new = try PropertyListDecoder().decode(DiskutilList.self, from: outData)
				
				new.apfsContainersPool = []
				new.coreStorageContainersPool = []
				
				for d in new.AllDisksAndPartitions{
					
					if d.isVolume(){
						continue
					}
					
					if d.isAPFSContainer(){
						if d.APFSPhysicalStores != nil && new.apfsContainersPool != nil{
							var removelist = [Int]()
							for p in 0..<new.apfsContainersPool.count{
								if d.APFSPhysicalStores!.contains(APFSStore(DeviceIdentifier: new.apfsContainersPool[p])){
									removelist.append(p)
								}
							}
							for r in removelist{
								new.apfsContainersPool.remove(at: r)
							}
						}
						continue
					}
					
					for p in d.Partitions!{
						let u = p.getUsableType()
						if u == .aPFSContainer{
							if new.apfsContainersPool == nil{
								new.apfsContainersPool = []
							}
							
							new.apfsContainersPool.append(p.DeviceIdentifier)
						}else if u == .coreStorageContainer{
							if new.coreStorageContainersPool == nil{
								new.coreStorageContainersPool = []
							}
							
							new.coreStorageContainersPool.append(p.DeviceIdentifier)
						}
					}
				}
				
				for i in 0..<new.AllDisksAndPartitions.count{
					var d = new.AllDisksAndPartitions[i]
					if d.isAPFSContainer(){
						if d.APFSPhysicalStores == nil{
							d.APFSPhysicalStores = [APFSStore(DeviceIdentifier: new.apfsContainersPool!.first!)]
							new.apfsContainersPool!.removeFirst()
						}
					}
					new.AllDisksAndPartitions[i] = d
				}
				
				return new
			}catch let err{
				log("Error decoding diskutil data")
				log(err.localizedDescription)
			}
		}
		
		return  nil
	}
}

}
