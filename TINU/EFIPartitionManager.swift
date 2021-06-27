//
//  EFIPartitionManager.swift
//  TINU
//
//  Created by Pietro Caruso on 27/05/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

#if !macOnlyMode
	
	public class EFIPartitionManager{
		
		private var partitionsCache: [String]!
        
        private var isUpdatingPartitionsCache = false
        
        deinit {
            clearPartitionsCache()
        }
		
		public func mountPartition(_ withBSDID: String) -> Bool{
			log("Try to mount the EFI partition: \(withBSDID)")
            
            /*if partitionsCache == nil{
                partitionsCache = []
            }*/
            
			if checkPartition(withBSDID){
				
				var res = false
				
                var text: String!
				
				let mountCMD = "diskutil mount \(withBSDID)"
				
				if #available(OSX 10.13.6, *), !Recovery.isActuallyOn{
					if let res = Command.Sudo.run(cmd: "/bin/sh", args: ["-c", mountCMD]){
						
							text = ""
						
							for i in res.output{
								text += i + "\n"
							}
						}else{
							text = Command.Sudo.getOut(cmd: mountCMD)
						}
				}else{
					text = Command.getOut(cmd: mountCMD)
				}
				
				print(text ?? "")
                
                if text == nil{
                    return false
                }
				
				res = (text.contains("mounted") && (text.contains("Volume EFI on") || text.contains("Volume (null) on") || (text.contains("Volume ") && text.contains("on")))) || (text.isEmpty)
				
				if res{
					log("EFI partition mounted with success: \(withBSDID)")
				}else{
					log("EFI Partition not mounted, error generated: \(text!)")
				}
				
				return res
				
			}
			
			return false
		}
		
		public func clearPartitionsCache(){
			partitionsCache = nil
		}
		
		@inline(__always) public func buildPartitionsCache(){
            self.buildPartitionsCache(fromPartitionsList: self.listPartitions())
		}
        
        public func buildPartitionsCache(fromPartitionsList list: [String]!){
			if !isUpdatingPartitionsCache{
                partitionsCache = nil
                partitionsCache = list
            }
        }
		
		public func unmountPartition(_ withBSDID: String) -> Bool{
			log("Try to unmount the EFI partition: \(withBSDID)")
			/*if partitionsCache == nil{
				partitionsCache = []
			}*/
            
			if checkPartition(withBSDID){
				/*
				let id = getDriveNameFromBSDID(withBSDID)
				
				print(id)
				
				if id == nil{
					print("EFI partition already unmounted: \(withBSDID)")
					return true
				}
				*/
				
				//NSWorkspace.shared().unmountAndEjectDevice(atPath: id!)
				
				if dm.getMountPointFromPartitionBSDID(withBSDID) == nil{
					log("EFI partition already unmounted: \(withBSDID)")
					return true
				}
				
				var res = false
				
				var text = ""
				/*if #available(OSX 10.13.6, *){
					text = getOutWithSudo(cmd: "diskutil unmount \(withBSDID)")
				}else{*/
				text = Command.getOut(cmd: "diskutil unmount \(withBSDID)")
				//}
				
				res = (text.contains("unmounted") && (text.contains("Volume EFI on") || text.contains("Volume (null) on") || (text.contains("Volume ") && text.contains("on")))) || (text.isEmpty)
				
				if res{
					log("EFI partition unmounted with success: \(withBSDID)")
				}else{
					log("EFI Partition not unmounted, error generated: \(text)")
				}
				
				return res
				
				
			}
			
			return false
		}
        
        public func checkPartition(_ withBSDID: String) -> Bool{
            
            var res = false
			
			var source: [String]!
			
			if partitionsCache == nil || partitionsCache == []{
				source = listPartitions()
			}else{
				source = partitionsCache
			}
			
			if let result = source?.contains(withBSDID){
				res = result
			}else{
				res = false
			}
            
            if !res{
                print("    Invalid EFI partition: \(withBSDID)")
            }
            
            return res
        }
        
		public func listPartitions() -> [String]!{
			
			if !(partitionsCache == nil || partitionsCache == []){
				return partitionsCache
			}
			
			isUpdatingPartitionsCache = true
			
			var usableDrives: [String]! = nil
			
			do{
				print("Waiting for the drives data...")
				
				let out = Command.getOut(cmd: "diskutil list -plist")
				
				//print(out)
				
				guard let diskutilData = try (DecodeManager.decodePlistDictionaryOpt(xml: out) as? [String: Any]) else {
					print("    Wrong diskutil data!!!")
					return nil
				}
				
				print("Got drives data")
				
				/*if let drives = diskutilData["AllDisks"] as? [String]{
				for drive in drives{
				
				if !drive.hasSuffix("s1"){
				continue
				}
				
				var type: String!
				
				type = dm.getDevicePropertyInfo(drive, propertyName: "Content")
				
				if let partType = type{
				
				if partType == "EFI"{
				
				usableDrives.append(drive)
				
				print("    New EFI partition found: \(drive)")
				
				}else{
				continue
				}
				
				}else{
				continue
				}
				}
				
				}else{
				print("    Wrong disks data!!! 1")
				return nil
				}*/
				
				guard let drives = diskutilData["AllDisksAndPartitions"] as? [[String: Any]] else{
					print("    Wrong disks data!!! 2")
					return nil
				}
				
				for drive in drives{
					
					if !((drive["Content"] as? String) == "GUID_partition_scheme"){
						continue
					}
					
					guard let partitions = drive["Partitions"] as? [[String: Any]] else { continue }
					
					for partition in partitions{
						guard let content = partition["Content"] as? String else { continue }
						
						if content != "EFI"{
							continue
						}
						
						guard let id = (partition["DeviceIdentifier"] as? String) else { continue }
						
						if usableDrives == nil{
							usableDrives = []
						}
						
						usableDrives.append(id)
						print("    New EFI partition found: \(id)")
						
					}
					
				}
				
			}catch let err{
				print("EFI partitions listing error: \(err)")
				return nil
			}
			
			isUpdatingPartitionsCache = false
			
			if usableDrives != nil && partitionsCache == []{
				partitionsCache = usableDrives
			}
			
			return usableDrives
		}
	}

#endif
