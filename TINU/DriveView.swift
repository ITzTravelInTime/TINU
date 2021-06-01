//
//  DriveView.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import AppKit

//this class is an UI object used to represent a drive or a insteller app that can be selected by the user
class DriveView: ShadowView, ViewID {
	let id: String = "DriveView"
	//items size for chose drive and chose app screens
	
	static let itemSize: NSSize = NSSize(width: 130, height: 155)
	
	let cm = cvm.shared
    
    var isEnabled = true{
        didSet{
			DispatchQueue.main.async {
				self.setDefaultAspect()
			}
        }
    }
	
	//var isSelected = false

    public var isApp = false
    public var applicationPath = ""
    
    public var part: Part!
	
	let gradientLayer = CAGradientLayer()
	
	var image: NSImageView!
	var volume: NSTextField!
	
	var warnImage: NSImageView!
	private var warnText: String = ""
	var appName: String = ""
	
	var sz: String!
	
	override func updateLayer() {
		super.updateLayer()
		
		self.appearance = sharedWindow.effectiveAppearance
		
		/*
		if isSelected{
			self.backgroundColor = NSColor.selectedControlColor
		}else{
			self.backgroundColor = NSColor.controlColor
		}
		*/
		
		if image != nil{
			if #available(macOS 11.0, *), look == .bigSurUp{
				if !isSelected{
					image.contentTintColor = .systemGray
				}else{
					image.contentTintColor = .alternateSelectedControlTextColor
				}
			}
		}
		
		if volume != nil{
			if isEnabled{
				if isSelected && look == .bigSurUp{
					self.volume.textColor = .alternateSelectedControlTextColor
				}else{
					self.volume.textColor = .textColor
				}
			}else{
				self.volume.textColor = .systemGray
			}
		}
		
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		//self.appearance = sharedWindow.effectiveAppearance
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
		
		setModeFromCurrentLook()
		
		self.wantsLayer = true
		
		gradientLayer.frame = self.bounds
		gradientLayer.cornerRadius = self.layer!.cornerRadius
		
		if image != nil{
			image.removeFromSuperview();
			image = nil
		}
        
        image = NSImageView(frame: NSRect(x: 15, y: 55, width: self.frame.size.width - 30, height: self.frame.size.height - 65))
		image.wantsLayer = true
        image.isEditable = false
        image.imageAlignment = .alignCenter
        image.imageScaling = .scaleProportionallyUpOrDown
		image.backgroundColor = NSColor.transparent
		
        self.addSubview(image)
		
		image.layer!.zPosition = self.layer!.zPosition + 1
		
		if volume != nil{
			volume.removeFromSuperview();
			volume = nil
		}
        
        volume = NSTextField(frame: NSRect(x: 5, y: 5, width: self.frame.size.width - 10, height: 45))
		volume.wantsLayer = true
		
		if look == .bigSurUp{
			volume.font = NSFont.systemFont(ofSize: 10)
		}else{
			volume.font = NSFont.boldSystemFont(ofSize: 10)
		}
		
		volume.stringValue = ""
        volume.isEditable = false
        volume.isBordered = false
        volume.alignment = .center
		volume.drawsBackground = false
        self.addSubview(volume)
		
		volume.layer!.zPosition = self.layer!.zPosition + 1
        
        volume.isEnabled = isEnabled
        image.isEnabled = isEnabled
		
		self.isSelected = false
		
