//
//  ChoseButton.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

/*
struct EmulatedImgView{
	var image: NSImage? = nil
	var contentTintColor: NSColor? = nil
}

struct EmulatedTextField{
	var stringValue: String = ""
}
*/
/*@IBDesignable class NSButtonWithImageSpacing: NSButton {
	
	@IBInspectable var verticalPadding: CGFloat = 0
	@IBInspectable var horizontalPadding: CGFloat = 0
	
	@IBInspectable var topSpacing: CGFloat = -1
	
	override func draw(_ dirtyRect: NSRect) {
		// Reset the bounds after drawing is complete
		let originalBounds = self.bounds
		defer { self.bounds = originalBounds }
		
		// Inset bounds by the image padding
		self.bounds = originalBounds.insetBy(
			dx: horizontalPadding,
			dy: verticalPadding
		)
		
		if topSpacing >= 0{
			self.bounds.origin.y = originalBounds.origin.y + topSpacing
			self.bounds.size.height = originalBounds.size.height - verticalPadding - topSpacing
		}
		
		if #available(macOS 10.14, *), !look.isRecovery() {} else {
			self.frame = self.bounds
		}
		
		super.draw(dirtyRect)
		
	}
}*/

@IBDesignable class ChoseButton: NSButton{//NSButtonWithImageSpacing {
	
	@IBInspectable var cImage: NSImageView = NSImageView()
	@IBInspectable var cTitle: NSTextField = NSTextField()
	//var cImage: EmulatedImgView = EmulatedImgView()
	//var cTitle: EmulatedTextField = EmulatedTextField()
	@IBInspectable var fullSizeImage: Bool = false
	@IBInspectable var lowerText: Bool = false
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		awakeFromNib()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.bezelStyle = .texturedSquare
		self.wantsLayer = true
		
		//cImage.image = self.image
		//cTitle.stringValue = self.title
		
		self.title = ""
		self.image = nil
		
		let margin: CGFloat = 20
		
		//Frames
		cTitle.frame.size = CGSize(width: self.frame.width, height: self.frame.height * (2/6))
		cTitle.frame.origin = CGPoint(x: 0, y: lowerText ? (self.frame.height - cTitle.frame.height) : margin)
		
		if !fullSizeImage{
			cImage.frame.size = CGSize(width: self.frame.size.width - (margin / 2), height: self.frame.height - self.cTitle.frame.height - (margin * 2))
			cImage.frame.origin = CGPoint(x: 5, y: (lowerText ? (self.frame.height - cImage.frame.size.height - self.cTitle.frame.height - margin) : margin))
		}else{
			cImage.frame.origin = CGPoint.zero
			cImage.frame.size = self.frame.size
		}
		
		//Initialization
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
		
		/*
		self.horizontalPadding = 5
		
		//self.title = cTitle.stringValue
		
		if look.usesSFSymbols(){
			self.font = NSFont.systemFont(ofSize: 13)
		}else{
			self.font = NSFont.boldSystemFont(ofSize: 13)
		}
		
		//self.image?.size.width = self.frame.height * (4/6)
		//self.image?.size.height = self.frame.height * (4/6)
		
		self.imageScaling = .scaleProportionallyUpOrDown
		
		if self.fullSizeImage{
			self.imagePosition = .imageBelow
			self.verticalPadding = 0
			self.topSpacing = 20
		}else{
			self.imagePosition = lowerText ? .imageAbove : .imageBelow
			self.verticalPadding = 20
			
			if look.usesSFSymbols(){
				
				var newSize = self.image?.size ?? NSSize(width: 90, height: 90)
				
				if newSize.width != newSize.height{
					if newSize.width > newSize.height{
						// w / h = nw / nh <=> nh * (w / h) = nw <=> nh = nw * (h / l)
						newSize.height = 90 * (newSize.height / newSize.width)
						newSize.width = 90
					}else{
						newSize.width = 90 * (newSize.width / newSize.height)
						newSize.height = 90
					}
				}
				
				
				if #available(macOS 11.0, *){
					self.image = self.image?.resized(to: newSize)?.withSymbolWeight(.ultraLight)
				}else{
					self.image = self.image?.resized(to: newSize)
				}
				
				self.image?.isTemplate = true
				self.imageScaling = .scaleNone
				//self.topSpacing = 40
			}
		}
		
		/*
		if #available(macOS 10.14, *) {
			self.contentTintColor = cImage.contentTintColor
		}
		*/
		
		if look == .recovery{
			self.verticalPadding = 0
			self.horizontalPadding = 0
			self.isBordered = true
			//self.showsBorderOnlyWhileMouseInside = true
			super.draw(dirtyRect)
			return
		}
		*/
		
		if #available(macOS 10.14, *), look.usesSFSymbols(){
			if isHighlighted{
				self.contentTintColor = .alternateSelectedControlTextColor
			}else{
				self.contentTintColor = .systemGray
			}
		}
		
		/*
		if let mutableAttributedTitle = self.attributedTitle.mutableCopy() as? NSMutableAttributedString, !isHighlighted {
			mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.textColor, range: NSRange(location: 0, length: mutableAttributedTitle.length))
			mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.textColor, range: NSRange(location: 0, length: mutableAttributedTitle.length))
			self.attributedTitle = mutableAttributedTitle
		}
		*/
		
		
		self.isBordered = false
		//self.layer?.masksToBounds = true
		self.layer?.backgroundColor = NSColor.transparent.cgColor
		
		if !look.supportsShadows() && look.usesSFSymbols(){
			self.layer?.borderWidth = 0
		}
		
		if let target = self.superview as? ShadowView{
			target.isSelected = isHighlighted
			self.layer?.cornerRadius = target.layer?.cornerRadius ?? 0
		}
		
		
		if !isHighlighted {
			cTitle.textColor = NSColor.textColor
			if #available(macOS 10.14, *), look.usesSFSymbols(){
				cImage.contentTintColor = .systemGray
			}
		} else {
			
			if #available(macOS 10.14, *), look.usesSFSymbols(){
				cTitle.textColor = NSColor.alternateSelectedControlTextColor
				cImage.contentTintColor = NSColor.alternateSelectedControlTextColor
			}else{
				cTitle.textColor = NSColor.textColor
			}
		}
		
		//super.draw(dirtyRect)
		
	}
	
}
