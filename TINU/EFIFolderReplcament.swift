//
//  EFIFolderReplcament.swift
//  TINU
//
//  Created by Pietro Caruso on 22/05/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if useEFIReplacement && !macOnlyMode
public class EFIReplacementView: NSView{
	//titles
	let titleLabel = NSTextField()
	let expLabel = NSTextField()
	
	//folder opened
	let pathLabel = NSTextField()
	let checkImage = NSImageView()
	
	//buttons
	let openButton = NSButton()
	let resetButton = NSButton()
	
	//draw code
	
	override public func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		viewDidMoveToSuperview()
	}
	
	var bootloader: SupportedEFIFolders = .clover{
		didSet{
			viewDidMoveToSuperview()
		}
	}
	
	override public func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		
		//size constants
		let buttonsHeigth: CGFloat = 32
		
		let fieldHeigth: CGFloat = 20
		
		let imgSide: CGFloat = 40
		
		//titles
		titleLabel.isEditable = false
		titleLabel.isSelectable = false
		titleLabel.drawsBackground = false
		titleLabel.isBordered = false
		titleLabel.isBezeled = false
		titleLabel.alignment = .center
		
		titleLabel.frame.origin = NSPoint(x: 5, y: self.frame.size.height - fieldHeigth - 5)
		titleLabel.frame.size = NSSize(width: self.frame.size.width - 10 , height: fieldHeigth)
		titleLabel.font = NSFont.boldSystemFont(ofSize: 13)
		self.addSubview(titleLabel)
		
		expLabel.isEditable = false
		expLabel.isSelectable = false
		expLabel.drawsBackground = false
		expLabel.isBordered = false
		expLabel.isBezeled = false
		expLabel.alignment = .left
		
		expLabel.frame.origin = NSPoint(x: 5, y: self.frame.size.height - fieldHeigth * 5 - 5)
		expLabel.frame.size = NSSize(width: self.frame.size.width - 10 , height: fieldHeigth * 4)
		expLabel.font = NSFont.systemFont(ofSize: 13)
		
		if let drive = dm.getCurrentDriveName(){
			titleLabel.stringValue = "\(bootloader.rawValue) EFI folder installer"
			expLabel.stringValue = "This option automatically installs the selected \(bootloader.rawValue) EFI folder inside the EFI partition of the drive \"\(drive)\".\nOnly UEFI 64Bits \(bootloader.rawValue) EFI folders are supported."
		}
		
		self.addSubview(expLabel)
		
		
		//efi folder check
		pathLabel.isEditable = false
		pathLabel.isSelectable = false
		pathLabel.drawsBackground = false
		pathLabel.isBordered = false
		pathLabel.isBezeled = false
		pathLabel.alignment = .left
		
		pathLabel.frame.origin = NSPoint(x: 5, y: buttonsHeigth + 10)
		pathLabel.frame.size = NSSize(width: self.frame.size.width - 10 - imgSide , height: 26)
		pathLabel.font = NSFont.systemFont(ofSize: 12)
		
		pathLabel.stringValue = ""
		
		self.addSubview(pathLabel)
		
		checkImage.image = NSImage(named: "checkVector")
		checkImage.frame.size = NSSize(width: imgSide, height: imgSide)
		checkImage.frame.origin = NSPoint(x: self.frame.size.width - 5 - imgSide, y: pathLabel.frame.origin.y + (pathLabel.frame.height / 2) - (imgSide / 2))
		checkImage.imageScaling = .scaleProportionallyUpOrDown
		checkImage.isEditable = false
		
		self.addSubview(checkImage)
		
		//buttons
		openButton.title = "Choose Folder ..."
		openButton.bezelStyle = .rounded
		openButton.setButtonType(.momentaryPushIn)
		
		openButton.frame.size = NSSize(width: 150, height: buttonsHeigth)
		
		openButton.frame.origin = NSPoint(x: self.frame.size.width - openButton.frame.size.width - 5, y: 5)
		
		openButton.font = NSFont.systemFont(ofSize: 13)
		openButton.isContinuous = true
		openButton.target = self
		openButton.action = #selector(EFIReplacementView.openClick)
		
		self.addSubview(openButton)
		
		resetButton.title = "Remove"
		resetButton.bezelStyle = .rounded
		resetButton.setButtonType(.momentaryPushIn)
		
		resetButton.frame.size = NSSize(width: 100, height: buttonsHeigth)
		
		resetButton.frame.origin = NSPoint(x: 5, y: 5)
		
		resetButton.font = NSFont.systemFont(ofSize: 13)
		resetButton.isContinuous = true
		resetButton.target = self
		resetButton.action = #selector(EFIReplacementView.resetClick)
		
		self.addSubview(resetButton)
		
		checkOriginFolder()
		
		//check states
		if EFIFolderReplacementManager.shared.checkSavedEFIFolder() == nil{
			resetButton.isEnabled = false
			openButton.isEnabled = true
		}else{
			resetButton.isEnabled = true
			openButton.isEnabled = false
		}
	}
	
	func openClick(){
		let open = NSOpenPanel()
		open.allowsMultipleSelection = false
		open.canChooseDirectories = true
		open.canChooseFiles = false
		open.isExtensionHidden = false
		open.showsHiddenFiles = true
		
		open.beginSheetModal(for: CustomizationWindowManager.shared.referenceWindow, completionHandler: {response in
			if response == NSModalResponseOK{
				if !open.urls.isEmpty{
					DispatchQueue.global(qos: .background).async{
						if let opener = EFIFolderReplacementManager.shared.loadEFIFolder(open.urls.first!.path, currentBootloader: self.bootloader){
							if !opener{
								DispatchQueue.main.async {
									
									//is this really usefoul or needed? can this be batter?
									msgBoxWarning("Impossible to open the EFI folder", "There was an unkown error while trying to open the selcted EFI folder")
								}
							}else{
								DispatchQueue.main.sync {
									self.checkOriginFolder()
								}
							}
						}else{
							DispatchQueue.main.sync {
								
								msgBoxWarning("The folder \"\(open.urls.first!.path)\" is not a proper \(self.bootloader.rawValue) efi folder", "The folder you selected \"\(open.urls.first!.path)\" does not contain the required element \"\(EFIFolderReplacementManager.shared.missingFileFromOpenedFolder!)\", make sure to open just the folder named EFI and that it cointains all the needed elements")
								
								EFIFolderReplacementManager.shared.resetMissingFileFromOpenedFolder()
								
							}
						}
					}
				}
			}
		})
	}
	
	func resetClick(){
		DispatchQueue.global(qos: .background).async{
			if !EFIFolderReplacementManager.shared.unloadEFIFolder(){
				DispatchQueue.main.async {
					
					//is this really usefoul or needed? can this be batter?
					msgBoxWarning("TINU: Error while unloading the EFI folder", "There was an error while unloading the stored efi foleer from the program memory")
				}
			}else{
				DispatchQueue.main.async {
					self.checkOriginFolder()
				}
			}
		}
		
		
	}
	
	func checkOriginFolder(){
		
		
		
		if EFIFolderReplacementManager.shared.openedDirectory == nil{
			pathLabel.stringValue = ""
			checkImage.isHidden = true
			
			self.resetButton.isEnabled = false
			self.openButton.isEnabled = true
		}else{
			
			if EFIFolderReplacementManager.shared.currentEFIFolderType == self.bootloader{
				var str = EFIFolderReplacementManager.shared.openedDirectory!
				
				if str.count > 45{
					str = str[0...45] + "..."
				}
			
				pathLabel.stringValue = str
				checkImage.isHidden = false
				
			}else{
				
				let t = EFIFolderReplacementManager.shared.currentEFIFolderType.rawValue
				
				//this is still imprecise because it doesn't accounts for the usage of the h as the first letter, but for now it's enought
				pathLabel.stringValue = "You have alreay chosen " + (t.first!.isVowel() ? "an " : "a ") + t + " EFI folder"
				
				checkImage.isHidden = true
			}
			
			self.resetButton.isEnabled = true
			self.openButton.isEnabled = false
		}
	}
	
}
#endif
