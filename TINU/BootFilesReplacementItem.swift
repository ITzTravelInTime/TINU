//
//  bootFilesReplacementItem.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

/*
import Cocoa

#if !macOnlyMode

class BootFilesReplacementItem: NSView {
    var textField = NSTextField()
    
    var openButton = NSButton()
    
    var deleteButton = NSButton()
    
    var imageView = NSImageView()
    
    var chosedText = NSTextField()
    
    var replaceFile: BootFilesReplacementManager.ReplaceFileObject!
    
    var isInPlace = false
	
	var isGray = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		//F5F5F5
		if isGray{
			self.backgroundColor = NSColor.controlAlternatingRowBackgroundColors[0]
		}else{
			self.backgroundColor = NSColor.controlAlternatingRowBackgroundColors[1]
		}
		
		let fieldHeigth: CGFloat = 17
		let buttonsHeigth: CGFloat = 32
		
		//let choosedLabelHeigth: CGFloat = 14
        
        isInPlace = replaceFile.data != nil
        
        openButton.title = "Customize"
        openButton.bezelStyle = .rounded
		openButton.setButtonType(.momentaryPushIn)
		
        openButton.frame.size = NSSize(width: 100, height: buttonsHeigth)
		
		openButton.frame.origin = NSPoint(x: self.frame.size.width - openButton.frame.size.width - 5, y: (self.frame.size.height / 2) - buttonsHeigth / 2)
		
        openButton.font = NSFont.systemFont(ofSize: 13)
        openButton.isContinuous = true
        openButton.target = self
        openButton.action = #selector(BootFilesReplacementItem.openClick)
        
        self.addSubview(openButton)
        
        deleteButton.title = "Reset"
        deleteButton.bezelStyle = openButton.bezelStyle
		deleteButton.setButtonType(.momentaryPushIn)
        deleteButton.frame.size = NSSize(width: 100, height: buttonsHeigth)
		deleteButton.frame.origin = NSPoint(x: self.frame.size.width - deleteButton.frame.size.width - 5, y: openButton.frame.origin.y)
        deleteButton.font = NSFont.boldSystemFont(ofSize: (openButton.font?.pointSize)!)
        deleteButton.isContinuous = openButton.isContinuous
        deleteButton.target = self
        deleteButton.action = #selector(BootFilesReplacementItem.deleteClick)
        
        self.addSubview(deleteButton)
		
		imageView.image = NSImage(named: "check")
		imageView.frame.size = NSSize(width: (self.frame.size.height - 10), height: (self.frame.size.height - 10))
		imageView.frame.origin = NSPoint(x: deleteButton.frame.origin.x - imageView.frame.width - 5, y: 5)
		imageView.imageScaling = .scaleProportionallyUpOrDown
		imageView.isEditable = false
		
		self.addSubview(imageView)
		
		
//		chosedText.isEditable = false
//		chosedText.isSelectable = false
//		chosedText.drawsBackground = false
//		chosedText.isBordered = false
//		chosedText.isBezeled = false
//		chosedText.alignment = .right
//		chosedText.frame.size = NSSize(width: 60, height: choosedLabelHeigth)
//		chosedText.frame.origin = NSPoint(x: imageView.frame.origin.x - chosedText.frame.width - 5, y: self.frame.size.height / 2 - choosedLabelHeigth / 2)
//		chosedText.font = NSFont.systemFont(ofSize: choosedLabelHeigth - 2)
//		chosedText.stringValue = "Customized"
//
//		self.addSubview(chosedText)
//		
		
		textField.isEditable = false
		textField.isSelectable = false
		textField.drawsBackground = false
		textField.isBordered = false
		textField.isBezeled = false
		textField.alignment = .left
		
		textField.frame.origin = NSPoint(x: 10, y: self.frame.size.height / 2 - fieldHeigth / 2)
		textField.frame.size = NSSize(width: self.frame.size.width - 10 - deleteButton.frame.size.width - 5 - imageView.frame.width - 5 - 5, height: fieldHeigth)
		textField.font = NSFont.systemFont(ofSize: 13)
		
		self.addSubview(textField)
		
        checkButtonsVisibility()
    }
	
    func checkButtonsVisibility(){
        openButton.isHidden = isInPlace
        
        deleteButton.isHidden = !isInPlace
        
        imageView.isHidden = deleteButton.isHidden
        
        chosedText.isHidden = deleteButton.isHidden
    }
    
    func deleteClick(){
        for f in 0...(BootFilesReplacementManager.shared.filesToReplace.count - 1){
            if BootFilesReplacementManager.shared.filesToReplace[f].filename == replaceFile.filename{
                BootFilesReplacementManager.shared.filesToReplace[f].data = nil
                isInPlace = false
                log("Value removed successfully from \"" + replaceFile.filename + "\"")
            }
        }
        
        checkButtonsVisibility()
    }
    
    func openClick(){
        let extNil = (URL.init(string: "file:///" + replaceFile.filename)?.pathExtension)
        var ext = ""
        
        if let ex = extNil{
            ext = ex
        }
        
        
        let open = NSOpenPanel()
        open.allowsMultipleSelection = false
        open.canChooseDirectories = false
        open.canChooseFiles = true
        open.isExtensionHidden = false
        open.showsHiddenFiles = true
        open.allowedFileTypes = [ext]
        
        open.beginSheetModal(for: CustomizationWindowManager.shared.referenceWindow , completionHandler: {response in
			
			if response == NSModalResponseOK{
				if !open.urls.isEmpty{
					do{
						
						log("Trying to give a value at the item: \(self.replaceFile.filename)")
						
						//log(open.urls.first!)
						
						//replaceFile.data = try Data.init(contentsOf: open.urls.first!)
						
						for f in 0...(BootFilesReplacementManager.shared.filesToReplace.count - 1){
							if BootFilesReplacementManager.shared.filesToReplace[f].filename == self.replaceFile.filename{
								BootFilesReplacementManager.shared.filesToReplace[f].data = try Data.init(contentsOf: open.urls.first!)
								self.isInPlace = true
								log("Value gived successfully!")
							}
						}
						
						self.checkButtonsVisibility()
//
//						for i in filesToReplace{
//						var isnil = false
//						if i.data == nil{
//						isnil = true
//						}
//						log("item " + i.filename + " data " + String(isnil))
//						}
						
					}catch let error{
						log(error.localizedDescription)
						msgBox("Error while opening the file", "There was an error while opening the file you choosed: \n" + error.localizedDescription, NSAlertStyle.critical)
					}
				}
			}
			
		})
		
//
//		if open.runModal() == NSModalResponseOK{
//		if !open.urls.isEmpty{
//		do{
//
//		log("Trying to give a value at the item: \(replaceFile.filename)")
//
//		//log(open.urls.first!)
//
//		//replaceFile.data = try Data.init(contentsOf: open.urls.first!)
//
//		for f in 0...(BootFilesReplacementManager.shared.filesToReplace.count - 1){
//		if BootFilesReplacementManager.shared.filesToReplace[f].filename == replaceFile.filename{
//		BootFilesReplacementManager.shared.filesToReplace[f].data = try Data.init(contentsOf: open.urls.first!)
//		isInPlace = true
//		log("Value gived successfully!")
//		}
//		}
//
//		checkButtonsVisibility()
//
//		for i in filesToReplace{
//		var isnil = false
//		if i.data == nil{
//		isnil = true
//		}
//		log("item " + i.filename + " data " + String(isnil))
//		}
//
//		}catch let error{
//		log(error.localizedDescription)
//		msgBox("Error while opening the file", "There was an error while opening the file you choosed: \n" + error.localizedDescription, NSAlertStyle.critical)
//		}
//		}
//		}
//
    }
}

#endif

*/
