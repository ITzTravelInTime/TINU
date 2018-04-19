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
            }
        }
    }
    
    
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        if canUseVibrantLook || self.empty {
            scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
            scoller.drawsBackground = false
            scoller.borderType = .noBorder
        }else{
            scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
            scoller.drawsBackground = true
            scoller.borderType = .bezelBorder
        }
        
        if let document = scoller.documentView{
            if document.identifier == "spacer"{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        updateDrives()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if sharedInstallMac{
            titleField.stringValue = "Choose a drive or a partition to install macOS on"
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
        
        sharedVolume = nil
        sharedBSDDrive = nil
        sharedBSDDriveAPFS = nil
        
        //sharedVolumeNeedsFormat = nil
        sharedVolumeNeedsPartitionMethodChange = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        self.ok.isEnabled = false
        
        //this code just does the parsing of the diskutil list command
        DispatchQueue.global(qos: .userInitiated).async {
            
            var drvs = [Part]()
            var currentDrv: Part!
            
            var otherFS = "Apple_HFS"
            
            if #available(OSX 10.13, *){
                print("We are on High Sierra or a more recent version of mac, let's activate APFS support")
                otherFS = "Apple_APFS"
            }
            
            let h = (self.scoller.frame.height) / 2 - 80
            
            //just need to know which is the boot volume, to not allow the user to choose it
            let boot = getDeviceBSDIDFromMountPoint("/")!//getOut(cmd: "/usr/sbin/bless --info --getBoot")
            
            if !simulateDrivePlistDect{
                
                //let output = getOut(cmd: "diskutil list").components(separatedBy: "\n")
                let (output, _, _) = runCommand(cmd: "/bin/sh", args: ["-c", "diskutil list"])
                
                //print(output)
                //print(error)
                //print(status)
                
                //let time = Date()
                
                
                
                for i in output{
                    var c = i.components(separatedBy: CharacterSet.whitespacesAndNewlines).split(separator: "")
                    //print(c)
                    if !c.isEmpty{
                        if let d = c.first?.first{
                            if d.contains("/dev/disk"){
                                currentDrv = Part()
                                print("Scanning new drive")
                                continue
                            }
                        }
                        c.removeFirst()
                        
                        if let f = c.first?.first{
                            
                            switch f{
                            case "TYPE", "":
                                continue
                            case "Apple_Boot", "Apple_CoreStorage", "Apple_partition_map" /*,"Linux", "Linux_Swap"*/:
                                print("         volume not usable")
                                continue
                            case guid:
                                print("     this drive is guid")
                                currentDrv.partScheme = f
                            case mbr, applePS:
                                currentDrv.partScheme = f
                                print("     this drive is not guid: " + f)
                                if !self.checkDriveSize(c, true){
                                    currentDrv.partScheme = ""
                                    continue
                                }
                            case "EFI":
                                if c.first?.count == 2{
                                    if c.first?.last == "EFI"{
                                        currentDrv.hasEFI = true
                                        print("     this drive has an efi partition")
                                    }else{
                                        currentDrv.hasEFI = false
                                        print("     invalid efi partition")
                                    }
                                }
                            default:
                                if currentDrv.partScheme.isEmpty{
                                    print("     this drive is not usable")
                                    continue
                                }else if currentDrv.partScheme == guid{
                                    if !self.checkDriveSize(c, false) {
                                        continue
                                    }
                                }
                                
                                /*if !currentDrv.hasEFI{
                                 print("         Volume skypped because of a wrong or missing EFI partition")
                                 continue
                                 }*/
                                
                                var bsd = ""
                                
                                if let b = (c.last?.last){
                                    bsd = b
                                }else{
                                    print("         impossible to get the correct BSD name for the volume")
                                }
                                
                                print("         volume BSD name is: " + bsd)
                                
                                if boot == "/dev/" + bsd{
                                    print("         the volume is the boot volume, it will not be added")
                                    continue
                                }
                                
                                print("     this volume will be added:")
                                
                                let drv = currentDrv.copy()
                                
                                drv.bsdName += bsd
                                
                                
                                switch f{
                                case "Apple_HFS":
                                    drv.fileSystem = "HFS+"
                                    print("         volume File System is HFS")
                                case otherFS:
                                    drv.fileSystem = otherFS
                                    print("         volume File System is APFS")
                                default:
                                    drv.fileSystem = "Other"
                                    if sharedInstallMac{
                                        print("         volume File System is not HFS+ or APFS, it needs to be formatted to be used to install macOS on it")
                                    }else{
                                        print("         volume File System is not HFS+ or APFS")
                                    }
                                }
                                
                                c.remove(at: c.count - 1)
                                
                                if c.count == 1{
                                    var d = c.first!
                                    c.removeFirst()
                                    d.removeFirst()
                                    d.removeLast()
                                    d.removeLast()
                                    c.append(d)
                                }else{
                                    c.removeLast()
                                    var d = c.first!
                                    c.removeFirst()
                                    d.removeFirst()
                                    c.append(d)
                                }
                                
                                if let cc = c.first{
                                    for ccc in cc{
                                        
                                        drv.name += ccc + " "
                                    }
                                    if !drv.name.isEmpty{
                                        drv.name.characters.removeLast(1)
                                    }else{
                                        continue
                                    }
                                }
                                
                                
                                drv.path += drv.name
                                
                                if drv.name.contains("...") || !FileManager.default.fileExists(atPath: drv.path){
                                    print("         volume needs a fix for it's name")
                                    if let path = getDriveNameFromBSDID(drv.bsdName){
                                        drv.path = path
                                        drv.name = FileManager.default.displayName(atPath: path)
                                    }
                                }
                                
                                print("         volume name is " + drv.name)
                                
                                let drive = DriveObject(frame: NSRect(x: 0, y: h, width: itmSz.width, height: itmSz.height))
                                drive.isApp = false
                                drive.volumePath = drv.path
                                drive.image.image = NSWorkspace.shared().icon(forFile: drv.path)//NSImage(named: "logo.png")
                                drive.volume.stringValue = drv.name
                                drive.volumeBSD = drv.bsdName
                                drive.part = drv
                                
                                drives.append(drive)
                                drvs.append(drv)
                            }
                            
                            /*
                             if f == "TYPE" || f.isEmpty {
                             continue
                             }else if f == "Apple_Boot" || f == "Apple_CoreStorage" || f == "Apple_partition_map" /*|| f == "Linux" || f == "Linux_Swap"*/{
                             print("         volume not usable")
                             continue
                             }else if f == guid{
                             currentDrv.partScheme = guid
                             print("     this drive is guid")
                             }else if f == mbr || f == applePS{
                             currentDrv.partScheme = f
                             print("     this drive is not guid: " + f)
                             
                             if !self.checkDriveSize(c, true){
                             currentDrv.partScheme = ""
                             continue
                             }
                             }else if f == "EFI"{
                             if c.first?.count == 2{
                             var cc = c.first!
                             cc.remove(at: cc.startIndex)
                             if cc.first == "EFI"{
                             currentDrv.hasEFI = true
                             print("     this drive has an efi partition")
                             }
                             }
                             }else{
                             if currentDrv.partScheme.isEmpty{
                             print("     this drive is not usable")
                             continue
                             }else if currentDrv.partScheme == guid{
                             if !self.checkDriveSize(c, false) {
                             continue
                             }
                             }
                             
                             let drv = currentDrv.copy()
                             
                             drv.bsdName += (c.last?.last)!
                             print("         volume BSD name is: " + drv.bsdName)
                             
                             print("     this volume will be added:")
                             if f == "Apple_HFS"{
                             drv.fileSystem = "HFS+"
                             print("         volume File System is HFS")
                             }else if f == otherFS{
                             drv.fileSystem = otherFS
                             print("         volume File System is APFS")
                             }else{
                             drv.fileSystem = "Other"
                             print("         volume File System is not HFS+ or APFS")
                             }
                             
                             
                             c.remove(at: c.count - 1)
                             
                             if c.count == 1{
                             var d = c.first!
                             c.remove(at: 0)
                             d.remove(at: d.startIndex)
                             d.remove(at: d.endIndex - 1)
                             d.remove(at: d.endIndex - 1)
                             c.append(d)
                             }else{
                             c.remove(at: c.count - 1)
                             var d = c.first!
                             c.remove(at: 0)
                             d.remove(at: d.startIndex)
                             c.append(d)
                             }
                             
                             if let cc = c.first{
                             for ccc in cc{
                             
                             drv.name += ccc + " "
                             }
                             if !drv.name.isEmpty{
                             drv.name.characters.removeLast(1)
                             }else{
                             continue
                             }
                             }
                             
                             
                             drv.path += drv.name
                             
                             if drv.name.contains("...") || !FileManager.default.fileExists(atPath: drv.path){
                             print("         volume needs a fix for it's name")
                             if let path = getDriveNameFromBSDID(drv.bsdName){
                             drv.path = path
                             drv.name = FileManager.default.displayName(atPath: path)
                             }
                             }
                             
                             print("         volume name is " + drv.name)
                             
                             let drive = DriveObject(frame: NSRect(x: 0, y: (self.scoller.frame.height) / 2 - 80, width: 130, height: 150))
                             drive.isApp = false
                             drive.volumePath = drv.path
                             drive.image.image = NSWorkspace.shared().icon(forFile: drv.path)//NSImage(named: "logo.png")
                             drive.volume.stringValue = drv.name
                             drive.volumeBSD = drv.bsdName
                             drive.part = drv
                             
                             drives.append(drive)
                             drvs.append(drv)
                             
                             }*/
                        }else{
                            continue
                        }
                    }
                    
                }
                
            }else{
                do{
					print("Waiting for the drives data ...")
					
                    if let diskutilData = try (decodeXMLDictionaryOpt(xml: getOut(cmd: "diskutil list -plist")) as? [String: Any]){
						
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
						
						var bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: boot)
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
												cdrv = originalContainers[originalContainersCont]
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
														bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
														
														isOnBoot = true
													}
													
													let bd = getDriveBSDIDFromVolumeBSDID(volumeID: boot)
													let cd = getDriveBSDIDFromVolumeBSDID(volumeID: (drv?.bsdName)!)
													let vd = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
													
													if cd == bootDiskContainer || vd == bootDiskContainer || cd == bd || vd == bd{
														print("                 This volume is on the boot drive and can't be used")
														isOnBoot = true
													}
													
													if isOnBoot{
														if !drives.isEmpty{
															var removed = 0
															var count = 0
															for d in drives{
																let dd = getDriveBSDIDFromVolumeBSDID(volumeID: d.volumeBSD)
																if dd == cd{
																	print("                 removing \"\(d.volume.stringValue)\" from usable drives list because it's in the boot drive")
																	
																	drives.remove(at: count - removed)
																	removed += 1
																}
																
																count += 1
															}
															
															print("     This drive is not usable for an install media or to install mac os on")
															continue
														}
													}
												}
												
                                                drv?.apfsBDSName = idp
                                                
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
														}else if p == ""{
															print("                 Partition needs to get a proper mount point")
															shouldCorrectName =  true
														}
													
													let mo = URL(fileURLWithPath: p, isDirectory: true).pathComponents[1]
													
													if mo != "Volumes"{
															print("                 Invalid mount point: \(p)")
														continue
													}
													
                                                    drv?.path = p
                                                    print("             Partition mount point: " + (drv?.path)!)
                                                    
                                                }else{
                                                    print("             Partition mount point needs to be correct")
                                                    shouldCorrectName = true
                                                }
                                                
                                                if shouldCorrectName{
                                                    print("             Partition needs a fix for it's name")
                                                    if let path = getDriveNameFromBSDID((drv?.apfsBDSName!)!){
														
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
                                                
                                                let drivei = DriveObject(frame: NSRect(x: 0, y: h, width: itmSz.width, height: itmSz.height))
                                                drivei.isApp = false
                                                drivei.volumePath = (drv?.path)!
                                                drivei.image.image = NSWorkspace.shared().icon(forFile: (drv?.path)!)//NSImage(named: "logo.png")
                                                drivei.volume.stringValue = (drv?.name)!
                                                drivei.volumeBSD = (drv?.bsdName)!
                                                drivei.part = drv
                                                
                                                drives.append(drivei)
                                                
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
												
												//if is the boot partition
												if "/dev/" + idp == boot{
													bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
													print("             Boot partition can't be used")
													continue
												}
												
												//if is on the same drive as the boot partition
												
												let vd = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
												
												if vd == bootDiskContainer{
													print("                 This volume is on the boot drive and can't be used")
													continue
												}
												
											}
											
                                            if let cont = partition["Content"] as? String{
                                                switch cont{
                                                case "EFI":
                                                    if let name = partition["VolumeName"] as? String{
                                                        if name == "EFI" && String(describing: idp.characters.last!) == "1"{
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
													
													drv.bsdName += idp
													
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
															bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
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
                                                        print("             Partition mount point: " + drv.path)
                                                        
                                                    }else{
                                                        print("             Partition mount point needs to be correct")
                                                        shouldCorrectName = true
                                                    }
                                                    
                                                    if shouldCorrectName{
                                                        print("             Partition needs a fix for it's name")
                                                        if let path = getDriveNameFromBSDID(drv.bsdName){
															
															if path == "/"{
																bootDiskContainer = getDriveBSDIDFromVolumeBSDID(volumeID: idp)
																print("                 Partition is mounted as / , it can't be used")
																continue
															}
															
															let mo = URL(fileURLWithPath: path, isDirectory: true).pathComponents[1]
															
															if mo != "Volumes"{
																print("             Invalid mount point: \(path)")
																continue
															}
															
                                                            drv.path = path
                                                            print("             Correct name of the partition: " + drv.path)
                                                            drv.name = FileManager.default.displayName(atPath: path)
                                                            print("             Correct mount point of the partition: " + drv.path)
                                                        }else{
                                                            print("             Impossible to get the correct name and mountpoint for the partition")
                                                            continue
                                                        }
                                                    }
                                                    
                                                    let drivei = DriveObject(frame: NSRect(x: 0, y: h, width: itmSz.width, height: itmSz.height))
                                                    drivei.isApp = false
                                                    drivei.volumePath = drv.path
                                                    drivei.image.image = NSWorkspace.shared().icon(forFile: drv.path)//NSImage(named: "logo.png")
                                                    drivei.volume.stringValue = drv.name
                                                    drivei.volumeBSD = drv.bsdName
                                                    drivei.part = drv
                                                    
                                                    drives.append(drivei)
                                                    drvs.append(drv)
                                                    
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
            }
            
            
            
            //print(Date().timeIntervalSince(time))
            
            DispatchQueue.main.sync {
                
                self.scoller.hasVerticalScroller = false
                
                var res = (drives.count == 0)
                
                //this is just to test if there are no usable drives
                if simulateNoUsableDrives {
                    res = true
                }
                
                self.empty = res
                
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
                    
                    self.errorImage.image = warningIcon
					
					self.detectInfoButton.isHidden = false
                    
                }else{
                    let content = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: self.scoller.frame.size.height - 2 - 20))
                    content.backgroundColor = NSColor.white.withAlphaComponent(0)
                    
                    
                    self.scoller.hasHorizontalScroller = true
                    
                    var temp: CGFloat = 10
                    for d in drives.reversed(){
                        d.frame.origin.x = temp
                        temp += d.frame.width
                        content.addSubview(d)
                    }
                    content.frame.size.width = temp + 10
                    
                    if content.frame.size.width < self.scoller.frame.width{
                        let spacer = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2))
                        spacer.backgroundColor = NSColor.white.withAlphaComponent(0)
                        spacer.identifier = "spacer"
                        content.frame.origin = NSPoint(x: spacer.frame.width / 2 - content.frame.width / 2, y: 0)
                        spacer.addSubview(content)
                        self.scoller.documentView = spacer
                    }else{
                        self.scoller.documentView = content
                    }
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
            if sharedVolumeNeedsPartitionMethodChange != nil /*&& sharedVolumeNeedsFormat != nil*/{
                var dialogText = "This drive does not uses the GUID partition table or a supported file system.\nTo be used to craete a macOS install media it needs to be completely erased and converted into the rigth format, do you want to format it?\n\nNote that if you choose yes, all the data on it will be lost when you start the macOS install media creation process!"
                
                if sharedInstallMac{
                    dialogText = "This drive does not uses the GUID partition table or a supported file system.\nTo install macOS on it, it needs to be completely erased and converted in the rigth format, do you want to format it?\n\nNote that if you choose yes, all the data on it will be lost when you start the macOS install media creation process!"
                }
                
                /*
                 if sharedVolumeNeedsFormat{
                 if dialogOKCancel(question: "Format the volume?", text: "This volume will be erased to be used to create a macOS install media, this will permanently erase all the data on it, do you want to continue?", style: .warning){
                 return
                 }
                 }else*/ if sharedVolumeNeedsPartitionMethodChange{
                    if dialogYesNoWarning(question: "Format the drive?", text: dialogText, style: .warning){
                        return
                    }
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
                n.characters.remove(at: n.startIndex)
            }else{
                let s = String(describing: n.characters.first)
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
                    print("     this drive has a size unit unkown, skipping this drive")
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
                print("     this volume too small for a macOS installer")
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
