//
//  TargetDiskManager.swift
//  TINU
//
//  Created by Pietro Caruso on 22/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

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
			
			if current!.partScheme != .gUID || !(current!.hasEFI){
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
			let gb = UInt64(pow(10.0, 9.0))
			
			if simulateCreateinstallmediaFail != nil{
				return !(bytes <= (2 * gb)) // 2 gb
			}
			
			if ref.installMac{
				return !(bytes <= (20 * gb)) //20 gb
			}
			
			return !(bytes <= (6 * gb)) // 6 gb
		}
		
		struct DriveListItem{
			public let disk: Diskutil.Disk
			public var partition: Diskutil.Partition! = nil
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
				
				ret.append(.init(disk: d))
				
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
					
					ret.append(.init(disk: d, partition: p))
					
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
