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
		static var shared = EFIPartitionManager()
		
		private var partitionsCache: [String]!
		
		public func mountPartition(_ withBSDID: String) -> Bool{
			log("Try to mount the EFI partition: \(withBSDID)")
			if checkPartition(withBSDID){
				
				var res = false
				
                var text: String!
				
				if #available(OSX 10.13.6, *){
					text = getOutWithSudo(cmd: "diskutil mount \(withBSDID)")
				}else{
					text = getOut(cmd: "diskutil mount \(withBSDID)")
				}
				
				print(text)
                
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
		
		public func buildPartitionsCache(){
			partitionsCache = nil
			partitionsCache = listPartitions()
		}
		
		public func unmountPartition(_ withBSDID: String) -> Bool{
			log("Try to unmount the EFI partition: \(withBSDID)")
			if partitionsCache == nil{
				partitionsCache = []
			}
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
				
				if dm.getDriveNameFromBSDID(withBSDID) == nil{
					log("EFI partition already unmounted: \(withBSDID)")
					return true
				}
				
				var res = false
				
				var text = ""
				/*if #available(OSX 10.13.6, *){
					text = getOutWithSudo(cmd: "diskutil unmount \(withBSDID)")
				}else{*/
					text = getOut(cmd: "diskutil unmount \(withBSDID)")
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
			
			if partitionsCache == nil{
				res = listPartitions().contains(withBSDID)
			}else{
				if partitionsCache == []{
					partitionsCache = listPartitions()
				}
				res = partitionsCache.contains(withBSDID)
			}
			
			if !res{
				print("    Invalid EFI partition: \(withBSDID)")
			}
			
			return res
		}
		
		public func listPartitions() -> [String]!{
			
		if partitionsCache != nil{
			
			if partitionsCache == []{
				buildPartitionsCache()
			}
			
			return partitionsCache
		}
			
			let usableDrives: [String]!
			
			do{
				print("Waiting for the drives data ...")
				
				usableDrives = []
				
				if let diskutilData = try (PlistXMLManager.decodeXMLDictionaryOpt(xml: getOut(cmd: "diskutil list -plist")) as? [String: Any]){
					
					print("Got drives data")
					
					if let drives = diskutilData["AllDisks"] as? [String]{
						for drive in drives{
							
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
						print("    Wrong disks data!!!")
						return nil
					}
					
				}else{
					print("    Wrong diskutil data!!!")
					return nil
				}
				
			}catch let err{
				print("EFI partitions listing error: \(err)")
				return nil
			}
			
			return usableDrives
		}
	}
	
#endif
