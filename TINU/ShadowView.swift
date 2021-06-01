//
//  ShadowView.swift
//  TINU
//
//  Created by ITzTravelInTime on 25/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class ShadowView: NSView{
	
	func setModeFromCurrentLook(){
		switch look{
		case .bigSurUp:
			mode = .borderedButton
			//mode = .shadowedbutton
			break
		case .yosemiteToCatalina:
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
			draw(self.bounds)
		}
	}
	
	func updateColors(){
		self.layer?.needsDisplay()
		
		self.needsDisplay = true
		self.needsLayout = true
		
		switch mode {
		case .shadowedbutton:
			self.layer?.shadowColor = (isDarkMode ? NSColor.controlDarkShadowColor : NSColor.controlShadowColor).cgColor //isDarkMode ? CGColor.black : CGColor.init(gray: 0.4, alpha: 1);
			self.layer?.backgroundColor = isSelected ? NSColor.selectedControlColor.cgColor : NSColor.controlBackgroundColor.cgColor
			break
		case .borderedButton:
			self.layer?.borderColor = NSColor.systemGray.cgColor
			if #available(macOS 10.14, *) {
				self.layer?.backgroundColor = isSelected ? NSColor.controlAccentColor.cgColor : NSColor.transparent.cgColor
			} else {
				self.layer?.backgroundColor = isSelected ? NSColor.selectedMenuItemColor.cgColor : NSColor.transparent.cgColor
			}
			break
		default:
			self.layer?.backgroundColor = isSelected ? NSColor.selectedControlColor.cgColor : NSColor.transparent.cgColor
			break
		}
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.wantsLayer = true
		self.needsDisplay = true
		self.needsLayout = true
		
		self.layer?.cornerRadius = 15
		
		switch mode {
		case .shadowedbutton:
			self.shadow = NSShadow()
		
			self.layer?.shadowColor = isDarkMode ? CGColor.black : CGColor.init(gray: 0.4, alpha: 1);
			self.layer?.shadowRadius = 7
			self.layer?.shadowOffset = CGSize()
			
			self.layer?.shadowPath = CGPath(roundedRect: self.bounds, cornerWidth: 15, cornerHeight: 15, transform: nil)
		
			self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
			//self.layer?.masksToBounds = true
			break
		case .borderedButton:
			self.layer?.borderWidth = 2
			self.layer?.masksToBounds = true
			break
		default:
			self.layer?.backgroundColor = NSColor.transparent.cgColor
			break
		}
		
		updateColors()
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
			self.layer?.shadowColor = isDarkMode ? CGColor.black : CGColor.init(gray: 0.4, alpha: 1)
		}
	}
}
