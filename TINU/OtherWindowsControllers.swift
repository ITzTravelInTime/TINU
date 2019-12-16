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

public class LogWindowController: NSWindowController {
	
	@IBOutlet weak var saveLogItem: NSToolbarItem!
	@IBOutlet weak var copyLogItem: NSToolbarItem!
	@IBOutlet weak var shareLogItem: NSToolbarItem!
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		//self.window?.title += ": Log"
		
		self.window?.isFullScreenEnaled = true
		
		//this is to make sure we have a valid content view controller, because we don't have a windowdidappear function tom do this stuff, this asically waits in a background thread until we have a valid view controller to work with
		DispatchQueue.global(qos: .background).async {
			var ok = false
			
			while(!ok){
				DispatchQueue.main.sync {
					
					//in here we are sure we have a valid view controller so we do what we will do in a windowdidappear
					if let vc = self.contentViewController as? LogViewController{
						ok = true
						
						//associate buttons with acrtions in the view controller
						self.saveLogItem.target = vc
						self.copyLogItem.target = vc
						self.shareLogItem.target = vc
						
						self.saveLogItem.action = #selector(vc.saveLog(_:))
						self.copyLogItem.action = #selector(vc.copyLog(_:))
						self.shareLogItem.action = #selector(vc.shareLog(_:))
					}
				}
			}
		}
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
	}
	
}
