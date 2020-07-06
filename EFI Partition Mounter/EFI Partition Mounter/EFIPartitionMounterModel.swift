//
//  EFIPartitionMounterModel.swift
//  TINU
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)

public final class EFIPartitionMounterModel{
    static let shared = EFIPartitionMounterModel()
    
    public func getEFIPartitionsAndSubprtitions(response: @escaping ([EFIPartitionToolTypes.EFIPartitionStandard]?) -> Void){
        
        DispatchQueue.global(qos: .background).async {
            
            var result: [EFIPartitionToolTypes.EFIPartitionStandard]! = nil
            
            print("Scanning to get complete partitions list for this tool")
            
            do{
                /*var tempResult = (displayName: "", bsdName: "", isMounted: false, completeDrivePartitions: [(drivePartDisplayName: "", drivePartIcon: NSImage())])
                 
                 result.append(tempResult)*/
                
                print("    Waiting for the volumes data for the tool...")
                
                let commandData = getOut(cmd: "diskutil list -plist")
                
                //print(commandData)
                
                
                
                if commandData.isEmpty{
                    print("    volumes data is empty")
                }else{
                    
                    if let diskutilData = try (DecodeManager.decodePlistDictionaryOpt(xml: commandData) as? [String: Any]){
                        
                        //print(diskutilData)
                        
                        print("    Got drives data for the tool")
                        
                        var apfsContainers = [EFIPartitionToolTypes.VolumeStandard]()
                        var coreStorageContainers = [EFIPartitionToolTypes.VolumeStandard]()
						
						
                        
                        if let drives = diskutilData["AllDisksAndPartitions"] as? [[String: Any]]{
                            print("        Scanning disk and partitions to look for EFI partitions")
                            volumeFor: for volumes in drives{
                                
                                var isEFI = false
                                
                                var drive = ""
                                
                                if let id = volumes["DeviceIdentifier"] as? String{
                                    drive = id
                                    print("            Scanning the disk: \(id)")
                                }else{
                                    print("            This disk desn't have a device identifier, it will be skipped ...")
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
                                            print("                    This partition does not have a device identifier, it will be skipped ...")
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
                                                    
                                                    
                                                    if FileManager.default.fileExists(atPath: mp! + EFIPartitionToolTypes.cloverConfigLocation) || FileManager.default.fileExists(atPath: mp! + EFIPartitionToolTypes.openCoreConfigLocation){
                                                        print("                      This EFI Partition has a clover config file")
                                                        tempResult.hasConfig = true
                                                    }
                                                    
                                                }else{
                                                    print("                    This EFI partition is not mounted")
                                                }
                                                
                                                print("------------Getting info about this drive, because it has an EFI partition")
                                                
                                                tempResult.bsdName = partition
												
                                                var removable: Bool!
                                                
                                                if #available(OSX 10.12, *){
                                                    removable = dm.getDevicePropertyInfoBoolNew(drive, propertyName: "RemovableMediaOrExternalDevice")
                                                }else{
													removable = dm.getDevicePropertyInfoBoolNew(drive, propertyName: "Ejectable")
                                                }
												
												if let name = dm.getDriveName(from: drive){
													tempResult.displayName = name
												}else{
													continue volumeFor
												}
                                                
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
                                    
                                    print("                Scanning all the volumes of this virtual disk")
                                    
                                    var container = ""
                                    
                                    var source = [EFIPartitionToolTypes.VolumeStandard]()
                                    
                                    if isContainer{
                                        source = coreStorageContainers
                                    }else{
                                        source = apfsContainers
                                    }
									
                                    if !source.isEmpty{
										
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
                                    }else{
                                        print("                No source container partitions detected for this virtual drive")
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
                            
                            
                        }else{
                            print("    Wrong disks data!!!")
                            
                        }
                        
                        
                    }else{
                        print("    Wrong diskutil data!!!")
                        
                    }
                    
                }
                    
                
                
            }catch let err{
                print("partitions listing error: \(err)")
                
            }
            
            response(result)
        }
        
    }
	
	private func addPartition(item: inout EFIPartitionToolTypes.EFIPartitionStandard, array: [String: Any]) -> Bool{
		
		print("                    Adding a partition to the partitions list of: \(item.displayName)")
		
		var tempPartition = EFIPartitionToolTypes.PartitionStandard()
		
		var mount = ""
		
		if let mp = array["MountPoint"] as? String{
			print("                        Partiton mount point is: \(mp)")
			
			mount = mp
			
			tempPartition.drivePartIcon = NSWorkspace.shared().icon(forFile: mp)
			
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
