//
//  AdvancedOptionsButton.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa


@IBDesignable class AdvancedOptionsButton: NSButton {
    
	@IBInspectable var cImage: NSImageView = NSImageView()
	@IBInspectable var cTitle: NSTextField = NSTextField()
	
	@IBInspectable var useBottomMargin: Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        //cImage.frame = NSRect(x: 5, y: margin , width: self.frame.size.width - 10, height: usableHeigth * (3/6) )
		let margin: CGFloat = 20
		let conditionalMargin = (useBottomMargin ? margin : 0)
		cTitle.frame.origin = CGPoint(x: 0, y: margin)
		cTitle.frame.size = CGSize(width: self.frame.width, height: self.frame.height * (2/6))
		
		if useBottomMargin{
		cImage.frame.size = CGSize(width: self.frame.size.width - 10, height: self.frame.height - self.cTitle.frame.height - self.cTitle.frame.origin.y - conditionalMargin)
		cImage.frame.origin = CGPoint(x: 5, y: self.frame.height - cImage.frame.size.height - conditionalMargin)
		}else{
			
			cImage.frame.origin = CGPoint.zero
			cImage.frame.size = self.frame.size
			
		}
		
        cImage.imageFrameStyle = .none
        cImage.imageScaling = .scaleProportionallyUpOrDown
        
        self.addSubview(cImage)
		
        //cTitle.frame.origin = CGPoint(x: 0, y: self.frame.height - (margin / 2) - cTitle.frame.height)
		
        cTitle.isBezeled = false
        cTitle.isBordered = false
        cTitle.isEditable = false
        cTitle.drawsBackground = false
        cTitle.isSelectable = false
        //title.font = NSFont.labelFont(ofSize: 13)
        cTitle.font = NSFont.boldSystemFont(ofSize: 13) 
        cTitle.usesSingleLineMode = false
        cTitle.lineBreakMode = .byWordWrapping
        cTitle.alignment = .center
        
        self.addSubview(cTitle)
    }
    
}
