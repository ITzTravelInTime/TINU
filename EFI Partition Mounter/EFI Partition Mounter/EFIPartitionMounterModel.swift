//
//  EFIPartitionMounterModel.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import AppKit

#if (!macOnlyMode && TINU) || (!TINU && isTool)

public final class EFIPartitionMounterModel{
	static let shared = EFIPartitionMounterModel()
	
	/*
	private struct VirtualDisk: Equatable{
	
	}*/
	
	//new efi partition mounter system draft
	public func getEFIPartitionsAndSubprtitionsNew() -> [EFIPartitionToolTypes.EFIPartitionStandard]? {
		
		var result: [String: EFIPartitionToolTypes.EFIPartitionStandard]! = nil
		
		guard let diskutilData = DiskutilManagement.DiskutilList.readFromTerminal() else {
			print("No diskutil data!")
			return nil
		}
		
		var apfsQueue = [String: DiskutilManagement.Disk]()
		
		for disk in diskutilData.AllDisksAndPartitions{
			print("Scanning disk \(disk.DeviceIdentifier)")
			
			if disk.isAPFSContainer(){
				
				guard let stores = disk.APFSPhysicalStores else { continue }
				apfsQueue[stores.first!.DeviceIdentifier] = disk
				
				continue
			}
			
			if !disk.hasEFIPartition() { continue }
			print("  Disk has EFI partition")
			
			guard let name = dm.getDriveName(from: disk.DeviceIdentifier) else { continue }
			print("  Disk is named: \(name)")
			
			var res = EFIPartitionToolTypes.EFIPartitionStandard()
			
			res.displayName = name
			
			let removable: Bool! = dm.getDriveIsRemovable(disk.DeviceIdentifier)
			
			if removable == nil { continue }
			
			print("  Disk is " + (removable ? "removable" : "unremovable"))
			
			res.isRemovable = removable
			
			for partition in disk.Partitions!{
				if partition.getUsableType() == .eFI {
					res.isMounted = partition.isMounted()
					res.bsdName = partition.DeviceIdentifier
					res.configType = EFIPartitionToolTypes.ConfigLocations.folderHasConfig(partition.MountPoint!)
				}
				
				var part = EFIPartitionToolTypes.PartitionStandard()
				
				if !partition.isVolume(){ continue }
				
				part.drivePartDisplayName = partition.VolumeName!
				
				if !partition.isMounted(){ continue }
				
				part.drivePartIcon = NSWorkspace.shared.icon(forFile: partition.MountPoint!)
				
				res.completeDrivePartitions.append(part)
			}
			
			if result == nil{
				result = [:]
			}
			
			result[disk.DeviceIdentifier] = res
		}
		
		if result == nil{
			return nil
		}
		
		var ret: [EFIPartitionToolTypes.EFIPartitionStandard] = []
		
		for r in result{
			ret.append(r.value)
		}
		
		return ret
	}
	
