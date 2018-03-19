//
//  DriveObject.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class is an UI object used to represent a drive or a insteller app that can be selected by the user
class DriveObject: NSView {
    
    var isEnabled = true{
        didSet{
            setDefaultAspect()
        }
    }

    public var isApp = false
    
    public var volumePath = ""
    public var volumeBSD = ""
    public var applicationPath = ""
    
    public var part: Part!
    
    var image = NSImageView()
    var volume = NSTextField()
    
    var overlay: NSImageView!
	
	var sz: String!
    /*
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //refreshUI()
    }
    */
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        refreshUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
	
	override func viewDidMoveToSuperview() {
		self.setDefaultAspect()
	}
	
    private func refreshUI(){
        //self.borderColor = NSColor.red.cgColor
        //self.backgroundColor = NSColor.blue
        self.layer?.cornerRadius = 15
        
        image = NSImageView(frame: NSRect(x: 15, y: 55, width: self.frame.size.width - 30, height: self.frame.size.height - 60))
        image.isEditable = false
        image.imageAlignment = .alignCenter
        image.imageScaling = .scaleProportionallyUpOrDown
        self.addSubview(image)
        
        volume = NSTextField(frame: NSRect(x: 5, y: 5, width: self.frame.size.width - 10, height: 45))
        volume.font = NSFont.boldSystemFont(ofSize: 10)
        volume.stringValue = ""
        volume.isEditable = false
        volume.isBordered = false
        volume.alignment = .center
        volume.backgroundColor = NSColor.white.withAlphaComponent(0)
        
        //volume.isSelectable = false
        self.addSubview(volume)
        
        volume.isEnabled = isEnabled
        image.isEnabled = isEnabled
		
    }
    
    override func mouseDown(with event: NSEvent) {
        
        for c in (self.superview?.subviews)!{
            if let d = c as? DriveObject{
                if d != self{
                    d.setDefaultAspect()
                }
            }
        }
        
        if isEnabled{
            setSelectedAspect()
            
            if isApp{
				sharedApp = applicationPath
				Swift.print("The application that the user has selected is: " + applicationPath)
				
            }else{
				sharedSVReallyIsAPFS = false
				
				//sharedVolumeNeedsFormat = nil
				sharedVolumeNeedsPartitionMethodChange = nil
				
				if part != nil{
					if part.partScheme != "GUID_partition_scheme" || !part.hasEFI{
						sharedVolumeNeedsPartitionMethodChange = true
						/*}else{
						sharedVolumeNeedsPartitionMethodChange = false*/
					}
					
					if !sharedInstallMac && part.fileSystem == "APFS"{
						sharedVolumeNeedsPartitionMethodChange = true
					}
					
					if sharedInstallMac && (part.fileSystem == "Other" || !part.hasEFI){
						sharedVolumeNeedsPartitionMethodChange = true
					}
					
					/*
					if part.fileSystem == "Other" && !sharedVolumeNeedsPartitionMethodChange{
					sharedVolumeNeedsFormat = true
					}else{
					sharedVolumeNeedsFormat = false
					}*/
				}
				
				sharedVolume = volumePath
				sharedBSDDrive = volumeBSD
				
				sharedBSDDriveAPFS = part.apfsBDSName
				
				sharedSVReallyIsAPFS = part.driveType == .apfs
				
				Swift.print("The volume that the user has selected is: " + volumePath)
            }
			
		}
		
			if isApp{
				if let s = self.window?.contentViewController as? ChoseAppViewController{
					s.ok.isEnabled = isEnabled
				}
			}else{
				if let s = self.window?.contentViewController as? ChoseDriveViewController{
					s.ok.isEnabled = isEnabled
				}
			}
		
    }
	
    public func setDefaultAspect(){
		if sz == nil{
			if let s = part?.size{
				sz = "Size: \(self.roundInt(number: s))"
			}else{
				sz = "Size: 0 Byte"
			}
		}
		
        //self.layer?.backgroundColor = NSColor.white.withAlphaComponent(0).cgColor
        if isEnabled{
            self.backgroundColor = NSColor.white.withAlphaComponent(0)
            volume.textColor = NSColor.textColor
            
            if overlay != nil{
                overlay.image = NSImage()
                overlay.removeFromSuperview()
                overlay = nil
            }
			
			if isApp{
				self.toolTip = "Path: " + applicationPath
			}else{
				self.toolTip = sz
			}
			
        }else{
            //self.backgroundColor = NSColor.lightGray
            self.backgroundColor = NSColor.white.withAlphaComponent(0)
            volume.textColor = NSColor.lightGray
            self.layer?.cornerRadius = 15
            
            overlay = NSImageView(frame: self.image.frame)
            overlay.image = unsupportedOverlay
            
            self.addSubview(overlay)
			
			if isApp{
				self.toolTip = "This app is not usable bacause it's incomplete, you need the full installer app \nwhich weigths more than 5 gb\n\nPath: " + applicationPath
			}else{
				if sharedInstallMac{
					self.toolTip = "This drive can't be used to\ninstall macOS in it now."
				}else{
					self.toolTip = "This drive can't be used to\ncreate a macOS install media"
				}
			}
        }
        
    }
    
    public func setSelectedAspect(){
        //self.layer?.backgroundColor = NSColor.blue.cgColor
        self.backgroundColor = NSColor.selectedControlColor
        volume.textColor = NSColor.selectedControlTextColor
        self.layer?.cornerRadius = 15
    }
	
	func roundInt(number: UInt64) -> String{
		var n = number
		var div: UInt64 = 1
		
		while n > 1000 {
			div *= 1000
			n = number / div
		}
		
		var sufx = ""
		
		//log10(Double(div))
		switch log10(Double(div)) {
		case 3:
			sufx = "KB"
		case 6:
			sufx = "MB"
		case 9:
			sufx = "GB"
		case 12:
			sufx = "TB"
		case 15:
			sufx = "PB"
		case 0, 1, 2:
			sufx = "Byte"
		default:
			sufx = ""
		}
		
		return "\(n)\(sufx)"
	}
	
}
