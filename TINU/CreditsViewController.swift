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
	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var italianHackGroupLabel: NSTextField!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		print("Setting up CrditsViewController")
		
		let archs = Bundle.main.executableArchitectures!
		var supportedArchs = [NSBundleExecutableArchitectureX86_64: "x86_64", NSBundleExecutableArchitectureI386: "i386", NSBundleExecutableArchitecturePPC: "PPC", NSBundleExecutableArchitecturePPC64: "PPC_64"]
		
		if #available(OSX 11.0, *) {
			supportedArchs[NSBundleExecutableArchitectureARM64] = "ARM64"
		}else{
			supportedArchs[16777228] = "ARM64"
		}
		
		print("Supported architecture values: ")
		print(supportedArchs)
		
		print("Bundle architectures: ")
		print(archs)
		
		versionLabel.stringValue = TextManager.getViewString(context: self, stringID: "version") + Bundle.main.version! + " (" + Bundle.main.build! + ") ( "
		
		for arch in supportedArchs{
			if archs.contains(NSNumber(value: arch.key)){
				versionLabel.stringValue += arch.value + " "
			}
		}
		
		versionLabel.stringValue += ")"
		
        copyrigthLabel.stringValue = Bundle.main.copyright! + TextManager.getViewString(context: self, stringID: "license")
        
        if sharedIsOnRecovery{
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
        if let checkURL = NSURL(string: "https://github.com/ITzTravelInTime/TINU") {
            if NSWorkspace.shared.open(checkURL as URL) {
                print("url successfully opened: " + String(describing: checkURL))
            }
        } else {
            print("invalid url")
        }
    }
	
	@IBAction func openContacts(_ sender: Any) {
		if UIManager.shared.contactsWC == nil {
			UIManager.shared.contactsWC = ContactsWindowController()
		}
		
		UIManager.shared.contactsWC?.showWindow(self)
		
	}
}
