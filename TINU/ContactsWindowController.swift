//
//  ContactsWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

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
