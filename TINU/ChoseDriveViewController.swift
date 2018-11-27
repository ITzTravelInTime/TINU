//
//  ChoseDriveViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate let guid = "GUID_partition_scheme"
fileprivate let mbr = "FDisk_partition_scheme"
fileprivate let applePS = "Apple_partition_scheme"

class ChoseDriveViewController: GenericViewController {
    @IBOutlet weak var scoller: NSScrollView!
    @IBOutlet weak var ok: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var titleField: NSTextField!
    
    @IBOutlet weak var errorImage: NSImageView!
    
    @IBOutlet weak var errorLabel: NSTextField!
    
	@IBOutlet weak var detectInfoButton: NSButton!
	
    private var empty: Bool = false{
        didSet{
            if self.empty{
                scoller.drawsBackground = false
                scoller.borderType = .noBorder
                ok.title = "Quit"
                ok.isEnabled = true
            }else{
                viewDidSetVibrantLook()
                ok.title = "Next"
                ok.isEnabled = false
				
				if !(sharedIsOnRecovery || simulateDisableShadows){
					scoller.drawsBackground = false
					scoller.borderType = .noBorder
				}else{
					scoller.drawsBackground = true
					scoller.borderType = .bezelBorder
				}
            }
        }
    }
    
    
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        /*if canUseVibrantLook || self.empty {
            scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
            scoller.drawsBackground = false
            scoller.borderType = .noBorder
          }else{
            scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
            scoller.drawsBackground = true
            scoller.borderType = .bezelBorder
        }*/
        
