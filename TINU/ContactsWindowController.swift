//
//  ContactsWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ContactsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        //sets window
        self.window?.isFullScreenEnaled = false
        self.window?.title = sharedWindowTitlePrefix + ": Contact us"
        
        if sharedUseVibrant && !sharedIsOnRecovery {
            self.window?.titleVisibility = .hidden
            self.window?.titlebarAppearsTransparent = true
            self.window?.styleMask.insert(.fullSizeContentView)
            self.window?.isMovableByWindowBackground = true
            
            if sharedTestingMode{
                self.window?.titleVisibility = .visible
            }
        }
    }
    
    convenience init() {
        //creates an instace of the window
        self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Contacts") as! NSWindowController).window)
        //self.init(windowNibName: "ContactsWindowController")
    }

}
