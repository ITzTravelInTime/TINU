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
		self.window?.title += ": Why is my storage device not detected?"
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
		self.window?.title += ": Download a macOS installer app from the App Store"
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
	
	@IBOutlet weak var SaveToolBarButton: NSToolbarItem!
	@IBOutlet weak var CopyToolBarButton: NSToolbarItem!
	
	@IBAction func copyLog(_ sender: Any) {
		if let vc = contentViewController as? LogViewController{
			vc.copyLog(sender)
		}
	}
	
	@IBAction func saveLog(_ sender: Any) {
		if let vc = contentViewController as? LogViewController{
			vc.saveLog(sender)
		}
	}
	
	@IBAction func shareLog(_ sender: Any) {
		if let vc = contentViewController as? LogViewController{
			vc.shareLog(sender)
		}
	}
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		self.window?.title += ": Log"
		
		self.window?.isFullScreenEnaled = true
		
		SaveToolBarButton.image = IconsManager.shared.saveIcon
		CopyToolBarButton.image = IconsManager.shared.copyIcon
		
		self.window?.titleVisibility = .hidden
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}
