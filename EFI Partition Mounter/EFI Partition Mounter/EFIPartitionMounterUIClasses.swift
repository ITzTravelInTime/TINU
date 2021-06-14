//
//  EFIPartitionMounterUIClasses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)
public class EFIPartitionToolInterface{
	
	private static let appMenu: EFIPartitionToolTypes.ConfigMenuApps = CodableCreation<EFIPartitionToolTypes.ConfigMenuApps>.createFromDefaultFile()!
	
	public class EFIPartitionItem: ShadowView, ViewID{
		
		public let id: String = "EFIPartitionItem"
		
		public let titleLabel = NSTextField()
		
		private let placeHolderLabel = NSTextField()
		private let mountButton = NSButton()
		private let unmountButton = NSButton()
		private let editOtherConfigButton = NSButton()
		private var configOpenMenu: NSMenu = NSMenu()
		private let showInFinderButton = NSButton()
		private let ejectButton = NSButton()
		private let coverView = NSView()
		private let spinner = NSProgressIndicator()
		
		var isMounted = false
		var configType: EFIPartitionToolTypes.ConfigLocations! = .cloverConfigLocation
		var isEjectable = false
		var bsdid: String = ""
		var partitions: [PartitionItem] = []
		var isBar = false
		
		public let tileHeight: CGFloat = 60
		
		private var alreadyDrwn = false
		
