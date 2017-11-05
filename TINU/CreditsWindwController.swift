//
//  CreditsWindwController.swift
//  TINU
//
//  Created by ITzTravelInTime on 08/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

public class CreditsWindowController: GenericWindowController {
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title += ": Credits"
    }
    
    convenience init() {
        //creates an istance of the window
        self.init(window: (sharedStoryboard.instantiateController(withIdentifier: "Credits") as! NSWindowController).window)
        //self.init(windowNibName: "ContactsWindowController")
    }
    
}
