//
//  EFIPartitionMounterWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 08/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)

public class EFIPartitionMounterWindowController: AppWindowController {
	
	override public func windowDidLoad() {
		super.windowDidLoad()
        
        #if TINU
        
		self.window?.title += ": EFI partition mounter"
        
        #else
        
        
        self.window?.title = "EFI partition mounter"
        
        //self.window = (NSStoryboard(name: "EFIPartitionMounterStoryboard", bundle: Bundle.main).instantiateController(withIdentifier: "EFIMounterWindow") as! NSWindowController).window
        
        #endif
	}
	
    #if !isTool
    
	convenience init() {
		//creates an instace of the window
		self.init(window: (NSStoryboard(name: "EFIPartitionMounterTool", bundle: Bundle.main).instantiateController(withIdentifier: "EFIMounterWindow") as! NSWindowController).window)
		//self.init(windowNibName: "ContactsWindowController")
	}
    
    #else
    
    public override func windowWillClose(_ notification: Notification){
        if let win = self.window?.contentViewController as? EFIPartitionMounterViewController{
            
            if !win.barMode{
                NSApplication.shared().terminate(self)
            }
        }
    }
    
    #endif
    
	
}

#endif
