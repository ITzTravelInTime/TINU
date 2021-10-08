/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
		
		if self.stringValue.isEmpty{
			self.stringValue = href
		}
		
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
