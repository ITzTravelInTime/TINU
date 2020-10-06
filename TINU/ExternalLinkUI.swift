//
//  ExternalLinkMenuItem.swift
//  TINU
//
//  Created by Pietro Caruso on 30/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import AppKit

@IBDesignable
public class ExternalLinkMenuItem: NSMenuItem {
	@IBInspectable var href: String = ""
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		action = #selector(ExternalLinkMenuItem.click(_:))
		target = self
	}
	
	@objc func click(_ sender: Any){
		NSWorkspace.shared().open(URL(string: self.href)!)
	}
}

@IBDesignable
class ExternalLinkTextField: NSTextField {
	@IBInspectable var href: String = ""
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let attributes: [String: AnyObject] = [
			NSForegroundColorAttributeName: NSColor.linkColor
			,NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject, NSCursorAttributeName: NSCursor.pointingHand()
		]
		self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
		
	}
	
	override func mouseDown(with event: NSEvent) {
		NSWorkspace.shared().open(URL(string: self.href)!)
	}
}
