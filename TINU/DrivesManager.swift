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
	class func getDriveNameFromBSDID(_ id: String) -> String!{
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
		
		return getDevicePropertyInfo(id, propertyName: "MountPoint")
	}
	
	//return the display name of drive from it's bsd id, used in different screens, called potentially many times during the app execution
	class func getDeviceBSDIDFromMountPoint(_ mountPoint: String) -> String!{
		/*let res = getOut(cmd: "diskutil info \"" + mountPoint + "\" | grep \"Device Node\" | awk '{ print substr($0, index($0,$3)) }'")
		
		if res.isEmpty{
		return nil
		}
		
		return res
		*/
		return getDevicePropertyInfo(mountPoint, propertyName: "DeviceNode")
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
		return getDeviceNameFromSpecificBSDID(getDriveBSDIDFromVolumeBSDID(volumeID: id))
	}
	
	
	class func getDeviceNameFromSpecificBSDID(_ id: String) -> String!{
		/*let res = getOut(cmd: "diskutil info \"" + id + "\" | grep \"Device / Media Name\" | awk '{ print substr($0, index($0,$3)) }'")
		
		if res.isEmpty{
		return nil
		}
		
		return res*/
		
		return getDevicePropertyInfo(id, propertyName: "MediaName")
	}
	
    #if TINU
	class func getCurrentDriveName() -> String!{
		
		var retname: String!
		
		let rawID = cvm.shared.currentPart?.bsdName
		
		if let bsdID = rawID{
			
			let driveID = getDriveBSDIDFromVolumeBSDID(volumeID: bsdID)
		
			if #available(OSX 10.12, *){
				retname = getDevicePropertyInfoNew(driveID, propertyName: "IORegistryEntryName")!
				retname.deleteSuffix(" Media")
			}else{
				retname = getDevicePropertyInfoNew(driveID, propertyName: "MediaName")!
			}
			
		}
		
		return retname
	}
    #endif
	
	class func getDriveName(from deviceid: String) -> String!{
		var name: String!
	
		if #available(OSX 10.12, *){
			name = getDevicePropertyInfoNew(deviceid, propertyName: "IORegistryEntryName")
		}else{
			name = getDevicePropertyInfoNew(deviceid, propertyName: "MediaName")
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
	
	@inline(__always) class func getDevicePropertyInfo(_ id: String, propertyName: String) -> String!{
		return getDevicePropertyInfoNew(_: id, propertyName: propertyName)
	}
	
	private static var _id: String = ""
	private static var _out: String! = ""
	
	class func getDevicePropertyInfoNew(_ id: String, propertyName: String) -> String!{
		
		do{
			if id.isEmpty{
				return nil
			}
			
			if _id != id || _out == nil{
				_id = id
            	_out = getOut(cmd: "diskutil info -plist \"" + id + "\"")
			}
			
			if _out != nil{
            
				if let dict = try DecodeManager.decodePlistDictionary(xml: _out) as? [String: Any]{
				
					if let pitm = dict[propertyName]{
						let itm = "\(pitm)"
					
						if !itm.isEmpty{
							return itm
						}
					}
				}
				
			}
			
		}catch let err{
			print("Getting diskutil info property decoding error: \(err.localizedDescription)")
		}
		
		return nil
	}
    
    class func getDevicePropertyInfoBoolNew(_ id: String, propertyName: String) -> Bool!{
        
        do{
            let out = getOut(cmd: "diskutil info -plist \"" + id + "\"")
            
            
            
            if let dict = try DecodeManager.decodePlistDictionary(xml: out) as? [String: Any]{
                
                if let pitm = dict[propertyName]{
                    return pitm as? Bool
                    
                }else{
                    return nil
                }
            }else{
                return nil
            }
            
        }catch let err{
            print("Getting diskutil info property decoding error: \(err.localizedDescription)")
            return nil
        }
		
    }
	
	class func getDevicePropertyInfoOld(_ id: String, propertyName: String) -> String!{
		let res = getOut(cmd: "diskutil info \"" + id + "\" | grep \"\(propertyName)\" | awk '{ print substr($0, index($0,$3)) }'")
		
		if res.isEmpty{
			return nil
		}
		
		return res
		
	}
	
	//checks if the drive exists if it can find it's mount point
	class func driveExists(id: String) -> Bool{
		return getDriveNameFromBSDID(id) != nil
	}
	
	//checks if the drive exists if it can find it's bsd id from it's mount point
	class func driveExists(path: String) -> Bool{
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
