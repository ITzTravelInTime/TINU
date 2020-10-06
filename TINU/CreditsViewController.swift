//
//  CreditsViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 08/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import Cocoa

public class CreditsViewController: GenericViewController, ViewID {
	public let id: String = "CreditsViewController"
	
	
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrigthLabel: NSTextField!
    
    @IBOutlet weak var sourceButton: NSButton!
    @IBOutlet weak var contactButton: NSButton!
    
	@IBOutlet weak var italianHackGroupLabel: NSTextField!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
        versionLabel.stringValue = TextManager.getViewString(context: self, stringID: "version") + Bundle.main.version! + " (" + Bundle.main.build! + ")"
        copyrigthLabel.stringValue = Bundle.main.copyright! + TextManager.getViewString(context: self, stringID: "license")
        
        if sharedIsOnRecovery{
            contactButton.isEnabled = false
            sourceButton.isEnabled = false
        }
		
		#if macOnlyMode
			italianHackGroupLabel.isHidden = true
		#endif
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
            w.close()
        }
    }
    
    @IBAction func openSource(_ sender: Any) {
        if let checkURL = NSURL(string: "https://github.com/ITzTravelInTime/TINU") {
            if NSWorkspace.shared().open(checkURL as URL) {
                print("url successfully opened: " + String(describing: checkURL))
            }
        } else {
            print("invalid url")
        }
    }
	
	@IBAction func openContacts(_ sender: Any) {
		if contactsWindowController == nil {
			contactsWindowController = ContactsWindowController()
		}
		
		contactsWindowController?.showWindow(self)
		
	}
}
