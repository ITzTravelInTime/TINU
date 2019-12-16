//
//  DriveView.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class is an UI object used to represent a drive or a insteller app that can be selected by the user
class DriveView: ShadowView {
	
	//items size for chose drive and chose app screens
	
	static let itemSize: NSSize = NSSize(width: 130, height: 155)
	
	let cm = cvm.shared
    
    var isEnabled = true{
        didSet{
			
			//if !sharedIsOnRecovery{
			DispatchQueue.main.async {
				self.setDefaultAspect()
			}
        }
    }
	
	var isSelected = false

    public var isApp = false
    public var applicationPath = ""
    
    public var part: Part!
    
    var image = NSImageView()
    var volume = NSTextField()
	
	var warnImage: NSImageView!
	var warnText: NSTextField!
    
    var overlay: NSImageView!
	
	var sz: String!
	
	override func updateLayer() {
		super.updateLayer()
		
		//self.appearance = sharedWindow.effectiveAppearance
		
		if isSelected{
			self.backgroundColor = NSColor.selectedControlColor
		}
		
		if self.isEnabled{
			self.volume.textColor = NSColor.textColor
		/*}else{
			self.volume.textColor = NSColor.lightGray*/
		}
		
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		self.appearance = sharedWindow.effectiveAppearance
		
        //refreshUI()
		
		self.updateLayer()
		
		
		
    }
	
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
		
		self.appearance = sharedWindow.effectiveAppearance
		
        refreshUI()
		
		//self.wantsLayer = true
		self.needsLayout = true
		self.needsDisplay = true
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
		
		if (sharedIsOnRecovery || simulateDisableShadows){
			self.canShadow = false
			self.wantsLayer = true
			self.layer?.cornerRadius = 15
		}
        
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
        (volume as NSView).backgroundColor = NSColor.white.withAlphaComponent(0)
        
        //volume.isSelectable = false
        self.addSubview(volume)
        
        volume.isEnabled = isEnabled
        image.isEnabled = isEnabled
		
    }
    
    override func mouseDown(with event: NSEvent) {
        
        for c in (self.superview?.subviews)!{
            if let d = c as? DriveView{
                if d != self{
                    d.setDefaultAspect()
                }
            }
        }
        
        if isEnabled{
            setSelectedAspect()
            
            if isApp{
				cm.sharedApp = applicationPath
				Swift.print("The application that the user has selected is: " + applicationPath)
				
            }else{
				cm.sharedSVReallyIsAPFS = false
				
				//sharedVolumeNeedsFormat = nil
				cm.sharedVolumeNeedsPartitionMethodChange = nil
				
				cm.sharedDoTimeMachineWarn = false
				
				if part != nil{
					if part.partScheme != .gUID || !part.hasEFI{
						cm.sharedVolumeNeedsPartitionMethodChange = true
						/*}else{
						sharedVolumeNeedsPartitionMethodChange = false*/
					}
					
					if !sharedInstallMac && part.fileSystem == .aPFS{
						cm.sharedVolumeNeedsPartitionMethodChange = true
					}
					
					if sharedInstallMac && (part.fileSystem == .other || !part.hasEFI){
						cm.sharedVolumeNeedsPartitionMethodChange = true
					}
					
					if part.tmDisk{
						cm.sharedDoTimeMachineWarn = true
					}
					
					
					/*
					if part.fileSystem == "Other" && !sharedVolumeNeedsPartitionMethodChange{
					sharedVolumeNeedsFormat = true
					}else{
					sharedVolumeNeedsFormat = false
					}*/
				}
				
				cm.sharedSVReallyIsAPFS = part.fileSystem == .aPFS_container
				
				cm.currentPart = part
				
				Swift.print("The volume that the user has selected is: " + part.path!)
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
		
		if !isApp{
			if sz == nil{
				if let s = part?.size{
					sz = "Size: \(self.roundInt(number: s))"
				}else{
					sz = "Size: 0 Byte"
				}
			}
		}
		
		DispatchQueue.main.async {
        //self.layer?.backgroundColor = NSColor.white.withAlphaComponent(0).cgColor
		self.isSelected = false
		
			self.appearance = sharedWindow.effectiveAppearance
			self.updateLayer()
			
        if self.isEnabled{
            if self.overlay != nil{
                self.overlay.image = NSImage()
                self.overlay.removeFromSuperview()
                self.overlay = nil
			}
			
			if self.warnText != nil{
				self.warnText.removeFromSuperview()
				self.warnText = nil
			}
			
			if self.warnImage != nil{
				self.warnImage.removeFromSuperview()
				self.warnImage = nil
			}
				
			if self.volume.superview == nil{
				self.addSubview(self.volume)
			}
			
			
			if self.isApp{
				self.toolTip = "Path: " + self.applicationPath
			}else{
				self.toolTip = self.sz
			}
			
        }else{
			
			/*
           	self.overlay = NSImageView(frame: self.image.frame)
            self.overlay.image = IconsManager.shared.unsupportedOverlay
			self.overlay.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
			self.overlay.imageAlignment = .alignBottom
            
            self.addSubview(self.overlay)
			*/
			
			//let y: CGFloat = 15//self.volume.frame.origin.y + ((self.volume.frame.size.width / 2) - ((self.frame.width / 5) / 2))
			//let h: CGFloat = self.image.frame.origin.y - 15 - 3//height: self.frame.width / 5
			let w: CGFloat = self.frame.width / 3
			let margin: CGFloat = 15
			
			self.warnImage = NSImageView(frame: NSRect(x: self.frame.width - w - margin, y: self.image.frame.origin.y, width: w, height: w))
			self.warnImage.image = IconsManager.shared.warningIcon
			self.warnImage.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
			
			self.addSubview(self.warnImage)
			
			self.warnText = NSTextField(frame: self.volume.frame)
			self.warnText.font = self.volume.font
			self.warnText.stringValue = "Damaged app: " + self.volume.stringValue
			self.warnText.isEditable = false
			self.warnText.isBordered = false
			self.warnText.alignment = .center
			self.warnText.textColor = .systemYellow
			(self.warnText as NSView).backgroundColor = NSColor.white.withAlphaComponent(0)
			
			//volume.isSelectable = false
			self.addSubview(self.warnText)
			
			self.volume.removeFromSuperview()
			
			if self.isApp{
				self.toolTip = "This macOS installer app is not usable bacause it's incomplete, you need the full installer app \nwhich weights more than 5 gb\n\nPath: " + self.applicationPath
			}else{
				if sharedInstallMac{
					self.toolTip = "This drive can't be used to\ninstall macOS in it now."
				}else{
					self.toolTip = "This drive can't be used to\ncreate a bootable macOS installer"
				}
			}
        }
		}
        
    }
    
    public func setSelectedAspect(){
		//DispatchQueue.main.async {
			self.isSelected = true
			
			self.updateLayer()
			
		//}
    }
	
	func roundInt(number: UInt64) -> String{
		var n = number
		var div: UInt64 = 1
		
		while n > 1000 {
			div *= 1000
			n = number / div
		}
		
		var suffix = ""
		
		//log10(Double(div))
		switch log10(Double(div)) {
		case 3:
			suffix = "KB"
		case 6:
			suffix = "MB"
		case 9:
			suffix = "GB"
		case 12:
			suffix = "TB"
		case 15:
			suffix = "PB"
		case 0, 1, 2:
			suffix = "Byte"
		default:
			suffix = ""
		}
		
		return "\(n)\(suffix)"
	}
	
}
