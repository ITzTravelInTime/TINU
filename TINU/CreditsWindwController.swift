//
//  CreditsWindwController.swift
//  TINU
//
//  Created by ITzTravelInTime on 08/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class CreditsWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //sets the window
        self.window?.isFullScreenEnaled = false
        self.window?.title = sharedWindowTitlePrefix + ": Credits"
        
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
        //creates an istance of the window
        self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Credits") as! NSWindowController).window)
        //self.init(windowNibName: "ContactsWindowController")
    }
    
}
