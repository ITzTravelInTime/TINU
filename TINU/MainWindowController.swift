//
//  mainWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/05/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class maages the window
public class mainWindowController: GenericWindowController {

    override public func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        
        window?.toolbar = NSApplication.shared().windows[0].toolbar
        
        sharedWindow = self.window
        
        //those functions are executed here and ont into the app delegate, because this is executed first
        checkAppMode()
        checkUser()
        checkSettings()
        
        //we have got all the needed data, so we can setup the look properly
        self.setUI()
    }
    
    public func windowWillClose(_ notification: Notification){
        NSApplication.shared().terminate(self)
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        if sharedIsCreationInProgress{
            if !dialogYesNo(question: "Stop the process?", text: "Do you want to abort the Installer cration process?", style: .informational){
                if let w = self.contentViewController as? InstallingViewController{
                    w.stop()
                    return true
                }
            }
        }
        
        if sharedIsPreCreationInProgress{
            return false
        }
        
        return true
    }
    
}
