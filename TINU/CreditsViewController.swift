//
//  CreditsViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 08/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import Cocoa
import SwiftCPUDetect

public class CreditsViewController: GenericViewController, ViewID {
	public let id: String = "CreditsViewController"
	
	
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrigthLabel: NSTextField!
    
    @IBOutlet weak var sourceButton: NSButton!
    @IBOutlet weak var contactButton: NSButton!
	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var italianHackGroupLabel: NSTextField!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		print("Setting up CrditsViewController")
		
		//TODO: use the bundle cpu arch support from the swiftcpdetect library
		
		versionLabel.stringValue = TextManager.getViewString(context: self, stringID: "version") + Bundle.main.version! + " (" + Bundle.main.build! + ") ( "
		
		for arch in SwiftCPUDetect.CpuArchitecture.currentExecutableArchitectures() {
				versionLabel.stringValue += arch.rawValue + " "
		}
		
		versionLabel.stringValue += ")"
		
        copyrigthLabel.stringValue = Bundle.main.copyright! + TextManager.getViewString(context: self, stringID: "license")
        
        if Recovery.status{
            contactButton.isEnabled = false
            sourceButton.isEnabled = false
        }
		
		contactButton.title = TextManager.getViewString(context: self, stringID: "contactsButton")
		sourceButton.title = TextManager.getViewString(context: self, stringID: "sourceCodeButton")
		
		closeButton.title = TextManager.getViewString(context: self, stringID: "closeButton")
		
		#if macOnlyMode
			italianHackGroupLabel.isHidden = true
		#endif
		
		print("Setup end")
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
            w.close()
        }
    }
    
    @IBAction func openSource(_ sender: Any) {
		guard let checkURL = NSURL(string: "https://github.com/ITzTravelInTime/TINU") else {
			print("invalid url")
			return
		}
           
		if NSWorkspace.shared.open(checkURL as URL) {
			print("url successfully opened: " + String(describing: checkURL))
		}
    }
	
	@IBAction func openContacts(_ sender: Any) {
		if UIManager.shared.contactsWC == nil {
			UIManager.shared.contactsWC = ContactsWindowController()
		}
		
		//UIManager.shared.contactsWC?.showWindow(self)
		self.window.beginSheet(UIManager.shared.contactsWC!.window!, completionHandler: { response in
			
		})
	}
}