		public override func draw(_ dirtyRect: NSRect) {
			super.draw(dirtyRect)
			
			if alreadyDrwn{ return }
			
			let buttonWidth: CGFloat = 190
			let buttonsHeigth: CGFloat = 32
			
			let tileWidth = self.frame.width / 3.2
			let margin: CGFloat = self.frame.width * 0.015625 //(self.frame.width - ((self.frame.width / 3.2) * 3)) / 4
			
			self.wantsLayer = true
			self.needsLayout = true
			
			titleLabel.isEditable = false
			titleLabel.isSelectable = false
			titleLabel.drawsBackground = false
			titleLabel.isBordered = false
			titleLabel.isBezeled = false
			titleLabel.alignment = .left
			
			titleLabel.frame.origin = NSPoint(x: margin, y: self.frame.height - 29)
			titleLabel.frame.size = NSSize(width: self.frame.size.width - (margin * 3) - 24, height: 24)
			titleLabel.font = NSFont.boldSystemFont(ofSize: 20)//NSFont.systemFont(ofSize: 30)
			
			self.addSubview(titleLabel)
			
			//mountButton.title = "Mount EFI partition"
			mountButton.title = EFIPMTextManager.getViewString(context: self, stringID: "mountButton")
			mountButton.bezelStyle = .rounded
			mountButton.setButtonType(.momentaryPushIn)
			
			mountButton.frame.size = NSSize(width: buttonWidth, height: buttonsHeigth)
			
			mountButton.frame.origin = NSPoint(x: self.frame.size.width - buttonWidth - margin / 2, y: 5)
			
			mountButton.font = NSFont.boldSystemFont(ofSize: 13)
			mountButton.isContinuous = true
			mountButton.target = self
			mountButton.action = #selector(EFIPartitionItem.mountPartition(_:))
			
			self.addSubview(mountButton)
			
			//unmountButton.title = "Unmount EFI partition"
			unmountButton.title = EFIPMTextManager.getViewString(context: self, stringID: "unmountButton")
			unmountButton.bezelStyle = .rounded
			unmountButton.setButtonType(.momentaryPushIn)
			
			unmountButton.frame.size = mountButton.frame.size
			
			unmountButton.frame.origin = mountButton.frame.origin
			
			unmountButton.font = NSFont.boldSystemFont(ofSize: 13)
			unmountButton.isContinuous = true
			unmountButton.target = self
			unmountButton.action = #selector(EFIPartitionItem.unmountPartition(_:))
			
			self.addSubview(unmountButton)
			
			//showInFinderButton.title = "Open in Finder"
			showInFinderButton.title = EFIPMTextManager.getViewString(context: self, stringID: "openInfinderButton")
			showInFinderButton.bezelStyle = .rounded
			showInFinderButton.setButtonType(.momentaryPushIn)
			
			showInFinderButton.frame.size = NSSize(width: 140, height: buttonsHeigth)
			
			showInFinderButton.frame.origin = unmountButton.frame.origin
			showInFinderButton.frame.origin.x -= showInFinderButton.frame.size.width + 1
			
			showInFinderButton.font = NSFont.systemFont(ofSize: 13)
			showInFinderButton.isContinuous = true
			showInFinderButton.target = self
			showInFinderButton.action = #selector(EFIPartitionItem.showPartition(_:))
			
			self.addSubview(showInFinderButton)
			
			#if !macOnlyMode
			//editConfigButton.title = "Edit config.plist"
			editOtherConfigButton.title = EFIPMTextManager.getViewString(context: self, stringID: "editConfigButtonOther")
			
			editOtherConfigButton.bezelStyle = .rounded
			editOtherConfigButton.setButtonType(.momentaryPushIn)
			
			editOtherConfigButton.frame.size = NSSize(width: buttonWidth, height: buttonsHeigth)
			editOtherConfigButton.frame.origin = NSPoint(x: margin / 2, y: 5)//NSPoint(x: margin / 2, y: buttonsHeigth + 10)
			
			editOtherConfigButton.font = NSFont.systemFont(ofSize: 13)
			editOtherConfigButton.isContinuous = true
			editOtherConfigButton.target = self
			
			editOtherConfigButton.action = #selector(EFIPartitionItem.openConfigMenu(_:))
			
			self.addSubview(editOtherConfigButton)
			
			configOpenMenu = NSMenu()
			
			for c in 0..<appMenu.list.count{
				let name = appMenu.list[c].name
				
				var itm: NSMenuItem = NSMenuItem()
				
				if name == "Separator"{
					itm = NSMenuItem.separator()
					itm.isEnabled = false
				}else{
					itm.title = name
					itm.tag = c
					itm.isEnabled = true
					itm.isHidden = false
					itm.target = self
					itm.action = #selector(editConfigGeneric(_:))
				}
					
				configOpenMenu.insertItem(itm, at: c)
			}
			
			
			#endif
			
			ejectButton.title = ""
			ejectButton.bezelStyle = .texturedRounded
			ejectButton.setButtonType(.momentaryPushIn)
			ejectButton.isBordered = false
			
			ejectButton.imageScaling = .scaleProportionallyUpOrDown
			ejectButton.imagePosition = .imageOnly
			ejectButton.image = IconsManager.shared.getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/EjectMediaIcon.icns", symbol: "eject", name: "EFIIcon")
			
			ejectButton.frame.size = NSSize(width: titleLabel.frame.height, height: titleLabel.frame.height)
			
			ejectButton.frame.origin = NSPoint(x: titleLabel.frame.size.width + margin * 2, y: titleLabel.frame.origin.y)
			
			ejectButton.isContinuous = true
			ejectButton.target = self
			ejectButton.action = #selector(EFIPartitionItem.ejectDrive(_:))
			
			self.addSubview(ejectButton)
			
			spinner.style = .spinning
			
			spinner.frame.size = NSSize(width: 30, height: 30)
			
			spinner.frame.origin = NSPoint(x: (self.frame.width / 2) - (spinner.frame.size.width / 2), y: (self.frame.height / 2) - (spinner.frame.size.height / 2))
			
			coverView.addSubview(spinner)
			coverView.frame.size = self.frame.size
			coverView.frame.origin = NSPoint.zero
			coverView.backgroundColor = .controlColor
			coverView.wantsLayer = true
			coverView.layer?.opacity = 0.7
			coverView.layer?.cornerRadius = (self.layer?.cornerRadius)!
			coverView.layer?.zPosition = 10
			
			self.addSubview(coverView)
			
			self.spinner.isDisplayedWhenStopped = false
			self.spinner.usesThreadedAnimation = true
			
			if partitions.count == 0{
				
				placeHolderLabel.isEditable = false
				placeHolderLabel.isSelectable = false
				placeHolderLabel.drawsBackground = false
				placeHolderLabel.isBordered = false
				placeHolderLabel.isBezeled = false
				placeHolderLabel.alignment = .left
				
				placeHolderLabel.frame.origin = NSPoint(x: 10, y: titleLabel.frame.origin.y - (tileHeight / 2))
				placeHolderLabel.frame.size = NSSize(width: self.frame.size.width - 20 , height: 28)
				placeHolderLabel.font = NSFont.systemFont(ofSize: 18)
				
				//placeHolderLabel.stringValue = "No mounted partitions found"
				
				placeHolderLabel.stringValue = EFIPMTextManager.getViewString(context: self, stringID: "noPartitionsLabel")
				
				self.addSubview(placeHolderLabel)
				
			}else{
				
				var alternate: CGFloat = 0
				var startsAsVibrant = titleLabel.frame.origin.y - self.tileHeight - 15
				
				Swift.print("Adding tiles for drive: \(titleLabel.stringValue)")
				
				var distance: CGFloat = 0
				
				distance = 0
				
				for partition in partitions{
					partition.frame.size = CGSize(width: tileWidth, height: tileHeight)
					
					partition.frame.origin.y = startsAsVibrant
					
					partition.frame.origin.x = (tileWidth * alternate) + (margin * (alternate + 1)) + distance
					
					if alternate == 2{
						startsAsVibrant -= self.tileHeight + margin
						alternate = 0
					}else{
						alternate += 1
					}
					
					self.addSubview(partition)
					
					Swift.print("  Tile added: \(partition.nameLabel.stringValue)")
				}
				
			}
			
			alreadyDrwn.toggle()
			
			checkMounted()
		}
		
