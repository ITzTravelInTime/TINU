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

import AppKit

//TODO: Make this accept the multiple additional parameters init somehow
protocol CreationProcessSection {
	var ref: CreationProcess { get }
	init(reference: CreationProcess)
}

protocol UIRepresentable {
	var displayName: String { get }
	var icon: NSImage? { get }
	var genericIcon: NSImage? { get }
	var app: InstallerAppInfo? { get }
	var part: Part? { get }
	var size: UInt64 { get }
	var path: String? { get }
}

protocol CreationProcessFSObject{
	associatedtype T: UIRepresentable
	var current: T! { get set }
	var path: String! { get }
}

public class CreationProcess{
	
	static var shared = CreationProcess()
	
	required init(){
		options = OptionsManager(reference: self)
		app = InstallerAppManager(reference: self)
		disk = DiskInfo(reference: self)
	}
	
	let process: Management = Management()
	var disk   : DiskInfo! = nil
	var app    : InstallerAppManager! = nil
	var options: OptionsManager! = nil
	
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
		
		//InstallMediaCreationManager.shared.OtherOptionsBeforeformat(canFormat: &canFormat, useAPFS: &apfs)
		
		if !options.execution.canFormat{
			print("Getting drive info about the used volume")
			
			guard let s = disk.current.path else{
				print("The selected volume mount point is empty")
				return false
			}
			
			var sv = s
			
			if !FileManager.default.directoryExistsAtPath(sv){
				guard let sb = disk.bSDDrive else{
					print("Can't get the device id!!")
					return false
				}
				
				guard let sd = sb.mountPoint() else{
					print("Can't get the mount point!!")
					return false
				}
				
				sv = sd
				disk.current.path = sv
				print("Corrected the name of the target volume")
				
			}
			
			print("Mount point: \(sv)")
			
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
		
		//TODO: add some optimized check (possibly with stuff like caching, maybe using the cache of the app variable) to know if the alternate executable exists
		//only on yosemite use the dedicated executable provvided by the macOS 12+ installer app
		if #available(macOS 10.10, *){ if #available(macOS 10.11, *){ } else{
			if app.info.supports(version: 17) ?? false{
				return "createinstallmedia_yosemite"
			}
		}}
		
		return "createinstallmedia"
	}
	
	public var actualExecutableName: String{
		if app.current.status == .legacy{
			return "asr"
		}
		
		return executableName
	}
}

typealias cvm = CreationProcess
