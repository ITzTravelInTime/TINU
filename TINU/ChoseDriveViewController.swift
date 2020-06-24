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

fileprivate let apfs = "Apple_APFS"
fileprivate let hfs = "Apple_HFS"
fileprivate let core = "Apple_CoreStorage"
fileprivate let efi = "EFI"

fileprivate let ignore = ["Apple_Boot", "Apple_KernelCoreDump"]

class ChoseDriveViewController: ShadowViewController {
    @IBOutlet weak var scoller: NSScrollView!
    @IBOutlet weak var ok: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
	
	private var itemOriginY: CGFloat = 0
	
	private let spacerID = "spacer"
	
    private var empty: Bool = false{
        didSet{
            if self.empty{
                scoller.drawsBackground = false
                scoller.borderType = .noBorder
                ok.title = "Quit"
                ok.isEnabled = true
            }else{
                //viewDidSetVibrantLook()
				
				if let document = scoller.documentView{
					if document.identifier == spacerID{
						document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
						if let content = document.subviews.first{
							content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
						}
						self.scoller.documentView = document
					}
				}
				
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
    
    
    /*override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        if let document = scoller.documentView{
            if document.identifier == "spacer"{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
    }*/
    
    @IBAction func refresh(_ sender: Any) {
        updateDrives()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: "Choose the Drive or the Partition to turn into a macOS Installer")
		self.showTitleLabel()
		
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
            titleLabel.stringValue = "Choose a drive or a partition to install macOS on"
        }
        
        updateDrives()
    }
	
	func makeAndDisplayItem(_ item: DiskutilObject, _ to: inout [DriveView], _ origin: DiskutilObject! = nil, _ isGUIDwEFI: Bool = true){
		
		let d = (origin == nil) ? item : origin!
		let man = FileManager.default
		
		DispatchQueue.main.sync {
			
			let drivei = DriveView(frame: NSRect(x: 0, y: itemOriginY, width: DriveView.itemSize.width, height: DriveView.itemSize.height))
			
			drivei.isApp = false
			
			if item.isMounted(){
				drivei.image.image = NSWorkspace.shared().icon(forFile: item.MountPoint!)
			}
			
			if !isGUIDwEFI{
				drivei.volume.stringValue = dm.getDriveName(from: d.DeviceIdentifier)
			}else{
				drivei.volume.stringValue = man.displayName(atPath: d.MountPoint!)
			}
			
			log("        Drive display name is: \(drivei.volume.stringValue)")
			
			var prt: Part!
			
			if isGUIDwEFI{
				prt = Part(partitionBSDName: d.DeviceIdentifier, partitionName: drivei.volume.stringValue, partitionPath: d.MountPoint!, partitionFileSystem: Part.FileSystem.other, partitionScheme: Part.PartScheme.gUID , partitionHasEFI: true, partitionSize: d.Size)
			}else{
				print(item)
				print(d)
				prt = Part(partitionBSDName: item.DeviceIdentifier, partitionName: drivei.volume.stringValue, partitionPath: item.MountPoint!, partitionFileSystem: .other, partitionScheme: .blank, partitionHasEFI: false, partitionSize: d.Size)
				prt.apfsBDSName = d.DeviceIdentifier
			}
			
			drivei.part = prt
			to.append(drivei)
			
		}
	}
    
    private func updateDrives(){
		
		print("--- Detectin usable drives and volumes")
		
        self.scoller.isHidden = true
        self.spinner.isHidden = false
        self.spinner.startAnimation(self)
		
		scoller.documentView = NSView()
		
		print("Preparation for detection started")
        
        ok.isEnabled = false
        
        self.hideFailureImage()
		self.hideFailureLabel()
		self.hideFailureButtons()
		
		//let man = FileManager.default
		
		cvm.shared.sharedDoTimeMachineWarn = false
        
        //sharedVolumeNeedsFormat = nil
        cvm.shared.sharedVolumeNeedsPartitionMethodChange = nil
		
		cvm.shared.currentPart = nil
        
        var drives = [DriveView]()
        
        self.ok.isEnabled = false
		
		itemOriginY = ((self.scoller.frame.height - 17) / 2) - (DriveView.itemSize.height / 2)
		
		print("Preparation for detection finished")
		
        //this code just does interpretation of the diskutil list -plist command
        DispatchQueue.global(qos: .background).async {
			
			print("Actual detection thread started")
            
            //just need to know which is the boot volume, to not allow the user to choose it
			let boot = dm.getDeviceBSDIDFromMountPoint("/")!
			var boot_drive = [dm.getDriveBSDIDFromVolumeBSDID(volumeID: boot)]
			
			print("Boot volume BSDID: \(boot)")
			
			//new Codable-Based storage devices search
			if let data = DiskutilManagement.DiskutilList.readFromTerminal(){
				log("Analyzing diskutil data to detect usable storage devices")
				
				for d in data.AllDisksAndPartitions{
					if d.DeviceIdentifier == boot_drive.first!{
						if let stores = d.APFSPhysicalStores{
							for s in stores {
								boot_drive.append(dm.getDriveBSDIDFromVolumeBSDID(volumeID: s.DeviceIdentifier))
							}
						}
					}
				}
				
				print(boot_drive)
				
				for d in data.AllDisksAndPartitions{
					log("    Drive: \(d.DeviceIdentifier)")
					
					if boot_drive.contains(d.DeviceIdentifier){
						log("        Skipping this drive, it's the boot drive or in the boot drive")
						continue
					}
					
					if d.hasEFIPartition(){ // <=> has and efi partition and has some sort of GPT or GUID partition table
						log("        Drive has EFI partition and is GUID")
						log("        All the partitions of the drive will be scanned in order to detect the usable partitions")
						for p in d.Partitions!{
							log("        Partition/Volume: \(p.DeviceIdentifier)")
							let t = p.getUsableType()
							
							log("            Partition/Volume content: \( t == DiskutilManagement.PartitionContentStrings.unusable ? "Other file system" : t.rawValue )")
							
							if t == .aPFSContainer || t == .coreStorageContainer{
								log("            Partition is a container disk")
								continue
							}
							
							if !self.checkDriveSizeUint(bytes: p.Size){
								log("            Partition is not big enought to be used as a mac os installer or to house a macOS installation")
								continue
							}
							
							if !p.isMounted(){
								log("            Partition is not mounted, it needs to be mounted in order to be detected and usable with what we need to do later on")
								continue
							}
							
							log("            Partition meets all the requirements, it will be added to the dectected partitions list")
							
							self.makeAndDisplayItem(p, &drives)
							
							log("            Partition added to the list")
						}
					}else{
						log("        Drive is not GPT/GUID or doesn't seem to have an EFI partition, it will be detected only as a drive instead of showing the partitions as well")
					}
					
					if !self.checkDriveSizeUint(bytes: d.Size){
						log("        Drive is not big enought for our purposes")
						continue
					}
					
					var ref: DiskutilObject!
					
					if d.isVolume(){
						if d.isMounted(){
							ref = d
						}
					}else{
						
						for p in d.Partitions!{
							if p.isMounted(){
								ref = p
								break
							}
						}
						
					}
					
					if ref == nil{
						log("        Drive has no mounted partitions, those are needed in order to detect a drive")
						continue
					}
					
					log("        Drive seems to meet all the requirements for our purposes, it will be added to the list")
					
					self.makeAndDisplayItem(ref, &drives, d, false)
					
					log("        Drive added to list")
					
					
				}
			}
			
			DispatchQueue.main.sync {
				
				self.scoller.hasVerticalScroller = false
				
				var res = (drives.count == 0)
				
				//this is just to test if there are no usable drives
				if simulateNoUsableDrives {
					res = true
				}
				
				self.empty = res
				
				
				let set = res || sharedIsOnRecovery
				self.topView.isHidden = set
				self.bottomView.isHidden = set
				
				self.leftView.isHidden = set
				self.rightView.isHidden = set
				
				if res{
					//fail :(
					self.scoller.isHidden = true
					
					if self.failureLabel == nil || self.failureImageView == nil || self.failureButtons.isEmpty{
						self.setFailureImage(image: IconsManager.shared.warningIcon)
						self.setFailureLabel(text: "No usable storage devices detected")
						self.addFailureButton(buttonTitle: "Why is my storage device not detected?", target: self, selector: #selector(ChoseDriveViewController.openDetectStorageSuggestions))
					}
					
					self.showFailureImage()
					self.showFailureLabel()
					self.showFailureButtons()
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
	
	func openDetectStorageSuggestions(){
		self.presentViewControllerAsSheet(sharedStoryboard.instantiateController(withIdentifier: "DriveDetectionInfoVC") as! NSViewController)
	}
	
	@IBAction func goBack(_ sender: Any) {
		if sharedShowLicense{
			let _ = sawpCurrentViewController(with: "License", sender: self)
		}else{
			let _ = sawpCurrentViewController(with: "Info", sender: self)
		}
	}
	
	@IBAction func next(_ sender: Any) {
		if !empty{
			
			let dname = dm.getCurrentDriveName()!
			
			if cvm.shared.sharedVolumeNeedsPartitionMethodChange != nil /*&& sharedVolumeNeedsFormat != nil*/{
				
				var dialogText = "The drive \"\(dname)\" will be formatted entirely to be used to create a bootable macOS installer"
				
				if cvm.shared.currentPart.apfsBDSName != nil{
					dialogText = "The drive \"\(dname)\" will be formatted entirely to be used to create a bootable macOS installer"
				}
				
				if sharedInstallMac{
					dialogText = "The drive \"\(dname)\" will be formatted entirely to install macOS on it"
				}
				
				if cvm.shared.sharedVolumeNeedsPartitionMethodChange{
					if !dialogCriticalWarning(question: "Format \"\(dname)\"?", text: dialogText, proceedButtonText: "Erase", cancelButtonText: "Don't Erase"){
						//if !dialogCustomWarning(question: "Format \"\(dname)\"?", text: dialogText, style: .warning, mainButtonText: "Don't format", secondButtonText: "Format"){
						return
					}
				}
			}
			
			if cvm.shared.sharedDoTimeMachineWarn{
				let pname = cvm.shared.currentPart.name
				if !dialogCriticalWarning(question: "Format \"\(pname)\"?", text: "The partition \"\(pname)\" is used for Time Machine backups, and may contain your backed up files. Your backups will be lost if you use it!", proceedButtonText: "Erase", cancelButtonText: "Don't Erase"){
					//if !dialogCustomWarning(question: "Format \"\(pname)\"?", text: "The partition \"\(pname)\" is used for time machine backups, and may contain usefoul backup data, that will be lost if you use it", style: .warning, mainButtonText: "Don't format", secondButtonText: "Format"){
					return
				}
			}
			
			let _ = sawpCurrentViewController(with: "ChoseApp", sender: self)
		}else{
			NSApplication.shared().terminate(sender)
		}
	}
	
	/*
    private func checkDriveSize(_ cc: [ArraySlice<String>], _ isDrive: Bool) -> Bool{
        var c = cc
        
        c.remove(at: c.count - 1)
        
        var sz: UInt64 = 0
        
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
            
            if let s = UInt64(n){
                sz = s
            }
        }
		
        if let n = c.last?.last{
			switch n{
			case "KB":
				sz *= get1024Pow(exp: 1)
				break
			case "MB":
				sz *= get1024Pow(exp: 2)
				break
			case "GB":
				sz *= get1024Pow(exp: 3)
				break
			case "TB":
				sz *= get1024Pow(exp: 4)
				break
			case "PB":
				sz *= get1024Pow(exp: 5)
				break
			default:
				if isDrive{
					print("     this drive has an unknown size unit, skipping this drive")
				}else{
					print("         volume size unit unkown, skipping this volume")
				}
				return false
			}
        }
        
        var minSize: UInt64 = 7 * get1024Pow(exp: 3) // 7 gb
        
        if sharedInstallMac{
            minSize = 20 * get1024Pow(exp: 3) // 20 gb
        }
        
        //if we are in a testing situation, size of the drive is not so much important
        if simulateCreateinstallmediaFail != nil{
            minSize = get1024Pow(exp: 3) // 1 gb
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
	
	private func get1024Pow(exp: Float) -> UInt64{
		return UInt64(pow(1024.0, exp))
	}*/
    
    func checkDriveSizeUint(bytes: UInt64) -> Bool{
        let gb = UInt64(pow(10.0, 9.0))
		
        if sharedInstallMac{
            return !(bytes <= (20 * gb)) //20 gb
        }
		
        if simulateCreateinstallmediaFail != nil{
            return !(bytes <= (2 * gb)) // 2 gb
        }
        
        return !(bytes <= (8 * gb)) // 8 gb
    }
    
}
