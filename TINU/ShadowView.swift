//
//  ShadowView.swift
//  TINU
//
//  Created by ITzTravelInTime on 25/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate func shadowsColor(isDarkMode: Bool) -> CGColor{
	return (isDarkMode ? NSColor.controlDarkShadowColor : NSColor.controlShadowColor).cgColor //isDarkMode ? CGColor.black : CGColor.init(gray: 0.4, alpha: 1);
}

public class ShadowView: NSView{
	
	func setModeFromCurrentLook(){
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
			switch mode {
			case .shadowedbutton:
				self.shadow = NSShadow()
				self.layer?.shadowRadius = 7
				self.layer?.shadowOffset = CGSize()
				
				self.layer?.shadowPath = CGPath(roundedRect: self.bounds, cornerWidth: 15, cornerHeight: 15, transform: nil)
			
				self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
				self.layer?.borderWidth = 0
				break
			case .borderedButton:
				self.layer?.borderWidth = 2
				break
			default:
				self.layer?.backgroundColor = NSColor.transparent.cgColor
				self.layer?.borderWidth = 0
				
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
		if useBorder{
			self.layer?.borderColor = NSColor.systemGray.cgColor
		}
		
		if !isSelected{
			self.layer?.backgroundColor = (!useBorder ? NSColor.controlBackgroundColor.cgColor : NSColor.transparent.cgColor)
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
		
		self.layer?.cornerRadius = 15
		
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
