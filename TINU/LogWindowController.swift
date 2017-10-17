//
//  LogWindow.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

import Cocoa

class LogWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //sets window
        self.window?.isFullScreenEnaled = false
        self.window?.title = sharedWindowTitlePrefix + ": Log"
        
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
        self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
        //self.init(windowNibName: "ContactsWindowController")
    }
    
}
