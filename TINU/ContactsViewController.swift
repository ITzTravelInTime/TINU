//
//  ContactsViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

public class ContactsViewController: NSViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
            w.close()
        }
    }
    
}
