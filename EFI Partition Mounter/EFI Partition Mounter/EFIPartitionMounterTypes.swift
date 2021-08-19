//
//  EFIPartitionMounterTypes.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

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
			for loc in EFIPartitionToolTypes.ConfigLocations.allCases{
				if !FileManager.default.fileExists(atPath: path + loc.rawValue) { continue }
				
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
