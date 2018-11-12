//
//  DriveDetectionInfoWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 06/04/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class DriveDetectInfoWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Why my storage device is not detected?"
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "DriveDetectionInfo") as! NSWindowController).window)
		
		//self.window?.isFullScreenEnaled = false
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class DownloadAppWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Download a macOS installer app from the app store"
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "DownloadApp") as! NSWindowController).window)
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
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Contacts") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class CreditsWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title = ""
	}
	
	convenience init() {
		//creates an istance of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Credits") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}

public class LogWindowController: GenericWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Log"
		
		self.window?.isFullScreenEnaled = !true
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}
