/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

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

extension CreationProcess{
	public class DiskInfo: CreationProcessSection, CreationProcessFSObject{		
		
		var ref: CreationProcess
		
		required init(reference: CreationProcess){
			ref = reference
		}
		
		//this variable stores various info about the chosen drive
		public var current: Part!
		
		//this variable tells to the app if the selected drive needs to be formatted using GUID partition method
		public var shouldErase: Bool{
			if current == nil{
				return false
			}
			
			if !current!.isGUID || !current!.hasEFI || current.isDrive{
				return true
			}
				
			if !ref.installMac && current!.fileSystem == .aPFS{
				return true
			}
				
			if ref.installMac && (current!.fileSystem == .other || !current!.hasEFI){
				return true
			}
			
			return false
		}
		//used to detect if a volume relly uses apfs or it's just an internal apple volume
		public var isAPFS: Bool{
			if current == nil { return false }
			return (current!.fileSystem == .aPFS_container)
		}
		//thi is used to determinate if there is the need for the time machine warn
		public var warnForTimeMachine: Bool{
			return current?.tmDisk ?? false
		}
		
		//this variable is the drive or partition that the user has selected
		public var path: String!{
			return current?.path
		}
		
		//this variable is the bsd name of the drive or partition currently selected by the user
		public var bSDDrive: BSDID!{
			return current?.bsdName
		}
		
		//this variable is used to store apfs disk bsd id
		public var aPFSContaninerBSDDrive: BSDID!{
			return current?.part?.apfsBDSName
		}
		
		func compareSize(to number: UInt64) -> Bool{
			return (current != nil) ? (current?.size ?? 0 > number + UInt64(5 * pow(10.0, 8.0))) : false
		}
		
		func compareSize(to string: String!) -> Bool{
			guard let s = string?.uInt64Value else { return false }
			return compareSize(to: s)
		}
		
		func meetsRequirements(size bytes: UInt64) -> Bool{
			let gbyte = UInt64(pow(10.0, 9.0))
			
			if simulateCreateinstallmediaFail != nil{
				return (bytes >= (2 * gbyte)) // 2 gb
			}
			
			if ref.installMac{
				return (bytes >= (30 * gbyte)) //20 gb
			}
			
			return (bytes >= (6 * gbyte)) // 6 gb
		}
		
		struct DriveListItem{
			enum UsableState: UInt8, Codable, Equatable{
				case ok = 0
				case tooSmall
				case belongsToBoot
				case runningThisAppFrom
				case undefined
			}
			public let disk: Diskutil.Disk
			public var partition: Diskutil.Partition! = nil
			public var state: UsableState
		}
		
