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

class HorizontalScrollview: NSScrollView{
	
	override func scrollWheel(with event: NSEvent) {
		
		if event.modifierFlags.contains(NSEvent.ModifierFlags.shift){
			super.scrollWheel(with: event)
		}else{
			guard let copy = event.cgEvent?.copy() else { return }
			copy.flags = .init(rawValue: copy.flags.rawValue | CGEventFlags.maskShift.rawValue)
			guard let nevent = NSEvent(cgEvent: copy) else { return }
			super.scrollWheel(with: nevent )
		}
		
	}
	
}
