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
		public var bSDDrive: String!{
			return current?.bsdName
		}
		
		//this variable is used to store apfs disk bsd id
		public var aPFSContaninerBSDDrive: String!{
			return current?.apfsBDSName
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
	}
}
