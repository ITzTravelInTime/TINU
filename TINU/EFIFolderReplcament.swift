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
		
		//size constants
		let buttonsHeigth: CGFloat = 32
		
		let fieldHeigth: CGFloat = 20
		
		let imgSide: CGFloat = 30
		
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
		
		titleLabel.stringValue = "Clover EFI folder installer"
		
		self.addSubview(titleLabel)
		
		expLabel.isEditable = false
		expLabel.isSelectable = false
		expLabel.drawsBackground = false
		expLabel.isBordered = false
		expLabel.isBezeled = false
		expLabel.alignment = .left
		
		expLabel.frame.origin = NSPoint(x: 5, y: self.frame.size.height - fieldHeigth * 4 - 5)
		expLabel.frame.size = NSSize(width: self.frame.size.width - 10 , height: fieldHeigth * 3)
		expLabel.font = NSFont.systemFont(ofSize: 13)
		
		expLabel.stringValue = "This option automatically installs the selected Clover EFI folder inside the EFI partition of the target drive.\nOnly UEFI 64Bits Clover EFI folders are supported."
		
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
		
		checkImage.image = NSImage(named: "check")
		checkImage.frame.size = NSSize(width: imgSide, height: imgSide)
		checkImage.frame.origin = NSPoint(x: self.frame.size.width - 5 - imgSide, y: pathLabel.frame.origin.y + (pathLabel.frame.height / 2) - (imgSide / 2))
		checkImage.imageScaling = .scaleProportionallyUpOrDown
		checkImage.isEditable = false
		
		self.addSubview(checkImage)
		
		//buttons
		openButton.title = "Open a folder ..."
		openButton.bezelStyle = .rounded
		openButton.setButtonType(.momentaryPushIn)
		
		openButton.frame.size = NSSize(width: 150, height: buttonsHeigth)
		
		openButton.frame.origin = NSPoint(x: self.frame.size.width - openButton.frame.size.width - 5, y: 5)
		
		openButton.font = NSFont.systemFont(ofSize: 13)
		openButton.isContinuous = true
		openButton.target = self
		openButton.action = #selector(EFIReplacementView.openClick)
		
		self.addSubview(openButton)
		
		resetButton.title = "Delete"
		resetButton.bezelStyle = .rounded
		resetButton.setButtonType(.momentaryPushIn)
		
		resetButton.frame.size = NSSize(width: 100, height: buttonsHeigth)
		
		resetButton.frame.origin = NSPoint(x: 5, y: 5)
		
		resetButton.font = NSFont.systemFont(ofSize: 13)
		resetButton.isContinuous = true
		resetButton.target = self
		resetButton.action = #selector(EFIReplacementView.resetClick)
		
		self.addSubview(resetButton)
		
		
		//check states
		if EFIFolderReplacementManager.shared.checkSavedEFIFolder() == nil{
			resetButton.isEnabled = false
			openButton.isEnabled = true
		}else{
			resetButton.isEnabled = true
			openButton.isEnabled = false
		}
		
		checkOriginFolder()
	}
	
	func openClick(){
		let open = NSOpenPanel()
		open.allowsMultipleSelection = false
		open.canChooseDirectories = true
		open.canChooseFiles = false
		open.isExtensionHidden = false
		open.showsHiddenFiles = true
		
		if open.runModal() == NSModalResponseOK{
			if !open.urls.isEmpty{
				DispatchQueue.global(qos: .background).async{
					if let oper = EFIFolderReplacementManager.shared.loadEFIFolder(open.urls.first!.path){
					if !oper{
						DispatchQueue.main.async {
							msgBoxWarning("TINU: Impossible to open the EFI folder", "Error while opening the selcted EFI folder")
						}
					}else{
						DispatchQueue.main.async {
							//set ui
							
							//msgBox("TINU: EFI folder correctly opened", "EFI folder opened correctly, as it should be", .informational)
							
							self.resetButton.isEnabled = true
							self.openButton.isEnabled = false
							
							self.checkOriginFolder()
						}
					}
					}else{
						DispatchQueue.main.async {
							
							msgBoxWarning("TINU: EFI folder is not a proper clover efi folder", "EFI folder not opened, it does not seems to be a proper clover efi folder")
						}
					}
				}
			}
		}
	
	}
	
	func resetClick(){
		DispatchQueue.global(qos: .background).async{
			if !EFIFolderReplacementManager.shared.unloadEFIFolder(){
				DispatchQueue.main.async {
					msgBoxWarning("TINU: Error while removing efi folder from memory", "Error while removing the stored efi foleer from the program memory")
				}
			}else{
				DispatchQueue.main.async {
					self.resetButton.isEnabled = false
					self.openButton.isEnabled = true
					self.checkOriginFolder()
				}
			}
		}
		
		
	}
	
	func checkOriginFolder(){
		if EFIFolderReplacementManager.shared.openedDirectory == nil{
			pathLabel.stringValue = ""
			checkImage.isHidden = true
		}else{
			pathLabel.stringValue = EFIFolderReplacementManager.shared.openedDirectory!
			checkImage.isHidden = false
		}
	}
	
}
#endif
