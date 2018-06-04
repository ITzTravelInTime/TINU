//
//  AdvancedOptionsButton.swift
//  TINU
//
//  Created by ITzTravelInTime on 11/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa


@IBDesignable class AdvancedOptionsButton: NSButton {
    let margin: CGFloat = 20
    
    @IBInspectable var upperImage = NSImageView()
    @IBInspectable var upperTitle = NSTextField()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        let usableHeigth: CGFloat = self.frame.height - margin
        
        upperImage.frame = NSRect(x: 5, y: margin , width: self.frame.size.width - 10, height: usableHeigth * (3/6) )
        upperImage.imageFrameStyle = .none
        upperImage.imageScaling = .scaleProportionallyUpOrDown
        
        self.addSubview(upperImage)
        
        upperTitle.frame.size = CGSize(width: self.frame.width, height: usableHeigth * (2/6))
        upperTitle.frame.origin = CGPoint(x: 0, y: self.frame.height - (margin / 2) - upperTitle.frame.height)
        upperTitle.isBezeled = false
        upperTitle.isBordered = false
        upperTitle.isEditable = false
        upperTitle.drawsBackground = false
        upperTitle.isSelectable = false
        //upperTitle.font = NSFont.labelFont(ofSize: 13)
        upperTitle.font = NSFont.boldSystemFont(ofSize: 13) 
        upperTitle.usesSingleLineMode = false
        upperTitle.lineBreakMode = .byWordWrapping
        upperTitle.alignment = .center
        
        self.addSubview(upperTitle)
    }
    
}
