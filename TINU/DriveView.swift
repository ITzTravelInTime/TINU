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
	
	var image: NSImageView!
	var volume: NSTextField!
	
	var warnImage: NSImageView!
	private var warnText: String = ""
	var appName: String = ""
	
	var sz: String!
	
	override func updateLayer() {
		super.updateLayer()
		
		self.appearance = UIManager.shared.window.effectiveAppearance
		
		/*
		if isSelected{
			self.backgroundColor = NSColor.selectedControlColor
		}else{
			self.backgroundColor = NSColor.controlColor
		}
		*/
		
		if image != nil{
			if #available(macOS 11.0, *), look.usesSFSymbols(){
				if isSelected{
					image.contentTintColor = .alternateSelectedControlTextColor
				}else{
					image.contentTintColor = .systemGray
				}
				if warnImage != nil{
					self.warnImage.backgroundColor = NSColor.controlBackgroundColor
					self.warnImage.layer?.cornerRadius = self.warnImage.frame.size.width / 2
				}
			}
		}
		
		if volume != nil{
			if isEnabled{
				if isSelected && look.usesSFSymbols(){
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
		
		self.updateLayer()
    }
	
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
		
		self.appearance = UIManager.shared.window.effectiveAppearance
		
        refreshUI()
		
		//self.wantsLayer = true
		self.needsLayout = true
		self.needsDisplay = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
	
	deinit {
		if volume != nil{
			volume.removeFromSuperview();
			volume = nil
		}
		
		if image != nil{
			image.removeFromSuperview();
			image = nil
		}
		
		if warnImage != nil{
			warnImage.removeFromSuperview();
			warnImage = nil
		}
	}
	
	override func viewDidMoveToSuperview() {
		self.setDefaultAspect()
	}
	
    private func refreshUI(){
		
		setModeFromCurrentLook()
		
		self.wantsLayer = true
		/*
		if image != nil{
			image.removeFromSuperview();
			image = nil
		}
        */
		
		if image == nil{
			image = NSImageView(frame: NSRect(x: 15, y: 55, width: self.frame.size.width - 30, height: self.frame.size.height - 65))
			image.wantsLayer = true
			image.isEditable = false
			image.imageAlignment = .alignCenter
			image.imageScaling = .scaleProportionallyUpOrDown
			image.backgroundColor = NSColor.transparent
		
			self.addSubview(image)
			
			image.layer!.zPosition = self.layer!.zPosition + 1
		}
		
		if volume != nil{
			volume.removeFromSuperview();
			volume = nil
		}
        
        volume = NSTextField(frame: NSRect(x: 5, y: 5, width: self.frame.size.width - 10, height: 45))
		volume.wantsLayer = true
		
		if look.usesSFSymbols(){
			volume.font = NSFont.systemFont(ofSize: 10)
		}else{
			volume.font = NSFont.boldSystemFont(ofSize: 10)
		}
		
		volume.stringValue = ""
        volume.isEditable = false
        volume.isBordered = false
        volume.alignment = .center
		volume.drawsBackground = false
		
		if isEnabled{
			self.volume.stringValue = self.appName
		}else{
			self.volume.stringValue = self.warnText
		}
		
        self.addSubview(volume)
		
		volume.layer!.zPosition = self.layer!.zPosition + 1
        
        volume.isEnabled = isEnabled
        image.isEnabled = isEnabled
		
		if !isApp{
			if sz == nil{
				
				let s = (part != nil) ? part!.size : 0
				sz = TextManager.getViewString(context: self, stringID: "sizePrefix") + "\(self.roundInt(number: s))"
				
			}
		}
		
		if self.warnImage != nil{
			self.warnImage.image = nil
			self.warnImage.removeFromSuperview()
			self.warnImage = nil
		}
		
		let w: CGFloat = self.frame.width / 3
		//let margin: CGFloat = 15
		
		let activateWarningImage = (look.usesSFSymbols()) && self.isApp
		var notBigger: Bool = false
		
		if self.isApp{
			if self.sz != nil{
				notBigger = !cvm.shared.disk.compareSize(to: self.sz)
			}
		}
		
		if activateWarningImage || (!self.isEnabled && self.isApp){
			self.warnImage = NSImageView(frame: NSRect(x: self.frame.width - w - 5, y: self.image.frame.origin.y, width: w, height: w))
			
			self.warnImage.wantsLayer = true
			self.warnImage.layer!.zPosition = self.image.layer!.zPosition + 1
			
			self.warnImage.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
			self.warnImage.imageAlignment = .alignBottom
			
			if isEnabled{
				self.warnImage.image = IconsManager.shared.checkIcon
				
				if #available(macOS 11.0, *), look.usesSFSymbols(){
					self.warnImage.contentTintColor = .systemGreen
				}
			}else{
				
				if !notBigger{
					self.warnImage.image = IconsManager.shared.roundStopIcon
					if #available(macOS 11.0, *), look.usesSFSymbols(){
						self.warnImage.contentTintColor = .systemRed
					}
				}else{
					self.warnImage.image = IconsManager.shared.roundWarningIcon
					if #available(macOS 11.0, *), look.usesSFSymbols(){
						self.warnImage.contentTintColor = .systemYellow
					}
				}
			}
			
			self.addSubview(self.warnImage)
		}
		
		if self.isEnabled{
			
			if self.isApp{
				//self.toolTip = "Path: " + self.applicationPath
				self.setToolTipAndWarn("appNormal")
			}else{
				self.setToolTipAndWarn("driveNormal")
			}
			
		}else{
			
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
		
		updateLayer()
    }
    
    override func mouseDown(with event: NSEvent) {
        
        for c in (self.superview?.subviews)!{
			guard let d = c as? DriveView else { continue }
			
			if d != self{
				d.setDefaultAspect()
			}
        }
        
        if isEnabled{
            setSelectedAspect()
            
            if isApp{
				cm.app.path = applicationPath
				Swift.print("The application that the user has selected is: " + applicationPath)
            }else{
				cm.disk = cvm.DiskInfo(reference: cvm.shared.disk.ref, newPart: part)
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
		
		DispatchQueue.main.async {
			
			self.refreshUI()
			
			self.isSelected = false
			self.updateLayer()
		}
		
	}
	
	public func setSelectedAspect(){
		
		DispatchQueue.main.async {
			
			self.refreshUI()
			
			self.isSelected = true
			self.updateLayer()
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
