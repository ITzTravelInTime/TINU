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

import Cocoa

//this is just a simple class that represents a drive, used fot the drive scan algoritm
public class Part: UIRepresentable{
	
	init(bsdName: BSDID, fileSystem: FileSystem, isGUID: Bool, hasEFI: Bool, size: UInt64, isDrive: Bool, path: String? = nil, support: CreationProcess.DiskInfo.DriveListItem.UsableState) {
		self.bsdName = bsdName
		self.fileSystem = fileSystem
		self.isGUID = isGUID
		self.hasEFI = hasEFI
		self.size = size
		self.isDrive = isDrive
		self.path = path
		self.status = support
		
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
	
	let fileSystem: FileSystem
	
	/*
	enum PartScheme{
		case blank
		case gUID
		case mBR
		case aPPLE
	}
	
    let partScheme: PartScheme
    */
	
	let isGUID: Bool
	
	let hasEFI: Bool
	let size: UInt64
	let isDrive: Bool
	let status: CreationProcess.DiskInfo.DriveListItem.UsableState
	
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
		
		if !isDrive {
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
