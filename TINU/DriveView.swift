/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

import AppKit

//this class is an UI object used to represent a drive or a insteller app that can be selected by the user
class DriveView: ShadowView, ViewID {
	let id: String = "DriveView"
	//items size for chose drive and chose app screens
	
	static let itemSize: NSSize = NSSize(width: 130, height: 155)
    
    var isEnabled = true{
        didSet{
			if current != nil{
				DispatchQueue.main.async {
					self.setDefaultAspect()
				}
			}
        }
	}
	
	public var current: UIRepresentable?
	
	/*
	public var part: Part!
	public var app: InstallerAppInfo!
	*/
	
	var image = NSImageView()
	var volume = NSTextField()
	var warnImage = NSImageView()
	
	private var warnText: String = ""
	
	override func updateColors() {
		super.updateColors()
		
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			if isSelected{
				image.contentTintColor = .alternateSelectedControlTextColor
			}else{
				image.contentTintColor = .systemGray
			}
			
			
			if warnImage.superview != nil{
				self.warnImage.backgroundColor = NSColor.controlBackgroundColor
				self.warnImage.layer?.cornerRadius = self.warnImage.frame.size.width / 2
			}
			
		}
		
		if image.superview != nil && image.image == nil{
			if image.image == nil{
				image.image = current?.icon
			}
			
			/*
			if #available(macOS 11.0, *), look.usesSFSymbols() {
				image.image = image.image?.withSymbolWeight(.ultraLight)
			}
			*/
		}
		
		image.isEnabled = isEnabled
		
		if isEnabled{
			if isSelected && look.usesSFSymbols(){
				self.volume.textColor = .alternateSelectedControlTextColor
			}else{
				self.volume.textColor = .textColor
			}
		}else{
			self.volume.textColor = .systemGray
		}
		
		if look.usesSFSymbols(){
			volume.font = NSFont.systemFont(ofSize: 10)
		}else{
			volume.font = NSFont.boldSystemFont(ofSize: 10)
		}
		
		volume.isEnabled = isEnabled
		
		var isBigger: Bool = false
		if self.current?.app != nil{
			isBigger = self.current!.app!.status == .tooBig
		}
		
