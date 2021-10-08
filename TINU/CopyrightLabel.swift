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
		
		/*
		if #available(macOS 10.11, *) {
			let constraints = [
				self.centerXAnchor.constraint(equalTo: superview!.centerXAnchor)
			]
			
			NSLayoutConstraint.activate(constraints)
		} else {
			// Fallback on earlier versions
		}*/
		
		
		
	}
}