		func getUsableDriveListAll() -> [DriveListItem]?{
			var ret = [DriveListItem]()
			
			print("Detecting drives and partitions")
			
			//just need to know which is the boot volume, to not allow the user to choose it
			let boot = BSDID(fromMountPoint: "/")!
			var boot_drives = [boot.driveID]
			let execp = Bundle.main.executablePath!
			
			print("Boot volume BSDID: \(boot)")
			
			//new Codable-Based storage devices search
			guard let data = Diskutil.List() else { return nil }
			
			print("Successfully got diskutil data")
			
			//Retives the boot-volume virtual disks
			for disk in data.allDisksAndPartitions{
				if disk.DeviceIdentifier != boot_drives.first!{
					continue
				}
				
				guard let stores = disk.APFSPhysicalStores else { continue }
				
				for s in stores {
					boot_drives.append(s.DeviceIdentifier.driveID)
				}
			}
			
			print("The boot drive devices are: ")
			print(boot_drives)
			
			log("Analyzing disk data to detect usable storage devices")
			
			alldiskFor: for disk in data.allDisksAndPartitions{
				log("    Drive: \(disk.DeviceIdentifier)")
				
				if disk.isAPFSContainer(){
					log("      Drive is a container drive, skipping it")
					continue
				}
				
				ret.append(DriveListItem(disk: disk, partition: nil, state: .undefined))
				let diskIndex = ret.count - 1
				
				if !meetsRequirements(size: disk.Size){
					log("      Drive is not big enougth to be used for macOS installers, marking as unusable")
					ret[diskIndex].state = .tooSmall
					continue
				}
				
				if (boot_drives.contains(disk.DeviceIdentifier)){
					log("      Drive belongs to the boot drive")
					ret[diskIndex].state = .belongsToBoot
				}
				
				log("      Drive meets all the requirements")
				
				if ret[diskIndex].state == .undefined{
					ret[diskIndex].state = .ok
				}
				
				log("      scanning the partitions to find usable ones:")
				
				let hasEFI = disk.hasEFIPartition()
				
				partitionFor: for partition in disk.Partitions ?? []{
					log("        Partition/Volume: \(partition.DeviceIdentifier)")
					
					let t = partition.content
					
					log("            Partition/Volume content: \( t == Diskutil.PartitionContentStrings.unusable ? "Other file system" : t.rawValue )")
					
					if t == .aPFSContainer || t == .coreStorageContainer{
						log("            Partition is a container disk, skipping it")
						continue
					}
					
					/*
					if t == .eFI{
						log("            Partition is an EFI partition, skipping it")
						continue
					}
					*/

					if !partition.isMounted(){
						log("            Partition is not mounted, it needs to be mounted in order to be detected and usable with what we need to do later on")
						continue
					}
					
					if hasEFI{
						ret.append(.init(disk: disk, partition: partition, state: .undefined))
					}
					
					let partIndex = hasEFI ? ret.count - 1 : diskIndex
					
					if !meetsRequirements(size: partition.Size){
						log("            Partition is not big enough to be used as a mac os installer or to house a macOS installation, it will be marked as unusable")
						
						if hasEFI{
							ret[partIndex].state = .tooSmall
						}
						
						continue
					}
					
					if execp.contains(partition.mountPoint!) {
						log("            TINU is running from this partition, marking it as unusable")
						
						for i in diskIndex...partIndex{
							ret[i].state = .runningThisAppFrom
						}
						
						continue
					}
					
					log("            Partition meets all the requirements, it will be added to the detected partitions list as usable")
					
					if hasEFI{
						if ret[partIndex].state == .undefined{
							ret[partIndex].state = .ok
						}
					}
				}
			}
			
			return ret
		}
		
		func getUsableDriveListNew() -> [DriveListItem]?{
			var ret = [DriveListItem]()
			
			//just need to know which is the boot volume, to not allow the user to choose it
			let boot = BSDID(fromMountPoint: "/")!
			var boot_drive = [boot.driveID]
			let execp = Bundle.main.executablePath!
			
			print("Boot volume BSDID: \(boot)")
			
			//new Codable-Based storage devices search
			guard let data = Diskutil.List() else { return nil }
			
			log("Analyzing diskutil data to detect usable storage devices")
			
			for d in data.allDisksAndPartitions{
				if d.DeviceIdentifier != boot_drive.first!{
					continue
				}
				
				guard let stores = d.APFSPhysicalStores else { continue }
				
				for s in stores {
					boot_drive.append(s.DeviceIdentifier.driveID)
				}
			}
			
			print("The boot drive devices are: ")
			print(boot_drive)
			
			alldiskFor: for d in data.allDisksAndPartitions{
				log("    Drive: \(d.DeviceIdentifier)")
				
				if boot_drive.contains(d.DeviceIdentifier){
					log("        Skipping this drive, it's the boot drive or in the boot drive")
					continue
				}
				
				if !meetsRequirements(size: d.Size){
					log("        Drive is not big enough for our purposes")
					continue
				}
				
				#if noUnmounted
				var ref: Diskutil.Partition?
				
				if !d.isMounted(){
					for p in d.Partitions ?? []{
						if p.isMounted(){
							ref = p
							break
						}
					}
				}
				
				if ref == nil{
					log("        Drive has no mounted partitions, those are needed in order to detect a drive")
					continue
				}
				#endif
				
				log("        Drive seems to meet all the requirements for our purposes, it will be added to the list")
				
				//self.makeAndDisplayItem(ref, &drives, d, false)
				
				ret.append(.init(disk: d, partition: nil, state: .ok))
				
				log("        Drive added to list")
				
				if !d.hasEFIPartition(){ // <=> has and efi partition and has some sort of GPT or GUID partition table
					continue
				}
				
				log("        Drive has EFI partition and is GUID")
				log("        All the partitions of the drive will be scanned in order to detect the usable partitions")
				
				for p in d.Partitions ?? []{
					
					log("        Partition/Volume: \(p.DeviceIdentifier)")
					
					let t = p.content
					
					log("            Partition/Volume content: \( t == Diskutil.PartitionContentStrings.unusable ? "Other file system" : t.rawValue )")
					
					if t == .aPFSContainer || t == .coreStorageContainer{
						log("            Partition is a container disk")
						continue
					}
					
					if !meetsRequirements(size: p.Size){
						log("            Partition is not big enough to be used as a mac os installer or to house a macOS installation")
						continue
					}
					
					if !p.isMounted(){
						log("            Partition is not mounted, it needs to be mounted in order to be detected and usable with what we need to do later on")
						continue
					}
					
					if execp.contains(p.mountPoint!) {
						log("            TINU is running from this partition, skipping to the next drive")
						continue alldiskFor
					}
					
					log("            Partition meets all the requirements, it will be added to the detected partitions list")
					
					//self.makeAndDisplayItem(p, &drives)
					
					ret.append(.init(disk: d, partition: p, state: .ok))
					
					log("            Partition added to the list")
				}
				
			}
			
			return ret
		}
		