		updateLayer()
		
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
				}
				
				cm.sharedSVReallyIsAPFS = (part.fileSystem == .aPFS_container)
				cm.currentPart = part
				
				Swift.print("The volume that the user has selected is: " + part.mountPoint!)
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
				
				let s = (part != nil) ? part!.size : 0
				sz = TextManager.getViewString(context: self, stringID: "sizePrefix") + "\(self.roundInt(number: s))"
				
			}
		}
		
		DispatchQueue.main.async {
			//self.layer?.backgroundColor = NSColor.transparent.cgColor
			self.isSelected = false
			
			self.appearance = sharedWindow.effectiveAppearance
			self.updateLayer()
			
			if self.warnImage != nil{
				self.warnImage.image = nil
				self.warnImage.removeFromSuperview()
				self.warnImage = nil
			}
			
			let w: CGFloat = self.frame.width / 3
			//let margin: CGFloat = 15
			
			let activateWarningImage = (look == .bigSurUp) && self.isApp
			
			if activateWarningImage || !self.isEnabled{
			self.warnImage = NSImageView(frame: NSRect(x: self.frame.width - w - 5, y: self.image.frame.origin.y, width: w, height: w))
			self.warnImage.wantsLayer = true
			self.warnImage.layer!.zPosition = self.image.layer!.zPosition + 1
			
			self.warnImage.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
			self.warnImage.imageAlignment = .alignBottom
			}
			
			if self.volume.superview == nil{
				self.addSubview(self.volume)
			}
			
			if self.isEnabled{
				
				self.volume.stringValue = self.appName
				
				if self.isApp{
					//self.toolTip = "Path: " + self.applicationPath
					self.setToolTipAndWarn("appNormal")
				}else{
					self.setToolTipAndWarn("driveNormal")
				}
				
				if activateWarningImage{
					if #available(macOS 11.0, *), look == .bigSurUp{
						self.warnImage.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil)
						self.warnImage.image!.isTemplate = true
						self.warnImage.contentTintColor = .systemGreen
					}else{
						self.warnImage.image = IconsManager.shared.checkIcon
					}
				}
				
			}else{
				
				var notBigger: Bool = false
				
				self.volume.stringValue = self.warnText
				
				if self.isApp{
					if self.sz != nil{
						notBigger = !cvm.shared.compareSize(to: self.sz)
					}
				}
				
				if !notBigger{
					if #available(macOS 11.0, *), look == .bigSurUp{
						self.warnImage.image = NSImage(systemSymbolName: "xmark.octagon.fill", accessibilityDescription: nil)
						self.warnImage.image!.isTemplate = true
						self.warnImage.contentTintColor = .systemRed
					}else{
						self.warnImage.image = IconsManager.shared.stopIcon
					}
				}else{
					if #available(macOS 11.0, *), look == .bigSurUp{
						self.warnImage.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
						self.warnImage.image!.isTemplate = true
						self.warnImage.contentTintColor = .systemYellow
					}else{
						self.warnImage.image = IconsManager.shared.warningIcon
					}
				}
				
				
				
				//self.warnText.textColor = .systemYellow
				
				if notBigger{
					self.setToolTipAndWarn("appTooBig")
				}else if self.isApp{
					if self.sz != nil{
						self.setToolTipAndWarn("appDamaged")
					}else{
						self.setToolTipAndWarn("appError")
					}
				}
				
				if !self.isApp{
					self.toolTip = TextManager.getViewString(context: self, stringID: "driveNotUsableToolTip")
				}
				
			}
			
			if activateWarningImage || !self.isEnabled{
				self.addSubview(self.warnImage)
			}
		}
		
	}
	
	private func setToolTipAndWarn(_ id: String){
		var list: [String: String] = ["{path}" : self.applicationPath, "{name}" : appName]
		
		list["{mount}"] = (self.part != nil) ? ((self.part!.isDrive) ? "" : "\n\n" + self.part!.mountPoint) : ""
		
		list["{size}"] = (self.sz != nil) ? self.sz! : ""
		
		print(list)
		
		self.warnText = parse(messange: TextManager.getViewString(context: self, stringID: id + "Warn") ?? "", keys: list)
		
		self.toolTip = parse(messange: TextManager.getViewString(context: self, stringID: id + "ToolTip") ?? "", keys: list)
		
		Swift.print(self.toolTip!)
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
		default:
			suffix = "Byte"
			n = number
		}
		
		return "\(n) \(suffix)"
	}
	
}