        if let document = scoller.documentView{
            if document.identifier == "spacer"{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
		
		//self.empty.toggle()
		//self.empty.toggle()
    }
    
    @IBAction func refresh(_ sender: Any) {
        updateDrives()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		if !sharedIsOnRecovery && !simulateDisableShadows{
			scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
			scoller.drawsBackground = false
			scoller.borderType = .noBorder
			
			/*
			if !simulateDisableShadows{
			setShadowViewsAll(respectTo: scoller, topBottomViewsShadowRadius: 5, sideViewsShadowRadius: 3)
			setOtherViews(respectTo: scoller)
			
			self.uView.isHidden = true
			self.bView.isHidden = true
			
			self.lView.isHidden = true
			self.rView.isHidden = true
			}*/
			
		}else{
			scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
			scoller.drawsBackground = true
			scoller.borderType = .bezelBorder
		}
		
        if sharedInstallMac{
            titleField.stringValue = "Choose a partition to install macOS on"
        }
        
        updateDrives()
    }
    
    private func updateDrives(){
        self.scoller.isHidden = true
        self.spinner.isHidden = false
        self.spinner.startAnimation(self)
        
        print("--- Detectin usable drives and volumes")
        scoller.documentView = NSView()
        
        ok.isEnabled = false
        
        self.errorImage.isHidden = true
        self.errorLabel.isHidden = true
		
		self.detectInfoButton.isHidden = true
		
		let man = FileManager.default
		
		cvm.shared.sharedDoTimeMachineWarn = false
        
        //sharedVolumeNeedsFormat = nil
        cvm.shared.sharedVolumeNeedsPartitionMethodChange = nil
		
		cvm.shared.currentPart = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        self.ok.isEnabled = false
        
        //this code just does the parsing of the diskutil list command
        DispatchQueue.global(qos: .background).async {
            
            var drvs = [Part]()
            var currentDrv: Part!
            
            var otherFS = "Apple_HFS"
            
            if #available(OSX 10.13, *){
                print("We are on High Sierra or a more recent version of mac, let's activate APFS support")
                otherFS = "Apple_APFS"
            }
			var h: CGFloat = 0
			
			DispatchQueue.main.sync {
            	h = ((self.scoller.frame.height - 17) / 2) - (DriveObject.itemSize.height / 2)
			}
            
            //just need to know which is the boot volume, to not allow the user to choose it
            let boot = dm.getDeviceBSDIDFromMountPoint("/")!//getOut(cmd: "/usr/sbin/bless --info --getBoot")
			
                do{
					print("Waiting for the drives data ...")
					
                    if let diskutilData = try (PlistXMLManager.decodeXMLDictionaryOpt(xml: getOut(cmd: "diskutil list -plist")) as? [String: Any]){
						
						print("Drives data got with success")
                        
                        /*if let drivesData = diskutilData["AllDisksAndPartitions"] as? [[String: Any]]{
                         for drive in drivesData{
                         print(drive)
                         }
                         }*/
                        
                        print(diskutilData)
						
						var originalContainers = [Part]()
						var originalContainersCont = 0
						
                        var apfsDrives = [Part]()
                        var apfsDrivesCont = 0
						
						var bootDiskContainer = dm.getDriveBSDIDFromVolumeBSDID(volumeID: boot)
						//let selectedBoot = getDriveBSDIDFromVolumeBSDID(volumeID: getOut(cmd: "/usr/sbin/bless --info --getBoot"))
						
						print("Boot disks detected:")
						print(boot)
						print(bootDiskContainer)
                        
                        if let drivesData = diskutilData["AllDisksAndPartitions"] as? [[String: Any]]{
                            for drive in drivesData{
                                currentDrv = Part()
                                
                                let id = (drive["DeviceIdentifier"] as! String)
                                
                                if id.isEmpty{
                                    print("             Impossible to get the bsd id for the drive!")
                                    continue
                                }
                                
                                print("Scanning new drive: " + id)
                                
                                let size = drive["Size"] as! UInt64
                                
                                if !self.checkDriveSizeUint(bytes: size){
                                    print("     This drive is too small to be used")
                                    continue
                                }
                                
                                if let content = drive["Content"] as? String{
                                    var isGUID = false
                                    switch content{
                                    case guid:
                                        print("     This drive is GUID")
                                        currentDrv.partScheme = content
                                        isGUID = true
                                    case mbr, applePS:
                                        print("     This drive is not GUID, needs to be erased for the install media")
                                        currentDrv.partScheme = content
                                        currentDrv.totSize = Float(size)
                                    default:
										var cvolumes: [[String: Any]]?
										
										var isAPFS = true
										
										if let avolumes = drive["APFSVolumes"] as? [[String: Any]]{
											cvolumes = avolumes
										}else{
											//if sharedIsOnRecovery{
												/*if let hvolumes = drive["Apple_HFS"] as? [[String: Any]]{
												cvolumes = hvolumes
												isAPFS = false
												}*/
												
												cvolumes = [drive]
												isAPFS = false
											//}else{
											/*if !sharedIsOnRecovery{
												print("     This drive is not usable for an install media")
												
												if let tidp = drive["DeviceIdentifier"] as? String{
													if "/dev/" + tidp == boot{
														bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: originalContainers[originalContainersCont].bsdName)
													}
												}
												
												originalContainersCont += 1
											}*/
										}
										
                                        if let volumes = cvolumes{
											
											var cdrv: Part?
											
											if isAPFS{
												if apfsDrives.isEmpty{
													print("         Can't add the APFS container for this drive")
													continue
												}
												cdrv = apfsDrives[apfsDrivesCont]
												
											}else{
												if originalContainers.isEmpty{
													print("         Can't get the original disk for this drive")
													continue
												}
												
												if content == "Apple_HFS"{
													cdrv = originalContainers[originalContainersCont]
												}else{
													cdrv = currentDrv.copy()
													cdrv?.hasEFI = false
												}
											}
											
											if cdrv == nil{
												print("         Error detecting contaniner disk")
												continue
											}
											
											if isAPFS{
												cdrv?.driveType = .apfs
												print("         Scanning new APFS container: " + (cdrv?.bsdName)!)
											}else{
												cdrv?.driveType = .coreStorage
												print("         Scanning new disk container: " + (cdrv?.bsdName)!)
											}
											
                                            for volume in volumes{
                                                let drv = cdrv?.copy()
												
												
												if let sz = volume["Size"] as? UInt64{
													if sharedInstallMac{
														if !self.checkDriveSizeUint(bytes: sz){
															print("             This volume is too small to be used")
															continue
														}
													}
													drv?.size = sz
												}
												
                                                var idp = ""
												
                                                if let tidp = volume["DeviceIdentifier"] as? String{
                                                    idp = tidp
                                                }else{
                                                    print("             Impossible to get the bsd id for the partition!")
                                                    continue
                                                }
                                                
												print("             Scanning new partition: " + idp)
												
												if !sharedInstallMac{
													
													var isOnBoot = false
													
													if "/dev/" + idp == boot{
														print("                 Boot partition can't be used")
														bootDiskContainer = dm.getDriveBSDIDFromVolumeBSDID(volumeID: (drv?.bsdName)!)
														
														isOnBoot = true
													}
													
													let bd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: boot)
													let cd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: (drv?.bsdName)!)
													let vd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: idp)
													
													if cd == bootDiskContainer || vd == bootDiskContainer || cd == bd || vd == bd{
														print("                 This volume is on the boot drive and can't be used")
														isOnBoot = true
													}
													
													if isOnBoot{
														if !drives.isEmpty{
															var removed = 0
															var count = 0
															for d in drives{
																let dd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: d.part.bsdName!)
																if dd == cd{
																	DispatchQueue.main.sync {
																		print("                 removing \"\(d.volume.stringValue)\" from usable drives list because it's in the boot drive")
																	}
																	
																	drives.remove(at: count - removed)
																	removed += 1
																}
																
																count += 1
															}
															
															print("     This drive is not usable for an install media or to install mac os on")
															
														}
														
														continue
													}
												}
												
												if content == "Apple_HFS" || content == "Apple_APFS" || isAPFS{
													drv?.apfsBDSName = idp
												}else{
													drv?.bsdName = idp
												}
												
                                                var shouldCorrectName = false
                                                
                                                if let pn = volume["VolumeName"] as? String{
                                                    
                                                    if pn.isEmpty{
                                                        print("             Empty partition name, needs to be fixed")
                                                        shouldCorrectName = true
                                                    }else{
                                                        drv?.name = pn
                                                        print("             Partition name: " + pn)
                                                    }
                                                    
                                                }else{
                                                    print("             Impossible to get the volume name")
                                                    shouldCorrectName = true
                                                }
                                                
                                                if let p = volume["MountPoint"] as? String{
														if p == "/"{
															print("                 Partition is mounted as / , it can't be used")
															continue
														}else if p.isEmpty{
															print("                 Partition needs to get a proper mount point")
															shouldCorrectName =  true
														}
													
													let mo = URL(fileURLWithPath: p, isDirectory: true).pathComponents[1]
													
													if mo != "Volumes"{
															print("                 Invalid mount point: \(p)")
														continue
													}
													
                                                    drv?.path = p
                                                    print("             Partition mount point: " + p)
                                                    
                                                }else{
                                                    print("             Partition mount point needs to be correct")
                                                    shouldCorrectName = true
                                                }
                                                
                                                if shouldCorrectName{
                                                    print("             Partition needs a fix for it's name")
                                                    if let path = dm.getDriveNameFromBSDID((drv?.apfsBDSName!)!){
														
														if path == "/"{
															print("                 Partition is mounted as / , it can't be used")
															continue
														}
														
														let mo = URL(fileURLWithPath: path, isDirectory: true).pathComponents[1]
														
														if mo != "Volumes"{
															print("                 Invalid mount point: \(path)")
															continue
														}
														
                                                        drv?.path = path
                                                        print("             Correct name of the partition: " + (drv?.path)!)
                                                        drv?.name = FileManager.default.displayName(atPath: path)
                                                        print("             Correct mount point of the partition: " + (drv?.path)!)
                                                    }else{
                                                        print("             Impossible to get the correct name and mountpoint for the partition")
                                                        continue
                                                    }
                                                }
												
												if man.fileExists(atPath: (drv?.path)! + "/tmbootpicker.efi") || man.fileExists(atPath: (drv?.path)! + "/Backups.backupdb"){
													drv?.tmDisk = true
												}
												
												DispatchQueue.main.sync {
												
                                                let drivei = DriveObject(frame: NSRect(x: 0, y: h, width: DriveObject.itemSize.width, height: DriveObject.itemSize.height))
                                                drivei.isApp = false
                                                drivei.image.image = NSWorkspace.shared().icon(forFile: (drv?.path)!)//NSImage(named: "logo.png")
                                                drivei.volume.stringValue = (drv?.name)!
                                                drivei.part = drv
                                                
                                                drives.append(drivei)
													
												}
                                                
                                            }
											
											if isAPFS{
												apfsDrivesCont += 1
											}else{
												originalContainersCont += 1
											}
                                        }else{
                                            print("     Unusable drive")
                                            continue
                                        }
                                    }
                                    
                                    if let partitions = drive["Partitions"] as? [[String: Any]]{
                                        for partition in partitions{
                                            
                                            var idp = ""
                                            
                                            if let tidp = partition["DeviceIdentifier"] as? String{
                                                idp = tidp
                                            }else{
                                                print("             Impossible to get the bsd id for the partition!")
                                                continue
											}
											
											print("         Scanning new partition: " + idp)
											
											if !sharedInstallMac{
												
												
												var isOnBoot = false
												
												if "/dev/" + idp == boot{
													print("                 Boot partition can't be used")
													bootDiskContainer = dm.getDriveBSDIDFromVolumeBSDID(volumeID: idp)
													
													isOnBoot = true
												}
												
												let bd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: boot)
												let vd = dm.getDriveBSDIDFromVolumeBSDID(volumeID: idp)
												
												if vd == bootDiskContainer || vd == bd{
													print("                 This volume is on the boot drive and can't be used")
													isOnBoot = true
												}
												
												if isOnBoot{
													continue
												}
												
											}
											
                                            if let cont = partition["Content"] as? String{
                                                switch cont{
                                                case "EFI":
                                                    if let name = partition["VolumeName"] as? String{
                                                        if name == "EFI" && String(describing: idp.last!) == "1"{
                                                            currentDrv.hasEFI = true
                                                            print("             Drive does contains an EFI partition")
                                                        }else{
                                                            currentDrv.hasEFI = false
                                                            print("             EFI partition with problems, drive needs to be formatted")
                                                        }
                                                    }else{
                                                        currentDrv.hasEFI = false
                                                        print("             Error while getting EFI partition data")
                                                    }
                                                    
                                                    continue
												case "Apple_Boot", "Apple_partition_map":
                                                    print("             Unusable partition: " + idp)
                                                    continue
                                                default:
													
													let drv = currentDrv.copy()
													
													drv.bsdName = drv.bsdName! + idp
													
													if let sz = partition["Size"] as? UInt64 {
														
														if isGUID{
															if !self.checkDriveSizeUint(bytes: sz){
																print("             Partition is too small")
																continue
															}
														}
														
														drv.size = sz
													}
													
													print("             Partition bsd name: " + idp)
													
													print("             Partition file system kind: " + cont)
													
                                                    switch cont{
                                                    case "Apple_HFS":
														drv.fileSystem = "HFS+"
													case otherFS:
														if #available(OSX 10.13, *){
															drv.fileSystem = "APFS"
														
															print("             Partition is an APFS Container adding it to the APFS containers group")
															
															currentDrv.hasAPFSVolumes = true
															drv.hasAPFSVolumes = true
															
															apfsDrives.append(drv)
														}
														
														continue
													case "Apple_CoreStorage":
														
														//if sharedIsOnRecovery{
														
															drv.fileSystem = "CoreStorage"
															
															print("             Partition is a container of an apple drive")
															
															currentDrv.hasOriginalVolumes = true
															drv.hasOriginalVolumes = true
															
															originalContainers.append(drv)
															
														//}
														
														continue
                                                    default:
                                                        drv.fileSystem = "Other"
                                                    }
													
                                                    
                                                    var shouldCorrectName = false
                                                    
                                                    if let pn = partition["VolumeName"] as? String{
                                                        
                                                        if pn.isEmpty{
                                                            print("             Empty partition name, needs to be fixed")
                                                            shouldCorrectName = true
                                                        }else{
                                                            drv.name = pn
                                                            print("             Partition name: " + pn)
                                                        }
                                                        
                                                    }else{
                                                        print("             Impossible to get the volume name")
                                                        shouldCorrectName = true
                                                    }
                                                    
                                                    if let p = partition["MountPoint"] as? String{
                                                        if p == "/"{
															bootDiskContainer = dm.getDriveBSDIDFromVolumeBSDID(volumeID: idp)
															print("                 Partition is mounted as / , it can't be used")
															continue
                                                        }else if p == ""{
                                                            print("             Partition needs to get a proper mount point")
                                                            shouldCorrectName =  true
                                                        }
														
														let mo = URL(fileURLWithPath: p, isDirectory: true).pathComponents[1]
														
														if mo != "Volumes"{
															print("             Invalid mount point: \(p)")
															continue
														}
                                                        
                                                        drv.path = p
                                                        print("             Partition mount point: " + drv.path!)
                                                        
                                                    }else{
                                                        print("             Partition mount point needs to be correct")
                                                        shouldCorrectName = true
                                                    }
                                                    
                                                    if shouldCorrectName{
                                                        print("             Partition needs a fix for it's name")
                                                        if let path = dm.getDriveNameFromBSDID(drv.bsdName!){
															
															if path == "/"{
																bootDiskContainer = dm.getDriveBSDIDFromVolumeBSDID(volumeID: idp)
																print("                 Partition is mounted as / , it can't be used")
																continue
															}
															
															let mo = URL(fileURLWithPath: path, isDirectory: true).pathComponents[1]
															
															if mo != "Volumes"{
																print("             Invalid mount point: \(path)")
																continue
															}
															
                                                            drv.path = path
                                                            print("             Correct name of the partition: " + drv.path!)
                                                            drv.name = FileManager.default.displayName(atPath: path)
                                                            print("             Correct mount point of the partition: " + drv.path!)
                                                        }else{
                                                            print("             Impossible to get the correct name and mountpoint for the partition")
                                                            continue
                                                        }
                                                    }
													
													if man.fileExists(atPath: drv.path! + "/tmbootpicker.efi") || man.fileExists(atPath: drv.path! + "/Backups.backupdb"){
														drv.tmDisk = true
													}
													DispatchQueue.main.sync {
                                                    	let drivei = DriveObject(frame: NSRect(x: 0, y: h, width: DriveObject.itemSize.width, height: DriveObject.itemSize.height))
                                                    	drivei.isApp = false
                                                    	drivei.image.image = NSWorkspace.shared().icon(forFile: drv.path!)//NSImage(named: "logo.png")
                                                    	drivei.volume.stringValue = drv.name
                                                    	drivei.part = drv
                                                    
                                                    	drives.append(drivei)
                                                    	drvs.append(drv)
														
													}
                                                }
                                            }else{
                                                
                                                print("             Impossible to get partition content")
                                                continue
                                            }
                                        }
                                    }else{
                                        
                                        print("     Drive does not have partitions")
                                        continue
                                    }
                                    
                                }else{
                                    print("     Unkown drive content")
                                    continue
                                }
                            }
                        }else{
                            print("Impossible to get the drives!")
                        }
                        
					}else{
						print("Error getting drives data")
					}
                }catch{
                    print("Error: " + error.localizedDescription)
                }
			
			DispatchQueue.main.sync {
                
                self.scoller.hasVerticalScroller = false
                
                var res = (drives.count == 0)
                
                //this is just to test if there are no usable drives
                if simulateNoUsableDrives {
                    res = true
                }
                
                self.empty = res
				
				self.topView.isHidden = res || sharedIsOnRecovery
				self.bottomView.isHidden = res || sharedIsOnRecovery
				
				self.leftView.isHidden = res || sharedIsOnRecovery
				self.rightView.isHidden = res || sharedIsOnRecovery
                
                if res{
                    //fail :(
                    /*
                    print("No usable drives found!")
                    
                    self.scoller.hasHorizontalScroller = false
                    
                    let label = NSTextField()
                    label.stringValue = "No usable drives or devices found"
                    label.alignment = .center
                    label.isEditable = false
                    label.isBordered = false
                    label.drawsBackground = false
                    label.font = NSFont.systemFont(ofSize: 20)
                    label.frame.origin = CGPoint(x: 0, y: (self.scoller.frame.size.height / 2) - 15)
                    label.frame.size = NSSize(width: self.scoller.frame.width - 10, height: 30)
                    
                    content = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.size.width - 2, height: self.scoller.frame.size.height - 2))
                    content.addSubview(label)
                    
                    self.scoller.documentView = content*/
                    
                    self.scoller.isHidden = true
                    
                    self.errorImage.isHidden = false
                    self.errorLabel.isHidden = false
                    
                    self.errorImage.image = IconsManager.shared.warningIcon
					
					self.detectInfoButton.isHidden = false
                }else{
                    let content = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: self.scoller.frame.size.height - 17))
                    content.backgroundColor = NSColor.white.withAlphaComponent(0)
                    
                    self.scoller.hasHorizontalScroller = true
                    
                    var temp: CGFloat = 20
                    for d in drives.reversed(){
                        d.frame.origin.x = temp
						if !(sharedIsOnRecovery || simulateDisableShadows){
                        	temp += d.frame.width + 15
						}else{
							temp += d.frame.width
						}
                        content.addSubview(d)
                    }
					
					if !(sharedIsOnRecovery || simulateDisableShadows){
                    	content.frame.size.width = temp + 5
					}else{
						content.frame.size.width = temp + 20
					}
                    
                    if content.frame.size.width < self.scoller.frame.width{
                        let spacer = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2))
                        spacer.backgroundColor = NSColor.white.withAlphaComponent(0)
						
                        spacer.identifier = "spacer"
						
                        content.frame.origin = NSPoint(x: spacer.frame.width / 2 - content.frame.width / 2, y: 15 / 2)
                        spacer.addSubview(content)
                        self.scoller.documentView = spacer
                    }else{
                        self.scoller.documentView = content
                    }
					
					if let documentView = self.scoller.documentView{
						documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
					}
					
					self.scoller.usesPredominantAxisScrolling = true
					
                }
                
                self.scoller.isHidden = false
                self.spinner.isHidden = true
                self.spinner.stopAnimation(self)
                
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if sharedShowLicense{
            let _ = openSubstituteWindow(windowStoryboardID: "License", sender: self)
        }else{
            let _ = openSubstituteWindow(windowStoryboardID: "Info", sender: self)
        }
    }
    
    @IBAction func next(_ sender: Any) {
        if !empty{
			
			let dname = dm.getCurrentDriveName()!
			
            if cvm.shared.sharedVolumeNeedsPartitionMethodChange != nil /*&& sharedVolumeNeedsFormat != nil*/{
				
				var dialogText = "The drive \"\(dname)\" needs to be formatted entirely to be used to create a bootable macOS installer, because it does not use the GUID partition table"
                
                if sharedInstallMac{
                    dialogText = "The drive \"\(dname)\" needs to be formatted entirely to install macOS on it, because it does not use the GUID partition table"
                }
				
				if cvm.shared.sharedVolumeNeedsPartitionMethodChange{
					if !dialogCustomWarning(question: "Format \"\(dname)\"?", text: dialogText, style: .warning, mainButtonText: "Don't format", secondButtonText: "Format"){
                        return
                    }
                }
            }
			
			if cvm.shared.sharedDoTimeMachineWarn{
				let pname = cvm.shared.currentPart.name
				if !dialogCustomWarning(question: "Format \"\(pname)\"?", text: "The partition \"\(pname)\" is used for time machine backups, and may contain usefoul backup data, that will be lost if you use it", style: .warning, mainButtonText: "Don't format", secondButtonText: "Format"){
					return
				}
			}
			
            let _ = openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: self)
        }else{
            NSApplication.shared().terminate(sender)
        }
    }
    
    private func checkDriveSize(_ cc: [ArraySlice<String>], _ isDrive: Bool) -> Bool{
        var c = cc
        
        c.remove(at: c.count - 1)
        
        var sz: Float = 0
        
        if c.count == 1{
            let f: String = (c.last?.last!)!
            var cl = c.last!
            cl.remove(at: cl.index(before: cl.endIndex))
            let ff: String = cl.last!
            
            c.removeAll()
            
            c.append([ff, f])
            
        }
        
        if var n = c.last?.first{
            if isDrive{
                n.remove(at: n.startIndex)
            }else{
                let s = String(describing: n.first)
                if s == "*" || s == "+"{
                    print("         volume size is not fixed, skipping it")
                    return false
                }
            }
            
            if let s = Float(n){
                sz = s
            }
        }
        
        if let n = c.last?.last{
            if n == "KB"{
                sz /= 1024
            }else if n == "GB"{
                sz *= 1024
            }else if n == "TB"{
                sz *= 1024 * 1024
            }else if n != "MB"{
                if isDrive{
                    print("     this drive has an unknown size unit, skipping this drive")
                }else{
                    print("         volume size unit unkown, skipping this volume")
                }
                return false
            }
        }
        
        var minSize: Float = 7000
        
        if sharedInstallMac{
            minSize = 20000
        }
        
        //if we are in a testing situation, size of the drive is not so much important
        if simulateCreateinstallmediaFail != nil{
            minSize = 2000
        }
        
        if sz <= minSize{
            if isDrive{
                print("     this drive is too small to be used for a macOS installer, skipping this drive")
            }else{
                print("     this volume is too small for a macOS installer")
            }
            return false
        }
        
        return true
    }
    
    func checkDriveSizeUint(bytes: UInt64) -> Bool{
        var minSize: UInt64 = 6000000000
        
        if sharedInstallMac{
            minSize = 2 * 10000000000
        }
        
        if simulateCreateinstallmediaFail != nil{
            minSize = 5 * 100000000
        }
        
        /*
        if bytes <= minSize{
            return false
        }
        
        return true
        */
        
        return !(bytes <= minSize)
    }
    
}
