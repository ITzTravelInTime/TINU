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

public class LogWindowController: NSWindowController, ViewID {
	
	public let id: String = "LogWindowController"
	
	@IBOutlet weak var saveLogItem: NSToolbarItem!
	@IBOutlet weak var copyLogItem: NSToolbarItem!
	@IBOutlet weak var shareLogItem: NSToolbarItem!
	
	@IBOutlet weak var saveLogBigItem: NSToolbarItem!
	@IBOutlet weak var copyLogBigItem: NSToolbarItem!
	@IBOutlet weak var shareLogBigItem: NSToolbarItem!
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		
		self.window?.isFullScreenEnaled = true
		
		self.saveLogItem.target = self
		self.copyLogItem.target = self
		self.shareLogItem.target = self
		
		self.saveLogBigItem.target = self
		self.copyLogBigItem.target = self
		self.shareLogBigItem.target = self
		
		self.saveLogItem.action = #selector(self.saveLog(_:))
		self.copyLogItem.action = #selector(self.copyLog(_:))
		self.shareLogItem.action = #selector(self.shareLog(_:))
		
		self.saveLogBigItem.action = #selector(self.saveLog(_:))
		self.copyLogBigItem.action = #selector(self.copyLog(_:))
		self.shareLogBigItem.action = #selector(self.shareLog(_:))
		
		self.saveLogItem.label = TextManager.getViewString(context: self, stringID: "saveButton")
		self.saveLogBigItem.label = self.saveLogItem.label
		
		self.copyLogItem.label = TextManager.getViewString(context: self, stringID: "copyButton")
		self.copyLogBigItem.label = self.copyLogItem.label
		
		self.shareLogItem.label = TextManager.getViewString(context: self, stringID: "shareButton")
		self.shareLogBigItem.label = self.shareLogItem.label
		
		if #available(OSX 11.0, *) {
			self.saveLogItem.image = NSImage(systemSymbolName: "tray.and.arrow.down", accessibilityDescription: nil)
			self.shareLogItem.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)
			self.copyLogItem.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
		} else {
			self.saveLogItem.image = IconsManager.shared.internalDiskIcon
		}
		
		self.saveLogBigItem.image = self.saveLogItem.image
		self.shareLogBigItem.image = self.shareLogItem.image
		self.copyLogBigItem.image = self.copyLogItem.image
		
	}

	@objc func saveLog( _ sender: Any){
		if let vc = self.contentViewController as? LogViewController{
			vc.saveLog(sender)
		}
	}
	
	@objc func copyLog( _ sender: Any){
		if let vc = self.contentViewController as? LogViewController{
			vc.copyLog(sender)
		}
	}
	
	@objc func shareLog( _ sender: Any){
		if let vc = self.contentViewController as? LogViewController{
			vc.shareLog(sender)
		}
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
	}
	
	override public func close() {
		logWindow = nil
		super.close()
	}
	
}
