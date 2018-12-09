//
//  mainWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/05/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class manages the window
public class mainWindowController: GenericWindowController {

    override public func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        
        window?.toolbar = NSApplication.shared().windows[0].toolbar
        
        //we have got all the needed data, so we can setup the look properly
        self.setUI()
        
        sharedWindow = self.window
        
        sharedStoryboard = self.storyboard
        
        //self.contentViewController?.viewDidLoad()
        
        /*
        if sharedIsOnRecovery{
            self.contentViewController?.openSubstituteWindow(windowStoryboardID: "chooseSide", sender: self)
        }*/
    }
    
    override public func windowWillClose(_ notification: Notification){
        NSApplication.shared().terminate(self)
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        if CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress{
            //if !dialogYesNoWarning(question: "Stop the process?", text: "Do you want to abort the Installer cration process?", style: .informational){
			
			#if installManager
				return InstallMediaCreationManager.shared.stopWithAsk()
			#else
                if let w = self.contentViewController as? InstallingViewController{
                    return w.stopWithAsk()
                }
			#endif
            //}
        }
        
        if CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress{
            return false
        }
        
        return true
    }
    
}
