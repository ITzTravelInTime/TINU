//
//  CopyRightLabel.swift
//  TINU
//
//  Created by Pietro Caruso on 22/04/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Cocoa

public class CopyrightLabel: NSTextField{
	
	let sideMargin: CGFloat = 20
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		if let sWidth = self.superview?.frame.width{
			self.frame.size = CGSize(width: sWidth - (sideMargin * 2), height: 17)
		}
		
		self.frame.origin = CGPoint(x: sideMargin, y: 0)
		
		self.isBezeled = false
		self.isBordered = false
		self.isEditable = false
		self.drawsBackground = false
		self.isSelectable = false
		
		self.font = NSFont.systemFont(ofSize: 9)
		self.usesSingleLineMode = false
		self.lineBreakMode = .byWordWrapping
		self.alignment = .center
		
		self.isHidden = false
		
		self.stringValue = Bundle.main.copyright!
	}
}
