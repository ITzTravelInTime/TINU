//
//  EFIPartitionMounterWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 08/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

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
		
		/*
        #if TINU
        
		self.window?.title += ": EFI partition mounter"
        
        #else
        
        
        self.window?.title = "EFI partition mounter"
        
        //self.window = (NSStoryboard(name: "EFIPartitionMounterStoryboard", bundle: Bundle.main).instantiateController(withIdentifier: "EFIMounterWindow") as! NSWindowController).window
        
        #endif
		*/
		
			//print(toolBar.items)
		
		/*
		#if TINU
		menuBarModeToolBarItem.isEnabled = false
		for i in 0..<toolBar.items.count{
			if toolBar.items[i].itemIdentifier == menuBarModeToolBarItem.itemIdentifier{
				toolBar.removeItem(at: i)
			}
		}
		#endif
		*/
		
		guard let controller = self.window?.contentViewController as? EFIPartitionMounterViewController else { return }
		self.window?.title = EFIPMTextManager.getViewString(context: controller, stringID: "title")
		self.reloadToolBarItem.label = EFIPMTextManager.getViewString(context: controller, stringID: "refreshButton")
		
		/*
		//TODO: Use Tcon for this
		if controller.barMode{
			menuBarModeToolBarItem.label = EFIPMTextManager.getViewString(context: controller, stringID: "windowMode")
			if #available(macOS 11.0, *) {
				menuBarModeToolBarItem.image = NSImage(systemSymbolName: "menubar.arrow.down.rectangle", accessibilityDescription: nil)
			} else {
				menuBarModeToolBarItem.image = NSImage(named: "menubar.arrow.down.rectangle")
			}
		}else{
			menuBarModeToolBarItem.label = EFIPMTextManager.getViewString(context: controller, stringID: "toolbarMode")
			if #available(macOS 11.0, *) {
				menuBarModeToolBarItem.image = NSImage(systemSymbolName: "menubar.arrow.up.rectangle", accessibilityDescription: nil)
			} else {
				menuBarModeToolBarItem.image = NSImage(named: "menubar.arrow.up.rectangle")
			}
		}*/
		
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
