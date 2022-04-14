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

#if (!macOnlyMode && TINU) || (!TINU && isTool)
public final class EFIPartitionToolTypes{
	
	public struct ConfigMenuApps: CodableDefaults, Codable, Equatable{
		
		public struct ConfigMenuApp: Codable, Equatable {
			let name: String
			let download: String
			let installedAppName: String
		}
		
		public let list: [ConfigMenuApp]
		
		public static let defaultResourceFileExtension: String = "json"
		public static let defaultResourceFileName: String = "ConfigMenuApps"
	}

	public struct PartitionStandard {var drivePartDisplayName: String = ""; var drivePartIcon: NSImage = NSImage()}

	public struct EFIPartitionStandard {
		var displayName: String = "";
		var bsdName: BSDID = BSDID();
		var isRemovable: Bool = false;
		var isMounted: Bool = false;
		var configType: ConfigLocations! = .cloverConfigLocation;
		var completeDrivePartitions: [PartitionStandard] = []
	}
	
	public struct VolumeStandard {var id: BSDID = BSDID(); var isEFI: Bool = false}
	
	public enum ConfigLocations: String, CaseIterable{
		case cloverConfigLocation = "/EFI/CLOVER/config.plist"
		case openCoreConfigLocation = "/EFI/OC/config.plist"
		
		public init?(_ path: String){
			for loc in EFIPartitionToolTypes.ConfigLocations.allCases where FileManager.default.fileExists(atPath: path + loc.rawValue){
				
				print("This EFI Partition has a \(loc.rawValue.split(separator: "/")[2]) config file")
				
				self = loc
				
				return
			}
			
			return nil
		}
	}
	
	/*
	static public let cloverConfigLocation = "/EFI/CLOVER/config.plist"
	static public let openCoreConfigLocation = "/EFI/OC/config.plist"
	*/
}



#endif
