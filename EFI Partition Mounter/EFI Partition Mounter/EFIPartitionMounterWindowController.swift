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

#if (!macOnlyMode && TINU) || (!TINU && isTool)

public class EFIPartitionMounterWindowController: NSWindowController, NSToolbarDelegate {
	
	@IBOutlet weak var toolBar: NSToolbar!
	@IBOutlet weak var reloadToolBarItem: NSToolbarItem!
	@IBOutlet weak var reloadToolBarItemButton: NSButton!
	//@IBOutlet weak var menuBarModeToolBarItem: NSToolbarItem!
	
	public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]{
		
		#if TINU
		return [reloadToolBarItem.itemIdentifier, .flexibleSpace, .space]
		#else
		return [reloadToolBarItem.itemIdentifier, menuBarModeToolBarItem.itemIdentifier, .flexibleSpace, .space]
		#endif
	}
	
	public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]{
		#if TINU
		return [.flexibleSpace, reloadToolBarItem.itemIdentifier]
		#else
		return [.flexibleSpace, menuBarModeToolBarItem.itemIdentifier, reloadToolBarItem.itemIdentifier]
		#endif
	}
	
	override public func windowDidLoad() {
		super.windowDidLoad()
        
		toolBar.delegate = self
		
		guard let controller = self.window?.contentViewController as? EFIPartitionMounterViewController else { return }
		self.window?.title = EFIPMTextManager.getViewString(context: controller, stringID: "title")
		self.reloadToolBarItem.label = EFIPMTextManager.getViewString(context: controller, stringID: "refreshButton")
		
		self.window?.isFullScreenEnaled = true
		self.window?.collectionBehavior.insert(.fullScreenNone)
		
		DispatchQueue.global(qos: .userInteractive).async {
			var ok = false
			
			while(!ok){
				
				DispatchQueue.main.sync {
					
					guard let vc = self.contentViewController as? EFIPartitionMounterViewController else{ return }
					
					ok = true
					
					//For somereason connection actions won't work on high sierra and below
					self.reloadToolBarItem.target = vc
					self.reloadToolBarItem.action = #selector(vc.refresh(_:))
					
					self.reloadToolBarItemButton.target = vc
					self.reloadToolBarItemButton.action = #selector(vc.refresh(_:))
					
				}
				
			}
		}
	}
	
	@IBAction func reload(_ sender: NSToolbarItem) {
		if let win = self.window?.contentViewController as? EFIPartitionMounterViewController{
			win.refresh(sender)
		}
	}
	
	@IBAction func toggleMenuBarMode(_ sender: NSToolbarItem) {
		if let win = self.window?.contentViewController as? EFIPartitionMounterViewController{
			win.toggleIconMode(sender)
		}
	}
	
	override public func close() {
		#if TINU
		UIManager.shared.EFIPartitionMonuterTool = nil
		#else
		guard let win = self.window?.contentViewController as? EFIPartitionMounterViewController else { return }
			
		if !win.barMode{
			NSApplication.shared().terminate(self)
		}
		#endif
		
		super.close()
	}
	
    #if !isTool
    
	convenience init() {
		//creates an instace of the window
		self.init(window: (NSStoryboard(name: "EFIPartitionMounterTool", bundle: Bundle.main).instantiateController(withIdentifier: "EFIMounterWindow") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
    
    #endif
    
	
}

#endif
