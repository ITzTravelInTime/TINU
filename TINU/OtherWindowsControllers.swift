/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

public class DriveDetectInfoWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Why is my storage device not detected?"
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (UIManager.shared.storyboard.instantiateController(withIdentifier: "DriveDetectionInfo") as! NSWindowController).window)
		
		//self.window?.isFullScreenEnaled = false
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class DownloadAppWindowController: NSWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		
		self.window?.isFullScreenEnaled = true
		self.window?.collectionBehavior.insert(.fullScreenNone)
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (UIManager.shared.storyboard.instantiateController(withIdentifier: "DownloadApp") as! NSWindowController).window)
		//self.window?.isFullScreenEnaled = false
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class ContactsWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Contact us"
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (UIManager.shared.storyboard.instantiateController(withIdentifier: "Contacts") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class CreditsWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title = "About " + (self.window?.title ?? "TINU")
	}
	
	convenience init() {
		//creates an istance of the window
		self.init(window: (UIManager.shared.storyboard.instantiateController(withIdentifier: "Credits") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}
