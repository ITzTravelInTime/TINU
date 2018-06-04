//
//  EFIPartitionManager.swift
//  TINU
//
//  Created by Pietro Caruso on 27/05/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if !macOnlyMode
	
	public final class EFIPartitionManager{
		static var shared = EFIPartitionManager()
		
		public func mountPartition(_ withBSDID: String) -> Bool{
			print("Try to mount the EFI partition: \(withBSDID)")
			if checkPartition(withBSDID){
				
				var text = ""
				
				if installerAppSupportsThatVersion(version: 13.6){
					text = getOutWithSudo(cmd: "diskutil mount \(withBSDID)")
				}else{
					text = getOut(cmd: "diskutil mount \(withBSDID)")
				}
				
				if !(text.contains("mounted") && text.contains("Volume EFI on")){
					log("    EFI Partition mount error: \(text)")
				}else{
					print("EFI partition mounted with success: \(withBSDID)")
					return true
				}
				
				
			}
			
			return false
		}
		
		public func unmounPartition(_ withBSDID: String) -> Bool{
			print("Try to unmount the EFI partition: \(withBSDID)")
			if checkPartition(withBSDID){
				/*
				let id = getDriveNameFromBSDID(withBSDID)
				
				print(id)
				
				if id == nil{
					print("EFI partition already unmounted: \(withBSDID)")
					return true
				}
				*/
				
				var res = false//NSWorkspace.shared().unmountAndEjectDevice(atPath: id!)
				
				let text = getOut(cmd: "diskutil unmount \(withBSDID)")
				
				res = (text.contains("unmounted") && text.contains("Volume EFI on")) || (text == "")
				
				if res{
					print("EFI partition unmounted with success: \(withBSDID)")
				}else{
					log("EFI Partition not unmounted, error generated: \(text)")
				}
				
				return res
				
				
			}
			
			return false
		}
		
		public func checkPartition(_ withBSDID: String) -> Bool{
			let res = listPartitions().contains(withBSDID)
			
			if !res{
				print("    Invalid EFI partition: \(withBSDID)")
			}
			
			return res
		}
		
		public func listPartitions() -> [String]!{
			
			let usableDrives: [String]!
			
			do{
				print("Waiting for the drives data ...")
				
				usableDrives = []
				
				if let diskutilData = try (decodeXMLDictionaryOpt(xml: getOut(cmd: "diskutil list -plist")) as? [String: Any]){
					
					print("Got drives data")
					
					if let drives = diskutilData["AllDisks"] as? [String]{
						for drive in drives{
							
							if let partType = getDevicePropertyInfo(drive, propertyName: "Partition Type"){
							
								if partType == "EFI"{
								
									usableDrives.append(drive)
								
									print("    New EFI partition found: \(drive)")
								
								}
								
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
