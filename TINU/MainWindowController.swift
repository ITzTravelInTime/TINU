//
//  mainWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/05/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class maages the window
class mainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        window?.delegate = self
        
        window?.toolbar = NSApplication.shared().windows[0].toolbar
        
        sharedWindow = self.window
        
        checkAppMode()
        
        checkUser()
        
        if sharedUseVibrant && !sharedIsOnRecovery {
            self.window?.titleVisibility = .hidden
            self.window?.titlebarAppearsTransparent = true
            self.window?.styleMask.insert(.fullSizeContentView)
            self.window?.isMovableByWindowBackground = true
        }
        
        if sharedTestingMode{
            self.window?.title = sharedWindowTitlePrefix
            if sharedUseVibrant && !sharedIsOnRecovery {
                self.window?.titleVisibility = .visible
            }
        }
        
        
    }

    
    func makeStandard(){
        //self.window?.isResizable = true
        
        self.window?.exitFullScreen()
        
        self.window?.isFullScreenEnaled = false
        
    }
    
    func makeEditable(){
        //self.window?.isResizable = false
        
        self.window?.makeFullScreen()
        
        self.window?.isFullScreenEnaled = true
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
        return true
    }
    
}

var sharedWindow: NSWindow!
