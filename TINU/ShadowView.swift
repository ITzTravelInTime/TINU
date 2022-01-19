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

import Cocoa

fileprivate func shadowsColor(isDarkMode: Bool) -> CGColor{
	return (isDarkMode ? NSColor.controlDarkShadowColor : NSColor.controlShadowColor).cgColor //isDarkMode ? CGColor.black : CGColor.init(gray: 0.4, alpha: 1);
}

public class ShadowView: NSView{
	
	private var borderWidth: CGFloat{
		return (HIDPIDetectionManager.numberOfScreens == 1) ? (1 / HIDPIDetectionManager.PointSizeDetector.status) : (HIDPIDetectionManager.isHIDPIEnabledOnAllScreens ? 0.65 : 1)
	}
	
	func setModeFromCurrentLook(){
		
		if look.supportsShadows(){
			mode = .shadowedbutton
		}else if look == .recovery{
			mode = .none
		}else{
			mode = .borderedButton
		}
		
		/*
		switch look{
		case .noShadowsSFSymbols:
			mode = .borderedButton
			//mode = .shadowedbutton
			break
		case .shadowsOldIcons, .shadowsSFSymbols:
			mode = .shadowedbutton
			break
		default:
			mode = .none
			break
		}
		*/
	}
	
	var isSelected = false{
		didSet{
			updateLayer()
		}
	}
	
	enum Mode: UInt8, Equatable, Codable, CaseIterable{
		case shadowedbutton = 0
		case borderedButton
		case none
	}
	
	var mode: Mode = .shadowedbutton{
		didSet{
			self.shadow = nil
			self.layer?.cornerRadius = 15
			self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
			self.layer?.borderWidth = borderWidth
			
			switch mode {
			case .shadowedbutton:
				self.shadow = NSShadow()
				self.layer?.shadowRadius = 5 //7
				//self.layer?.shadowOffset = CGSize()
				self.layer?.shadowOffset = CGSize(width: 0, height: -3)
				
				self.layer?.shadowPath = CGPath(roundedRect: self.bounds, cornerWidth: self.layer?.cornerRadius ?? 15, cornerHeight: self.layer?.cornerRadius ?? 15, transform: nil)
				break
			case .none:
				self.layer?.backgroundColor = NSColor.transparent.cgColor
				self.layer?.borderWidth = 0
				break
			default:
				break
			}
			
			if mode != .shadowedbutton{
				self.layer?.masksToBounds = true
			}
			
			updateColors()
		}
	}
	
	func updateColors(){
		self.layer?.needsDisplay()
		
		self.needsDisplay = true
		self.needsLayout = true
		
		if mode == .shadowedbutton{
			self.layer?.shadowColor = shadowsColor(isDarkMode: isDarkMode)
		}
		
		let useBorder = mode == .borderedButton
		if useBorder || mode == .shadowedbutton{
			self.layer?.borderColor = NSColor.systemGray.cgColor
		}
		
		if !isSelected{
			self.layer?.backgroundColor = /*(!useBorder ?*/ NSColor.controlBackgroundColor.cgColor /*: NSColor.transparent.cgColor)*/
		}else{
			if useBorder || look.usesSFSymbols(){
				if #available(macOS 10.14, *) {
					self.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
				}else{
					self.layer?.backgroundColor = NSColor.selectedMenuItemColor.cgColor
				}
			}else{
				self.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
			}
		}
		
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.wantsLayer = true
		
		setModeFromCurrentLook()
		
	}
	
	override public func viewDidChangeEffectiveAppearance() {
		updateColors()
	}
	
	override public func updateLayer() {
		super.updateLayer()
		
		updateColors()
	}
}

public class ShadowPanel: NSView{
	
	override public func updateLayer() {
		super.updateLayer()
	
		useShadow.toggle()
		useShadow.toggle()
		
	}
	
	var customShadowRadius: CGFloat = 7{
		didSet{
			if useShadow{
				self.layer?.shadowRadius = customShadowRadius
			}
		}
	}
	
	var useShadow = false{
		didSet{
			if useShadow{
				self.wantsLayer = true
				
				self.shadow = NSShadow()
				self.layer?.shadowRadius = self.customShadowRadius
				self.layer?.shadowOffset = CGSize()
				self.layer?.shadowPath = CGPath(rect: self.bounds, transform: nil)
				
				draw(self.bounds)
			}
		}
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		self.backgroundColor = NSColor.windowBackgroundColor
		
		if useShadow{
			self.layer?.shadowColor = shadowsColor(isDarkMode: isDarkMode)
		}
	}
}
