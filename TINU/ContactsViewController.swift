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

import Cocoa

public class ContactsViewController: GenericViewController, ViewID {
	
	public let id: String = "ContactsViewController"
	
	@IBOutlet weak var italianHackGroupLabel: NSTextField!
	@IBOutlet weak var italianHackGroupLinkLabel: ExternalLinkTextField!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
		self.showTitleLabel()
		
		#if macOnlyMode
			italianHackGroupLabel.stringValue = "Facebook group (Italian):"
			//italianHackGroupLinkLabel.stringValue = ""
		#endif
		
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
			if let sp = w.sheetParent{
				sp.endSheet(w, returnCode: NSApplication.ModalResponse.OK)
			}
			w.close()
        }
    }
    
}
