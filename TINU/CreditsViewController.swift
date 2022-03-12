/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
		
		
		(self.window.windowController as! GenericWindowController).deactivateVibrantWindow()
		
		//UIManager.shared.contactsWC?.showWindow(self)
		self.window.beginSheet(UIManager.shared.contactsWC!.window!, completionHandler: { response in
			(self.window.windowController as! GenericWindowController).activateVibrantWindow()
		})
	}
	
	@IBAction func openLicense(_ sender: Any){
		let vc = (NSStoryboard(name: "Main", bundle: Bundle.main).instantiateController(withIdentifier: "License") as! LicenseViewController)
		
		//vc.sheetMode = true
		
		(self.window.windowController as! GenericWindowController).deactivateVibrantWindow()
		
		let window = NSWindow(contentViewController: vc as NSViewController)
		
		window.maxSize = vc.view.frame.size
		window.minSize = window.maxSize
		
		self.window.beginSheet(window, completionHandler: { response in
			(self.window.windowController as! GenericWindowController).activateVibrantWindow()
		})
	}
}
