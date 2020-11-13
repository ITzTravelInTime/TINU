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
		NSWorkspace.shared.open(URL(string: self.href)!)
	}
}

@IBDesignable
class ExternalLinkTextField: NSTextField {
	@IBInspectable var href: String = ""
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let attributes: [String: AnyObject] = [
			NSAttributedString.Key.foregroundColor.rawValue: NSColor.linkColor
			,NSAttributedString.Key.underlineStyle.rawValue: NSUnderlineStyle.single.rawValue as AnyObject, NSAttributedString.Key.cursor.rawValue: NSCursor.pointingHand
		]
		self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
		
	}
	
	override func mouseDown(with event: NSEvent) {
		NSWorkspace.shared.open(URL(string: self.href)!)
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
