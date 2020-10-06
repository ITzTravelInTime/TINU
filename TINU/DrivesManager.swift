//
//  DrivesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class DrivesManager{
	
	static let shared = DrivesManager()
	
	//return the display name of drive from it's bsd id, used in different screens, called potentially many times during the app execution
	//class func getDriveNameFromBSDID(_ id: String) -> String!{
		/*if let session = DASessionCreate(kCFAllocatorDefault) {
		let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [], options: [])!
		for volume in mountedVolumes {
		if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volume as CFURL) {
		if let bsd = DADiskGetBSDName(disk){
		if let bsdName = String.init(utf8String: bsd) {
		if "/dev/" + bsdName == id{
		return volume.path
		}
		}
		}
		}
		}
		}*/
		
		/*let res = getOut(cmd: "diskutil info \"" + id + "\" | grep \"Mount Point\" | awk '{ print substr($0, index($0,$3)) }'")
		
		if res.isEmpty{
		return nil
		}
		
		return res*/
		
		//return getDevicePropertyInfoString(id, propertyName: "MountPoint")
	//}
	
	class func getMountPointFromPartitionBSDID(_ id: String) -> String!{
		return  getDevicePropertyInfoString(id, propertyName: "MountPoint")
	}
	
	//return the display name of drive from it's bsd id, used in different screens, called potentially many times during the app execution
	class func getDeviceBSDIDFromMountPoint(_ mountPoint: String) -> String!{
		return getDevicePropertyInfoString(mountPoint, propertyName: "DeviceNode")
	}
	
	//gets the drive mount point from it's bsd name
	class func getBSDIDFromDriveName(_ path: String) -> String!{
		let res = getOut(cmd: "df -lH | grep \"" + path + "\" | awk '{print $1}'")
		
		if res.isEmpty{
			return nil
		}
		
		return res
	}
	
	//gets the drive device name from it's device name
	class func getDeviceNameFromBSDID(_ id: String) -> String!{
		return getDriveName(from: getDriveBSDIDFromVolumeBSDID(volumeID: id))
	}
	
    #if TINU
	class func getCurrentDriveName() -> String!{
		guard let id = cvm.shared.currentPart?.bsdName else {return nil}
		
		return getDeviceNameFromBSDID(id)
	}
    #endif
	
	class func getDriveName(from deviceid: String) -> String!{
		var name: String!
	
		if #available(OSX 10.12, *){
			name = getDevicePropertyInfoString(deviceid, propertyName: "IORegistryEntryName")
		}else{
			name = getDevicePropertyInfoString(deviceid, propertyName: "MediaName")
		}
	
		if name != nil{
		
			if #available(OSX 10.12, *){
				name = name!.deletingSuffix(" Media")
			}
		
			name = name!.isEmpty ? "Untitled drive" : name
		
			print("------------Drive name: \(name!)")
		}else{
			print("------------Can't get the drive name for this drive")
		}
		
		return name
	}
	
	private static var _id: String = ""
	private static var _out: String! = ""
	
	class func getDevicePropertyInfoAny(_ id: String, propertyName: String) -> Any!{
		do{
			if id.isEmpty{
				return nil
			}
			
			//probably another check is needed to avoid having different devices plugged one after the other and all having the same id being used with the info from one
			if _id != id || _out == nil{
				_id = id
				_out = getOut(cmd: "diskutil info -plist \"" + id + "\"")
				
				if _out.isEmpty{
					return nil
				}
				
			}
			
			if let dict = try DecodeManager.decodePlistDictionary(xml: _out) as? [String: Any]{
				return dict[propertyName]
			}
			
		}catch let err{
			print("Getting diskutil info property decoding error: \(err.localizedDescription)")
		}
		
		return nil
	}
	
	class func getDevicePropertyInfoString(_ id: String, propertyName: String) -> String!{
		guard let pitm = getDevicePropertyInfoAny(id, propertyName: propertyName) else{ return nil }
					
		let itm = "\(pitm)"
					
		if !itm.isEmpty{
			return itm
		}
		
		return nil
	}
    
    class func getDevicePropertyInfoBoolNew(_ id: String, propertyName: String) -> Bool!{
		return getDevicePropertyInfoAny(id, propertyName: propertyName) as? Bool
    }
	
	/*
	class func getDevicePropertyInfoOld(_ id: String, propertyName: String) -> String!{
		let res = getOut(cmd: "diskutil info \"" + id + "\" | grep \"\(propertyName)\" | awk '{ print substr($0, index($0,$3)) }'")
		
		if res.isEmpty{
			return nil
		}
		
		return res
		
	}
	*/
	
	//checks if the drive exists if it can find it's mount point
	class func driveIsMounted(id: String) -> Bool{
		return getMountPointFromPartitionBSDID(id) != nil
	}
	
	//checks if the drive exists if it can find it's bsd id from it's mount point
	class func driveHasID(path: String) -> Bool{
		return getBSDIDFromDriveName(path) != nil
	}
	
	//return the drive sbd id of a volume
	class func getDriveBSDIDFromVolumeBSDID(volumeID: String) -> String{
		var tmpBSDName = ""
		var ns = 0
		
		for cc in volumeID{
			let c = String(cc)
			if c.lowercased() == "s"{
				ns += 1
			}
			if ns == 1{
				if let _ = Int(c){
					tmpBSDName += c
				}
			}
		}
		
		return "disk" + tmpBSDName
	}
	
	
	
}

typealias dm = DrivesManager