		/*
		func getUsableDriveList() -> [DriveListItem]?{
			var ret = [DriveListItem]()
			
			//just need to know which is the boot volume, to not allow the user to choose it
			let boot = BSDID(fromMountPoint: "/")!
			var boot_drive = [boot.driveID]
			let execp = Bundle.main.executablePath!
			
			print("Boot volume BSDID: \(boot)")
			
			//new Codable-Based storage devices search
			guard let data = Diskutil.List() else { return nil }
			
			log("Analyzing diskutil data to detect usable storage devices")
			
			for d in data.allDisksAndPartitions{
				if d.DeviceIdentifier != boot_drive.first!{
					continue
				}
				
				guard let stores = d.APFSPhysicalStores else { continue }
				
				for s in stores {
					boot_drive.append(s.DeviceIdentifier.driveID)
				}
			}
			
			print("The boot drive devices are: ")
			print(boot_drive)
			
			alldiskFor: for d in data.allDisksAndPartitions{
				log("    Drive: \(d.DeviceIdentifier)")
				
				if boot_drive.contains(d.DeviceIdentifier){
					log("        Skipping this drive, it's the boot drive or in the boot drive")
					continue
				}
				
				if d.hasEFIPartition(){ // <=> has and efi partition and has some sort of GPT or GUID partition table
					log("        Drive has EFI partition and is GUID")
					log("        All the partitions of the drive will be scanned in order to detect the usable partitions")
					for p in d.Partitions ?? []{
						log("        Partition/Volume: \(p.DeviceIdentifier)")
						let t = p.getUsableType()
						
						log("            Partition/Volume content: \( t == Diskutil.PartitionContentStrings.unusable ? "Other file system" : t.rawValue )")
						
						if t == .aPFSContainer || t == .coreStorageContainer{
							log("            Partition is a container disk")
							continue
						}
						
						if !meetsRequirements(size: p.Size){
							log("            Partition is not big enough to be used as a mac os installer or to house a macOS installation")
							continue
						}
						
						if !p.isMounted(){
							log("            Partition is not mounted, it needs to be mounted in order to be detected and usable with what we need to do later on")
							continue
						}
						
						if execp.contains(p.MountPoint!) {
							log("            TINU is running from this partition, skipping to the next drive")
							continue alldiskFor
						}
						
						log("            Partition meets all the requirements, it will be added to the detected partitions list")
						
						//self.makeAndDisplayItem(p, &drives)
						
						ret.append(.init(item: p))
						
						log("            Partition added to the list")
					}
				}else{
					log("        Drive is not GPT/GUID or doesn't seem to have an EFI partition, it will be detected only as a drive instead of showing the partitions as well")
				}
				
				if !meetsRequirements(size: d.Size){
					log("        Drive is not big enough for our purposes")
					continue
				}
				
				var ref: DiskutilObject!
				
				if d.isVolume(){
					if d.isMounted(){
						ref = d
					}
				}else{
					
					for p in d.Partitions!{
						if p.isMounted(){
							ref = p
							break
						}
					}
					
				}
				
				#if noUnmounted
				if ref == nil{
					log("        Drive has no mounted partitions, those are needed in order to detect a drive")
					continue
				}
				#endif
				
				log("        Drive seems to meet all the requirements for our purposes, it will be added to the list")
				
				//self.makeAndDisplayItem(ref, &drives, d, false)
				
				ret.append(.init(item: ref, origin: d, isGUIDwEFI: false))
				
				log("        Drive added to list")
				
			}
			
			return ret
		}*/
	}
}
