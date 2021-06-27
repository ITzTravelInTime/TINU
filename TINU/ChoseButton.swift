//
//  ChoseButton.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa


@IBDesignable class ChoseButton: NSButton {
	
	@IBInspectable var cImage: NSImageView = NSImageView()
	@IBInspectable var cTitle: NSTextField = NSTextField()
	@IBInspectable var fullSizeImage: Bool = false
	@IBInspectable var lowerText: Bool = false
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.wantsLayer = true
		
		self.title = ""
		self.image = nil
		
		let margin: CGFloat = 20
		
		cTitle.frame.size = CGSize(width: self.frame.width, height: self.frame.height * (2/6))
		cTitle.frame.origin = CGPoint(x: 0, y: lowerText ? (self.frame.height - cTitle.frame.height) : margin)
		
		if !fullSizeImage{
			cImage.frame.size = CGSize(width: self.frame.size.width - (margin / 2), height: self.frame.height - self.cTitle.frame.height - (margin * 2))
			cImage.frame.origin = CGPoint(x: 5, y: (lowerText ? (self.frame.height - cImage.frame.size.height - self.cTitle.frame.height - margin) : margin))
		}else{
			cImage.frame.origin = CGPoint.zero
			cImage.frame.size = self.frame.size
		}
		
		cImage.isHighlighted = false
		cImage.isEditable = false
		cImage.imageFrameStyle = .none
		cImage.imageScaling = .scaleProportionallyUpOrDown
		
		if cImage.superview == nil{
			self.addSubview(cImage)
		}
		
		//cTitle.frame.origin = CGPoint(x: 0, y: self.frame.height - (margin / 2) - cTitle.frame.height)
		
		cTitle.isBezeled = false
		cTitle.isBordered = false
		cTitle.isEditable = false
		cTitle.drawsBackground = false
		cTitle.isSelectable = false
		//title.font = NSFont.labelFont(ofSize: 13)
		if look.usesSFSymbols(){
			cTitle.font = NSFont.systemFont(ofSize: 13)
		}else{
			cTitle.font = NSFont.boldSystemFont(ofSize: 13)
		}
		
		cTitle.usesSingleLineMode = false
		cTitle.lineBreakMode = .byWordWrapping
		cTitle.alignment = .center
		
		if cTitle.superview == nil{
			self.addSubview(cTitle)
		}
		
		if look == .recovery{
			self.isBordered = true
		}else{
			let target: ShadowView? = self.superview as? ShadowView
			
			self.isBordered = false
			self.layer?.masksToBounds = true
			self.layer?.backgroundColor = NSColor.transparent.cgColor
			
			if !look.supportsShadows() && look.usesSFSymbols(){
				self.layer?.borderWidth = 0
			}
			
			if target != nil{
				target?.isSelected = isHighlighted
			}
			
			if !isHighlighted {
				if target == nil{
					self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
				}
				cTitle.textColor = NSColor.textColor
				if #available(macOS 10.14, *), look.usesSFSymbols(){
					cImage.contentTintColor = .systemGray
				}
			} else {
				
				if #available(macOS 10.14, *), look.usesSFSymbols(){
					cTitle.textColor = NSColor.alternateSelectedControlTextColor
					cImage.contentTintColor = NSColor.alternateSelectedControlTextColor
					if target == nil{
						self.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
					}
				}else{
					cTitle.textColor = NSColor.textColor
					if target == nil{
						self.layer?.backgroundColor = NSColor.selectedTextBackgroundColor.cgColor
					}
				}
			}
			
		}
	}
    
}
