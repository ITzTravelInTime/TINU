//
//  LogWindow.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

public class LogWindowController: GenericWindowController {
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title += ": Log"
    }
    
    convenience init() {
        //creates an instace of the window
        self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
        //self.init(windowNibName: "ContactsWindowController")
    }
    
}