	public func getEFIPartitionsAndSubprtitions() -> [EFIPartitionToolTypes.EFIPartitionStandard]?{
		
		var result: [EFIPartitionToolTypes.EFIPartitionStandard]! = nil
		
		print("Scanning to get complete partitions list for this tool")
		
		do{
			/*var tempResult = (displayName: "", bsdName: "", isMounted: false, completeDrivePartitions: [(drivePartDisplayName: "", drivePartIcon: NSImage())])
			
			result.append(tempResult)*/
			
			print("    Waiting for the volumes data for the tool...")
			
			let commandData = Command.getOut(cmd: "diskutil list -plist")
			
			//print(commandData)
			
			if commandData.isEmpty{
				print("    volumes data is empty")
				return nil
			}
			
			guard let diskutilData = try (DecodeManager.decodePlistDictionaryOpt(xml: commandData) as? [String: Any]) else {
				print("    Wrong diskutil data!!!")
				return nil
			}
			
			print("    Got drives data for the tool")
			
			var apfsContainers = [EFIPartitionToolTypes.VolumeStandard]()
			var coreStorageContainers = [EFIPartitionToolTypes.VolumeStandard]()
			
			guard let drives = diskutilData["AllDisksAndPartitions"] as? [[String: Any]] else{
				print("    Wrong disks data!!!")
				return nil
			}
			
			print("        Scanning disk and partitions to look for EFI partitions")
			volumeFor: for volumes in drives{
				
				var isEFI = false
				
				var drive = ""
				
				if let id = volumes["DeviceIdentifier"] as? String{
					drive = id
					print("            Scanning the disk: \(id)")
				}else{
					print("            This disk desn't have a device identifier, it will be skipped...")
					continue volumeFor
				}
				
				var isContainer = false
				
				if let cont = volumes["Content"] as? String{
					if cont == "Apple_HFS"{
						print("                This disk is  a core storage container")
						isContainer = true
					}
					if cont == "Apple_APFS"{
						print("                This disk is an APFS volumes container")
					}
				}
				
				if let parts = volumes["Partitions"] as? [[String: Any]]{
					
					var tempResult = EFIPartitionToolTypes.EFIPartitionStandard()
					print("                Scanning all the partitions of this drive")
					
					partitionFor: for part in parts{
						
						var partition = ""
						
						if let id = part["DeviceIdentifier"] as? String{
							partition = id
							print("                    Scanning partition: \(id)")
						}else{
							print("                    This partition does not have a device identifier, it will be skipped...")
							continue partitionFor
						}
						
						if let cont = part["Content"] as? String{
							switch cont{
							
							case "Apple_APFS":
								print("                    This partition is an APFS volumes container, adding it to the volumes container list")
								apfsContainers.append(EFIPartitionToolTypes.VolumeStandard(id: partition, isEFI: isEFI))
								continue partitionFor
							case "Apple_CoreStorage":
								print("                    This partition is a Core Storage disk container, it will be added to the list of core storage disk containers")
								coreStorageContainers.append(EFIPartitionToolTypes.VolumeStandard(id: partition, isEFI: isEFI))
								continue partitionFor
							case "EFI":
								print("                    This partition is an EFI partition")
								
								let mp = part["MountPoint"] as? String
								
								tempResult.isMounted = (mp) != nil
								
								if tempResult.isMounted{
									print("                    This EFI partition is mounted")
									
									tempResult.configType = EFIPartitionToolTypes.ConfigLocations.folderHasConfig(mp!)
									
								}else{
									print("                    This EFI partition is not mounted")
								}
								
								print("------------Getting info about this drive, because it has an EFI partition")
								
								tempResult.bsdName = partition
								
								if let name = dm.getDriveName(from: drive){
									tempResult.displayName = name
								}else{
									print("------------Can't get drive name")
									continue volumeFor
								}
								
								let removable: Bool! = dm.getDriveIsRemovable(drive)
								
								if let isDriveRemovable = removable{
									tempResult.isRemovable = isDriveRemovable
									print("------------Drive is removable: \(isDriveRemovable)")
								}else{
									print("------------Can't get is this drive is removable")
									continue volumeFor
								}
								
								isEFI = true
								
								continue partitionFor
							default:
								break
							}
						}
						
						if !isEFI{
							continue partitionFor
						}
						
						if !self.addPartition(item: &tempResult, array: part){
							continue partitionFor
						}
						
					}
					
					if isEFI{
						if result == nil{
							result = []
						}
						result.append(tempResult)
					}
				}
				
				if volumes["APFSVolumes"] != nil || isContainer{
					
					print("                Scanning all the volumes of this virtual APFS disk")
					
					var container = ""
					
					var source = [EFIPartitionToolTypes.VolumeStandard]()
					
					if isContainer{
						source = coreStorageContainers
					}else{
						source = apfsContainers
					}
					
					if source.isEmpty{
						print("                No source container partitions detected for this virtual drive")
						continue volumeFor
					}
					
					var testContainer = source.first!
					
					if let stores = volumes["APFSPhysicalStores"] as? [[String: String]] {
						if let store = stores[0]["DeviceIdentifier"]{
							var count = 0
							for cont in source{
								
								if cont.id == store{
									testContainer = cont
									source.remove(at: count)
								}
								count += 1
							}
						}
					}else{
						
						testContainer = source.first!
						source.removeFirst()
						
					}
					
					if testContainer.isEFI{
						container = testContainer.id
						print("                Detected container partition: \(container)")
					}else{
						print("                This container partition, so this apfs virtual drive do not blongs to a drive with an EFI partition, so they will be skipped")
						continue volumeFor
					}
					
					if container.isEmpty{
						print("                No container partitions detected for this virtual drive")
						continue volumeFor
					}
					
					var tempResult: EFIPartitionToolTypes.EFIPartitionStandard!
					var tempPos = 0
					
					print("                Looking for the stored EFI partiton object to associate with the volumes of this virtual disk")
					
					let parent = dm.getDriveBSDIDFromVolumeBSDID(volumeID: container)
					
					resultFor: for res in result{
						if dm.getDriveBSDIDFromVolumeBSDID(volumeID: res.bsdName) == parent{
							tempResult = res
							
							print("                Matching EFI partition object found: \(res.bsdName)")
							
							break resultFor
						}
						
						tempPos += 1
					}
					
					if tempResult == nil{
						print("                There aren't any matching EFI partition objects in the stored collection")
						continue volumeFor
					}
					
					if isContainer{
						print("                Scanning the volume of this virtual core storage drive")
						coreStorageContainers = source
						
						if !self.addPartition(item: &tempResult, array: volumes){
							continue volumeFor
						}
						
						print("                Volumed scanned successfully")
						
					}else{
						
						apfsContainers = source
						
						if let parts = volumes["APFSVolumes"] as? [[String: Any]]{
							print("                Scanning the volumes of this vistual APFS disk")
							containerFor: for part in parts{
								
								if !self.addPartition(item: &tempResult, array: part){
									continue containerFor
								}
								
							}
							print("                APFS volumes added to the stored EFI partition object")
						}
					}
					
					result[tempPos] = tempResult
					
					print("                Stored EFI partition object updated")
				}
			}
			
		}catch let err{
			print("partitions listing error: \(err)")
			
		}
		
		return result
		
	}
	