		override public func updateLayer() {
			coverView.backgroundColor = .controlColor
			self.backgroundColor = .controlBackgroundColor
		}
		
		@objc private func mountPartition(_ sender: Any){
			guard let controller = self.window?.contentViewController as? EFIPartitionMounterViewController else { return }
			
			changeLoadMode(enabled: true)
			
			DispatchQueue.global(qos: .background).async {
					
				controller.watcherSkip = true
					
				self.isMounted = controller.eFIManager.mountPartition(self.bsdid)
				
				if !self.isMounted{
					self.configType = nil
				} else {
					if let mountPoint = dm.getMountPointFromPartitionBSDID(self.bsdid){
						self.configType = EFIPartitionToolTypes.ConfigLocations.folderHasConfig(mountPoint)
					}
				}
					
				DispatchQueue.main.async {
					self.checkMounted()
				}
				
			}
		}
		
		@objc private func unmountPartition(_ sender: Any){
			guard let controller = self.window?.contentViewController as? EFIPartitionMounterViewController else { return }
			
			changeLoadMode(enabled: true)
			
			DispatchQueue.global(qos: .background).async {
					
				controller.watcherSkip = true
					
				self.isMounted = !controller.eFIManager.unmountPartition(self.bsdid)
					
				DispatchQueue.main.async {
					self.checkMounted()
				}
			}
		}
		
		@objc private func showPartition(_ sender: Any){
			DispatchQueue.global(qos: .background).async {
				guard let mountPoint = dm.getMountPointFromPartitionBSDID(self.bsdid) else { return }
				
				NSWorkspace.shared.open(URL(fileURLWithPath: mountPoint, isDirectory: true))
			}
		}
		
		#if !macOnlyMode
		
		@objc private func openConfigMenu(_ sender: Any){
			
			if configType == nil{
				return
			}
			
			configOpenMenu.popUp(positioning: nil, at: editOtherConfigButton.frame.origin, in: self)
		}
		
		@objc private func editConfigGeneric(_ sender: Any){
			
			if configType == nil{
				return
			}
			
			guard let sen = sender as? NSMenuItem else { return }
			let target = sen.tag
			
			DispatchQueue.global(qos: .background).async{
				guard let mountPoint = dm.getMountPointFromPartitionBSDID(self.bsdid) else { return }
			
				guard let config = EFIPartitionToolTypes.ConfigLocations.folderHasConfig(mountPoint) else { return }
			
				let configLocation = mountPoint + config.rawValue
				
				let item = appMenu.list[target]
				
				DispatchQueue.main.sync{
				
					switch item.installedAppName{
					case "":
						if NSWorkspace.shared.openFile(configLocation){ return }
						
						msgboxWithManagerGeneric(EFIPMTextManager, self, name: "impossible", parseList: nil, style: .warning, icon: IconsManager.shared.warningIcon)
						break
					case "{openLink}" :
						NSWorkspace.shared.open(URL(string: item.download)!)
						break
					default:
						if NSWorkspace.shared.openFile(configLocation, withApplication: item.installedAppName){ return }
						
						let list = ["{appName}" : item.installedAppName]
						if dialogWithManagerGeneric(EFIPMTextManager as TextManagerGet, self, name: "download", parseList: list){
							NSWorkspace.shared.open(URL(string: item.download)!)
						}
						break
					}
				
				}
			}
		}
		#endif
		
