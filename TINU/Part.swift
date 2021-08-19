//
//  Part.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this is just a simple class that represents a drive, used fot the drive scan algoritm
public class Part: UIRepresentable{
	
	init(bsdName: BSDID, fileSystem: Part.FileSystem, partScheme: Part.PartScheme, hasEFI: Bool, size: UInt64, isDrive: Bool, path: String? = nil) {
		self.bsdName = bsdName
		self.fileSystem = fileSystem
		self.partScheme = partScheme
		self.hasEFI = hasEFI
		self.size = size
		self.isDrive = isDrive
		self.path = path
		
		calculateChached()
	}
	
	/*
	enum PartitionSchemes: String, Equatable, Codable, CaseIterable, RawRepresentable{
		case guid = "GUID_partition_scheme"
		case mbr = "FDisk_partition_scheme"
		case applePS = "Apple_partition_scheme"
	}
	
	enum PartitionFormats: String, Equatable, Codable, CaseIterable, RawRepresentable{
		case apfs = "Apple_APFS"
		case hfs = "Apple_HFS"
		case core = "Apple_CoreStorage"
		case efi = "EFI"
		case appleBoot = "Apple_Boot"
		case appleKernelCoreDump = "Apple_KernelCoreDump"
	
		static func ignoredList() -> [PartitionFormats]{
			return [.appleBoot, .appleKernelCoreDump]
		}
	}
	*/
	
	enum FileSystem{
		case blank
		case other
		case hFS
		case aPFS
		case aPFS_container
		case coreStorage_container
	}
	
	enum PartScheme{
		case blank
		case gUID
		case mBR
		case aPPLE
	}
	
    let fileSystem: FileSystem
    let partScheme: PartScheme
    let hasEFI: Bool
	let size: UInt64
	let isDrive: Bool
	
	var apfsBDSName: BSDID?
	
	var path: String?{
		didSet{
			calculateChached()
		}
	}
	
	var bsdName: BSDID{
		didSet{
			calculateChached()
		}
	}
	
	var tmDisk = false
	
	var icon: NSImage?{
		return IconsManager.shared.getCorrectDiskIcon(bsdName)
	}
	
	var genericIcon: NSImage?{
		return icon
	}
	
	private func calculateChached(){
		let man = FileManager.default
		
		print("Getting drive display name and name")
		driveChachedName = bsdName.driveName()
		
		if hasEFI || !isDrive {
			if path != nil{
				print("  Using path-based name")
				name = man.displayName(atPath: path!)
				return
			}else{
				print("  Should be using not mounted name")
			}
		}else{
			print("  Using actual drive name")
			name = driveName
			return
		}
		
		print("  Using BSD name")
		name = nil
	}
	
	
	private var name: String?
	
	public var displayName: String{
		return name ?? self.bsdName.rawValue
	}
	
	private var driveChachedName: String?
	
	public var driveName: String{
		return driveChachedName ?? self.bsdName.rawValue
	}
	
	var app: InstallerAppInfo?{
		return nil
	}
	
	var part: Part?{
		return self
	}
}