	private func addPartition(item: inout EFIPartitionToolTypes.EFIPartitionStandard, array: [String: Any]) -> Bool{
		
		print("                    Adding a partition to the partitions list of: \(item.displayName)")
		
		var tempPartition = EFIPartitionToolTypes.PartitionStandard()
		
		var mount = ""
		
		//Those if lets are not replecable with guard lets
		if let mp = array["MountPoint"] as? String{
			print("                        Partiton mount point is: \(mp)")
			
			mount = mp
			
			if mp.contains("/System/Volumes") {
				print("                        Partition mount point it's a system mount point, skipping it ...")
				return false
			}
			
			tempPartition.drivePartIcon = NSWorkspace.shared.icon(forFile: mp)
			
		}else{
			print("                        Partition not mounted, it will not be added to the list")
			return false
		}
		
		if let mp = array["VolumeName"] as? String{
			
			tempPartition.drivePartDisplayName = mp
			
		}else{
			
			let extracted = FileManager.default.displayName(atPath: mount)
			tempPartition.drivePartDisplayName = extracted
			
		}
		
		tempPartition.drivePartDisplayName = tempPartition.drivePartDisplayName.isEmpty ? "[Unititled]" : tempPartition.drivePartDisplayName
		
		print("                        Partiton name is: \(tempPartition.drivePartDisplayName)")
		
		item.completeDrivePartitions.append(tempPartition)
		
		print("                        Partition added to the list successfully")
		
		return true
	}
	
}

#endif
