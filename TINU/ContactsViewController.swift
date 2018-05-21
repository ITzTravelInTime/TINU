//
//  ContactsViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

public class ContactsViewController: NSViewController {
	@IBOutlet weak var italianHackGroupLabel: NSTextField!
	@IBOutlet weak var italianHackGroupLinkLabel: HyperTextField!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		#if macOnlyMode
			italianHackGroupLabel.stringValue = "Facebook group (Italian):"
			//italianHackGroupLinkLabel.stringValue = ""
		#endif
		
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
            w.close()
        }
    }
    
}
