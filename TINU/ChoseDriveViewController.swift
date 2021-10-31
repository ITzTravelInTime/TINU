/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa

class ChoseDriveViewController: ShadowViewController, ViewID {
	let id: String = "ChoseDriveViewController"
	
    @IBOutlet weak var scoller: HorizontalScrollview!
    @IBOutlet weak var ok: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
	
	private var itemOriginY: CGFloat = 0
	
	private let spacerID = "spacer"
	
	private var empty: Bool = false{
		didSet{
			if self.empty{
				scoller.drawsBackground = false
				scoller.borderType = .noBorder
				ok.title = TextManager.getViewString(context: self, stringID: "nextButtonFail")
				ok.image = NSImage(named: NSImage.stopProgressTemplateName)
				ok.isEnabled = true
				return
			}
			
			//viewDidSetVibrantLook()
			
			if let document = scoller.documentView{
				if document.identifier?.rawValue == spacerID{
					document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
					if let content = document.subviews.first{
						content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
					}
					self.scoller.documentView = document
				}
			}
			
			ok.title = TextManager.getViewString(context: self, stringID: "nextButton")
			ok.image = NSImage(named: NSImage.goRightTemplateName)
			ok.isEnabled = false
			
			if !look.isRecovery() {
				scoller.drawsBackground = false
				scoller.borderType = .noBorder
			}else{
				scoller.drawsBackground = true
				scoller.borderType = .bezelBorder
			}
			
		}
	}
    
    @IBAction func refresh(_ sender: Any) {
        updateDrives()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		//"Choose the Drive or the Partition to turn into a macOS Installer"
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
		self.showTitleLabel()
		
		ok.title = TextManager.getViewString(context: self, stringID: "nextButton")
		
		if !look.isRecovery(){
			scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
			scoller.drawsBackground = false
			scoller.borderType = .noBorder
		}else{
			scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
			scoller.drawsBackground = true
			scoller.borderType = .bezelBorder
		}
		
		/*
        if sharedInstallMac{
            titleLabel.stringValue = "Choose a drive or a partition to install macOS on"
        }*/
        
		self.scoller.scrollerStyle = .legacy
		
        updateDrives()
    }
	
