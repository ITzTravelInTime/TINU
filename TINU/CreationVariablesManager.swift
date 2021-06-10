//
//  CreationVariablesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

protocol CreationVariablesManagerSection {
	var ref: CreationVariablesManager { get }
	init(reference: CreationVariablesManager)
}

public class CreationVariablesManager{
	
	class CreateinstallmediaSmallManager{
		
		enum Status: UInt8, CaseIterable, Codable, Equatable{
			case configuration = 0
			case preCreation
			case creation
			case postCreation
			case doneSuccess
			case doneFailure
			
			func isBusy() -> Bool{
				return (self == .creation || self == .preCreation || self == .postCreation)
			}
		}
		
		public var status: Status = .configuration
		
		//variables used to manage the creation process
		public var process = Process()
		public var errorPipe = Pipe()
		public var outputPipe = Pipe()
		
		public var startTime = Date()
	}
	
	class DiskInfo{
		
		var ref: CreationVariablesManager
		
		//this variable stores various info about the chosen drive
		public var part: Part!
		
		//this variable tells to the app if the selected drive needs to be formatted using GUID partition method
		public var shouldErase: Bool
		//used to detect if a volume relly uses apfs or it's just an internal apple volume
		public var isAPFS: Bool
		//thi is used to determinate if there is the need for the time machine warn
		public var warnForTimeMachine: Bool
		
		required init(reference: CreationVariablesManager, newPart: Part! = nil){
			ref = reference
			isAPFS = false
			shouldErase = false
			warnForTimeMachine = false
			part = newPart
			
			if part != nil{
				if part.partScheme != .gUID || !part.hasEFI{
					shouldErase = true
				}
					
				if !ref.installMac && part.fileSystem == .aPFS{
					shouldErase = true
				}
					
				if ref.installMac && (part.fileSystem == .other || !part.hasEFI){
					shouldErase = true
				}
					
				if part.tmDisk{
					warnForTimeMachine = true
				}
				
				isAPFS = (part.fileSystem == .aPFS_container)
			}
				
			
		}
		
		//this variable is the drive or partition that the user has selected
		public var path: String!{
			get{
				return part.mountPoint
			}
			set{
				part.mountPoint = newValue
			}
		}
		
		//this variable is the bsd name of the drive or partition currently selected by the user
		public var bSDDrive: String!{
			get{
				return part.bsdName
			}
			set{
				part.bsdName = newValue
			}
		}
		
		func driveName() -> String!{
			guard let id = bSDDrive else {return nil}
			return dm.getDeviceNameFromBSDID(id)
		}
		
		//this variable is used to store apfs disk bsd id
		public var aPFSContaninerBSDDrive: String!{
				return part.apfsBDSName
		}
		
		func compareSize(to number: UInt64) -> Bool{
			//print(currentPart.size)
			//print(number)
			return (part != nil) ? (part.size > number + UInt64(5 * pow(10.0, 8.0))) : false
		}
		
		func compareSize(to string: String!) -> Bool{
			if let s = UInt64(string){
				return compareSize(to: s)
			}
			return false
		}
	}
	
	func checkProcessReadySate(_ useDriveIcon: inout Bool) -> Bool {
		
		if let sa = app.path{
			print("Check installer app")
			if !FileManager.default.directoryExistsAtPath(sa){
				print("Missing installer app in the specified directory")
				return false
			}
			print("Installaer app that will be used is: " + sa)
		}else{
			print("Missing installer in memory")
			return false
		}
		
		var canFormat = false
		var apfs = false
		
		InstallMediaCreationManager.shared.OtherOptionsBeforeformat(canFormat: &canFormat, useAPFS: &apfs)
		
		if !(cvm.shared.disk.part!.isDrive || canFormat){
			print("Getting drive info about the used volume")
			if let s = disk.path{
				var sv = s
				
				if !FileManager.default.directoryExistsAtPath(sv){
					if let sb = disk.bSDDrive{
						if let sd = dm.getPropertyInfoString(sb, propertyName: "MountPoint"){
							sv = sd
							disk.path = sv
							print("Corrected the name of the target volume")
						}else{
							print("Can't get the mount point!!")
							return false
						}
					}else{
						print("Can't get the device id!!")
						return false
					}
				}
				
				print("Mount point: \(sv)")
			}else{
				print("The selected volume mount point is empty")
				return false
			}
		}else{
			print("A drive has been selected or a partition that needs format")
			useDriveIcon = true
		}
		
		print("Everything is ready to start the installer creation process")
		return true
	}
	
	public var installMac: Bool = false

	//this variable returns the name of the current executable used by the app
	public var executableName: String{
		/*
			var res = "createinstallmedia"
			if sharedInstallMac{
				res = "startosinstall"
			}
			log(res)
			return res
		*/
		if installMac{
			return "startosinstall"
		}
		
		
		
		//only on yosemite use the dedicated executable provvided by the macOS 12+ installer app
		if #available(macOS 10.10, *){ if #available(macOS 10.11, *){ } else{
			if app.installerAppSupportsThatVersion(version: 17) ?? false{
				return "createinstallmedia_yosemite"
			}
		}}
		
		return "createinstallmedia"
	}
	
	static let shared = CreationVariablesManager()
	
	required init(){
		options = OtherOptionsManager(reference: self)
		app = InstallerAppManager(reference: self)
		disk = DiskInfo(reference: self)
	}
	
	let process: CreateinstallmediaSmallManager = CreateinstallmediaSmallManager()
	var disk   : DiskInfo! = nil
	var app    : InstallerAppManager! = nil
	var options: OtherOptionsManager! = nil
}

typealias cvm = CreationVariablesManager