		if warnImage.superview != nil && warnImage.image == nil{
			if isEnabled{
				self.warnImage.image = IconsManager.shared.checkIcon.themedImage()
				if #available(macOS 11.0, *), look.usesSFSymbols(){
					self.warnImage.contentTintColor = .systemGreen
				}
			}else{
				if !isBigger{
					self.warnImage.image = IconsManager.shared.roundStopIcon.themedImage()
					if #available(macOS 11.0, *), look.usesSFSymbols(){
						self.warnImage.contentTintColor = .systemRed
					}
				}else{
					self.warnImage.image = IconsManager.shared.roundWarningIcon.themedImage()
					if #available(macOS 11.0, *), look.usesSFSymbols(){
						self.warnImage.contentTintColor = .systemYellow
					}
				}
			}
		}
		
		if warnText.isEmpty || self.toolTip != nil{
		if self.isEnabled{
			
			if self.current?.app != nil{
				//self.toolTip = "Path: " + self.applicationPath
				self.setToolTipAndWarn("appNormal")
			}else{
				self.setToolTipAndWarn("driveNormal")
			}
			
		}else{
			if self.current?.app == nil{
				switch(self.current?.part?.status ?? .ok){
				case .undefined:
					self.setToolTipAndWarn("driveUnusable")
					 break
				case .tooSmall:
					self.setToolTipAndWarn("driveTooSmall")
					break
				case .belongsToBoot:
					self.setToolTipAndWarn("driveBoot")
					break
				case .runningThisAppFrom:
					self.setToolTipAndWarn("driveTINU")
					break
				case .ok:
					self.setToolTipAndWarn("driveNormal")
					break
				}
			}else{
				if isBigger{
					self.setToolTipAndWarn("appTooBig")
				}else{
					switch (current?.app?.status ?? .usable){
					case .broken:
						self.setToolTipAndWarn("appDamaged")
						break
					case .unsupported:
						self.setToolTipAndWarn("appUnsupported")
						break
					default:
						self.setToolTipAndWarn("appError")
						break
					}
				}
			}
		}
		
		if isEnabled{
			self.volume.stringValue = current!.displayName
		}else{
			self.volume.stringValue = self.warnText
		}
			
		}
	}
	
	deinit {
		image.image = nil
		warnImage.image = nil
	}
	
	override func viewDidMoveToSuperview() {
		self.setDefaultAspect()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		setUI()
		super.draw(dirtyRect)
	}
	
    private func setUI(){
		
		self.appearance = UIManager.shared.window.effectiveAppearance
		
		if image.superview == nil{
			image.frame = (NSRect(x: 15, y: 55, width: self.frame.size.width - 30, height: self.frame.size.height - 65))
			image.wantsLayer = true
			image.isEditable = false
			image.imageAlignment = .alignCenter
			image.imageScaling = .scaleProportionallyUpOrDown
			image.backgroundColor = NSColor.transparent
		
			self.addSubview(image)
			
			image.layer?.zPosition = (self.layer?.zPosition ?? 0) + 1
		}
        
		if volume.superview == nil{
			volume.frame = (NSRect(x: 5, y: 5, width: self.frame.size.width - 10, height: 45))
			volume.wantsLayer = true
			volume.isEditable = false
			volume.isBordered = false
			volume.alignment = .center
			volume.drawsBackground = false
			
			self.addSubview(volume)
			
			volume.layer?.zPosition = (self.layer?.zPosition ?? 0) + 1
		}
		
		if self.current?.app == nil && self.warnImage.superview != nil{
			self.warnImage.image = nil
			self.warnImage.removeFromSuperview()
			self.warnImage = NSImageView()
		}
		
		if ((look.usesSFSymbols() || !self.isEnabled) && self.warnImage.superview == nil){
			let w: CGFloat = self.frame.width / 3
			
			self.warnImage.frame = (NSRect(x: 5, y: self.image.frame.origin.y, width: w, height: w))
			
			self.warnImage.wantsLayer = true
			self.warnImage.layer?.zPosition = (self.image.layer?.zPosition ?? 0) + 1
			
			self.warnImage.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
			self.warnImage.imageAlignment = .alignCenter
			
			self.addSubview(self.warnImage)
		}
    }
    
	override func mouseDown(with event: NSEvent) {
		for case let d as DriveView in self.superview?.subviews ?? [] where d != self{
			
			d.setDefaultAspect()
		}
		
		if self.isEnabled{
			self.setSelectedAspect()
			let cm = cvm.shared
			
			if self.current?.app != nil{
				cm.app.current = self.current?.app
				print("The application that the user has selected is: " + (self.current?.path ?? "[error]"))
			}else if self.current?.part != nil{
				cm.disk.current = self.current?.part
				print("The volume that the user has selected is: " + (self.current!.path ?? ""))
			}
		}
		
		if self.current?.app != nil{
			if let s = self.window?.contentViewController as? ChoseAppViewController{
				s.ok.isEnabled = self.isEnabled
			}
		}else{
			if let s = self.window?.contentViewController as? ChoseDriveViewController{
				s.ok.isEnabled = self.isEnabled
			}
		}
	}
	
	public func setDefaultAspect(){
		
		DispatchQueue.main.async {
			self.isSelected = false
			self.updateColors()
		}
		
	}
	
	public func setSelectedAspect(){
		
		DispatchQueue.main.async {
			self.isSelected = true
			self.updateColors()
		}
		
	}
	
	
	
	private func setToolTipAndWarn(_ id: String){
		var list: [String: String] = ["{path}" : (current?.path ?? ""), "{name}" : (current?.displayName ?? "")]
		
		list["{mount}"] = self.current?.path != nil ? ("\n\n" + self.current!.path!) : ""
		
		var sz: String!
		if self.current?.part != nil{
			sz = TextManager.getViewString(context: self, stringID: "sizePrefix") + "\(self.roundInt(number: self.current?.size ?? 0))"
		}else if self.current?.app != nil{
			sz = String(self.current?.size ?? 0)
		}else{
			return
		}
		
		list["{size}"] = (sz != nil) ? sz! : ""
		
		print(list)
		
		self.warnText = (TextManager.getViewString(context: self, stringID: id + "Warn") ?? "").parsed(usingKeys: list)
		
		if self.warnText.isEmpty{
			self.warnText = current!.displayName
		}
		
		self.toolTip = (TextManager.getViewString(context: self, stringID: id + "ToolTip") ?? "").parsed(usingKeys: list)
		
		if self.toolTip == nil{
			self.toolTip = ""
		}
		
		print(self.toolTip!)
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
