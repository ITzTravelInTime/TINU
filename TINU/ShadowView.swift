//
//  ShadowView.swift
//  TINU
//
//  Created by ITzTravelInTime on 25/09/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class ShadowView: NSView{
	
	var canShadow = true
	
	override public func viewDidChangeEffectiveAppearance() {
		self.layer?.needsDisplay()
        
        self.needsDisplay = true
        self.needsLayout = true
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.wantsLayer = true
		self.needsDisplay = true
		self.needsLayout = true
		
		if canShadow{
			
		self.shadow = NSShadow()
		
		self.layer?.shadowColor = CGColor.black
		self.layer?.shadowRadius = 10
		self.layer?.shadowOffset = CGSize()
		self.layer?.cornerRadius = 15
		self.layer?.shadowPath = CGPath(roundedRect: self.bounds, cornerWidth: 15, cornerHeight: 15, transform: nil)
		
		}
		
		updateLayer()
	}
	
	override public func updateLayer() {
		super.updateLayer()
		
		if self.canShadow{
			self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
		}else{
			self.layer?.backgroundColor = NSColor.white.withAlphaComponent(0).cgColor
		}
		
	}
}

public class ShadowPanel: NSView{
	
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
				
				self.layer?.shadowColor = CGColor.black
				self.layer?.shadowRadius = customShadowRadius
				self.layer?.shadowOffset = CGSize()
				self.layer?.shadowPath = CGPath(rect: self.bounds, transform: nil)
			}
		}
	}
	
	override public func draw(_ dirtyRect: NSRect) {
		self.backgroundColor = NSColor.windowBackgroundColor
		
	}
}