	func makeAndDisplayItem(_ item: CreationProcess.DiskInfo.DriveListItem, _ to: inout [DriveView]){
		
		let man = FileManager.default
		
		DispatchQueue.main.sync {
			
			if item.partition != nil{
				let d = item.partition!
				
				let drivei = DriveView(frame: NSRect(x: 0, y: itemOriginY, width: DriveView.itemSize.width, height: DriveView.itemSize.height))
				
				drivei.isEnabled = (item.state == .ok)
				
				let prt = Part(bsdName: d.DeviceIdentifier, fileSystem: .other, isGUID: true, hasEFI: true, size: d.Size, isDrive: false, path: d.mountPoint, support: item.state)
				
				prt.tmDisk = man.fileExists(atPath: d.mountPoint! + "/tmbootpicker.efi") || man.directoryExistsAtPath(d.mountPoint! + "/Backups.backupdb")
				
				log("        Item type: \(prt.isDrive ? "Drive" : "Partition")")
				log("        Item display name is: \(prt.displayName)")
				
				drivei.current = prt as UIRepresentable
				to.append(drivei)
				
				return
			}
			
			let d = item.disk
			
			let drivei = DriveView(frame: NSRect(x: 0, y: itemOriginY, width: DriveView.itemSize.width, height: DriveView.itemSize.height))
			
			drivei.isEnabled = (item.state == .ok)
			
			let prt = Part(bsdName: d.DeviceIdentifier.driveID, fileSystem: .other, isGUID: d.content == .gUID, hasEFI: d.hasEFIPartition(), size: d.Size, isDrive: true, path: d.mountPoint, support: item.state)
			
			prt.apfsBDSName = d.DeviceIdentifier
			
			log("        Item type: \(prt.isDrive ? "Drive" : "Partition")")
			log("        Item display name is: \(prt.displayName)")
			
			drivei.current = prt as UIRepresentable
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
		
		//Re-initialize the current disk
		cvm.shared.disk = cvm.DiskInfo(reference: cvm.shared.disk.ref)
        
        self.ok.isEnabled = false
		
		itemOriginY = ((self.scoller.frame.height - 17) / 2) - (DriveView.itemSize.height / 2)
		
		print("Preparation for detection finished")
		
        //this code just does interpretation of the diskutil list -plist command
        DispatchQueue.global(qos: .background).async {
			
			print("Actual detection thread started")
			
			var drives = [DriveView]()
            
			/*
			for item in cvm.shared.disk.getUsableDriveListNew() ?? []{
				self.makeAndDisplayItem(item, &drives)
			}
			*/
			
			for item in cvm.shared.disk.getUsableDriveListAll() ?? []{
				self.makeAndDisplayItem(item, &drives)
			}
			
			DispatchQueue.main.sync {
				
				self.scoller.hasVerticalScroller = false
				
				let res = simulateNoUsableDrives ? true : (drives.count == 0)
				
				self.empty = res
				
				let set = res || Recovery.status
				self.topView.isHidden = set
				self.bottomView.isHidden = set
				
				self.leftView.isHidden = set
				self.rightView.isHidden = set
				
				if res{
					//fail :(
					self.scoller.isHidden = true
					
					if self.failureLabel == nil || self.failureImageView == nil || self.failureButtons.isEmpty{
						self.defaultFailureImage()
						//TextManager.getViewString(context: self, stringID: "agreeButtonFail")
						
						self.setFailureLabel(text: TextManager.getViewString(context: self, stringID: "failureText"))
						self.addFailureButton(buttonTitle: TextManager.getViewString(context: self, stringID: "failureButton"), target: self, selector: #selector(ChoseDriveViewController.openDetectStorageSuggestions), image: NSImage(named: NSImage.infoName))
					}
					
					self.showFailureImage()
					self.showFailureLabel()
					self.showFailureButtons()
				}else{
					let content = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: self.scoller.frame.size.height - 17))
					content.backgroundColor = NSColor.transparent
					
					self.scoller.hasHorizontalScroller = true
					
					var temp: CGFloat = 20
					for d in drives{
						d.frame.origin.x = temp
						
						temp += d.frame.width + (( look != .recovery ) ? 15 : 0)
						
						content.addSubview(d)
						d.draw(d.bounds)
					}
					
					content.frame.size.width = temp + ((look != .recovery) ? 5 : 20)
					
					//TODO: this is not ok for resizable windows
					if content.frame.size.width < self.scoller.frame.width{
						let spacer = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2))
						spacer.backgroundColor = NSColor.transparent
						
						spacer.identifier = NSUserInterfaceItemIdentifier(rawValue: self.spacerID)
						
						content.frame.origin = NSPoint(x: spacer.frame.width / 2 - content.frame.width / 2, y: 15 / 2)
						spacer.addSubview(content)
						self.scoller.documentView = spacer
						spacer.draw(spacer.bounds)
					}else{
						self.scoller.documentView = content
						content.draw(content.bounds)
					}
					
					if let documentView = self.scoller.documentView{
						documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
						self.scoller.automaticallyAdjustsContentInsets = true
					}
					
					self.scoller.usesPredominantAxisScrolling = true
				}
				
				self.scoller.isHidden = false
				self.spinner.isHidden = true
				self.spinner.stopAnimation(self)
				
			}
		}
	}
	
	
	
	private var tmpWin: GenericViewController!
	@objc func openDetectStorageSuggestions(){
		//tmpWin = nil
		tmpWin = UIManager.shared.storyboard.instantiateController(withIdentifier: "DriveDetectionInfoVC") as? GenericViewController
		
		if tmpWin != nil{
			self.presentAsSheet(tmpWin)
		}
	}
	
	@IBAction func goBack(_ sender: Any) {
		if UIManager.shared.showLicense{
			let _ = swapCurrentViewController("License")
		}else{
			let _ = swapCurrentViewController("Info")
		}
		tmpWin = nil
	}
	
	@IBAction func next(_ sender: Any) {
		if !empty{
			
			let parseList = ["{diskName}" : cvm.shared.disk.current.driveName, "{partitionName}" : cvm.shared.disk.current.displayName]
				
			if cvm.shared.disk.warnForTimeMachine{
				if !dialogGenericWithManagerBool(self, name: "formatDialogTimeMachine", parseList: parseList){
					return
				}
			}
			
			if cvm.shared.disk.shouldErase{
				if !dialogGenericWithManagerBool(self, name: "formatDialog", parseList: parseList){
					return
				}
			}
			
			tmpWin = nil
			
			let _ = swapCurrentViewController("ChoseApp")
		}else{
			NSApplication.shared.terminate(sender)
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
    
}