		@objc private func ejectDrive(_ sender: Any){
			changeLoadMode(enabled: true)
			
			var controller : EFIPartitionMounterViewController!
			
			controller = self.window?.windowController?.contentViewController as? EFIPartitionMounterViewController
			
			if controller == nil {
				self.checkMounted()
				return
			}
			
			DispatchQueue.global(qos: .background).async{
				
				let driveID = dm.getDriveBSDIDFromVolumeBSDID(volumeID: self.bsdid)
				
				var res = false
				
				var text = ""
				
				DispatchQueue.global(qos: .background).sync{
					controller.watcherSkip = true
				}
				
				text = CommandsManager.getOut(cmd: "diskutil eject \(driveID)")
				//text = getOut(cmd: "diskutil unmountDisk \(driveID)")
				
				//res = (text.contains("Unmount of all volumes on") && text.contains("was successful")) || (text.isEmpty)
				
				let resSrc: [(Bool, [String])] = [(true, [""]), (false, ["Unmount of all volumes on", "was successful"]), (false, ["Disk", "ejected"])]
				
				for s in resSrc{
					if !s.0{
						var breaked = false
						for r in s.1{
							if !text.contains(r){
								breaked = true
								break
							}
						} 
						if breaked{
							continue
						}
					}else if !s.1.isEmpty{
						if text != s.1.first!{
							continue
						}
					}
					
					res = true
				}
				
				if res{
					log("Drive unmounted with success: \(driveID)")
					
					DispatchQueue.main.sync {
						
						let disk = self.titleLabel.stringValue
						msgBox("You can remove \"\(disk)\"", "Now it's safe to remove \"\(disk)\" from the computer", .informational)
						
						self.checkMounted()
						
						controller.refresh(controller!)
						
					}
					
				}else{
					log("Drive not unmounted, error generated: \(text)")
					
					//msgBoxWarning("Impossible to eject \"\(driveID)\"", "There was an error while trying to eject this disk: \(driveID)\n\nDiagnostics info: \n\nCommand executed: diskutil unmountDisk \(driveID)\nOutput: \(text)")
					DispatchQueue.main.sync {
						let list = ["{disk}" : self.titleLabel.stringValue, "{text}" : text]
						msgboxWithManagerGeneric(EFIPMTextManager, self, name: "notEject", parseList: list, style: .warning, icon: IconsManager.shared.warningIcon)
					}
					
					
				}
				
				
			}
		}
		
		func checkMounted(){
			
			changeLoadMode(enabled: false)
			
			showInFinderButton.isHidden = !isMounted || sharedIsReallyOnRecovery
			unmountButton.isHidden = !isMounted
			
			mountButton.isHidden = isMounted
			
			editOtherConfigButton.isHidden = !(isMounted && configType != nil && !sharedIsReallyOnRecovery)
			
			ejectButton.isHidden = !isEjectable || (isMounted && partitions.isEmpty)
			
		}
		
		private func changeLoadMode(enabled: Bool){
			
			mountButton.isEnabled = !enabled
			unmountButton.isEnabled = !enabled
			showInFinderButton.isEnabled = !enabled
			ejectButton.isEnabled = !enabled
			
			coverView.isHidden = !enabled
			
			if enabled{
				spinner.startAnimation(coverView)
			}else{
				spinner.stopAnimation(coverView)
			}
		}
		
	}
	
	
	
	public class PartitionItem: NSView {
		let imageView = NSImageView()
		let nameLabel = NSTextField()
		
		override public func draw(_ dirtyRect: NSRect) {
			
			//self.backgroundColor = .red
			
			imageView.frame.size = NSSize(width: self.frame.size.height, height: self.frame.size.height)
			imageView.frame.origin = NSPoint.zero
			imageView.imageScaling = .scaleProportionallyUpOrDown
			imageView.isEditable = false
			
			self.addSubview(imageView)
			
			nameLabel.isEditable = false
			nameLabel.isSelectable = false
			nameLabel.drawsBackground = false
			nameLabel.isBordered = false
			nameLabel.isBezeled = false
			nameLabel.alignment = .left
			
			var h: CGFloat = 22
			
			let div = nameLabel.stringValue.count / 16
			
			if div < 3{
				h *= CGFloat(div + 1)
			}else{
				h *= 3
			}
			
			nameLabel.frame.origin = NSPoint(x: self.frame.size.height, y: (self.frame.height / 2) - (h / 2))
			nameLabel.frame.size = NSSize(width: self.frame.size.width - self.frame.size.height, height: h)
			nameLabel.font = NSFont.systemFont(ofSize: 15)
			
			self.addSubview(nameLabel)
			
		}
		
		
		
	}
}
#endif

