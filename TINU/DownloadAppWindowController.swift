//
//  DownloadAppWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 17/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class DownloadAppWindowController: GenericWindowController {

    override public func windowDidLoad() {
        super.windowDidLoad()
     self.window?.title += ": Download an installer app"
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	convenience init() {
		//creates an istance of the window
		self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "DownloadAppWindow") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
	
}
