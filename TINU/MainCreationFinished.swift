//
//  MainCreationFinished.swift
//  TINU
//
//  Created by Pietro Caruso on 31/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import Cocoa

class MainCreationFinishedViewController: NSViewController{
    @IBOutlet weak var myTitle: NSTextField!
    
    @IBOutlet weak var image: NSImageView!
    
    @IBOutlet weak var exitButton: NSButton!
    
    @IBOutlet weak var continueButton: NSButton!
    
    //@IBOutlet weak var log: NSScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let w = sharedWindow{
            w.isClosingEnabled = true
            w.isMiniaturizeEnaled = true
        }
        
        if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
        
        myTitle.stringValue = sharedTitle
        
        let notification = NSUserNotification()
        if !sharedIsOk{
            image.image = stopIcon
            exitButton.title = "Quit"
            continueButton.title = "Retry"
            continueButton.isEnabled = true
            continueButton.frame.size.width = exitButton.frame.size.width
            continueButton.frame.origin.x = exitButton.frame.origin.x
            
            notification.title = "macOS install media creation failed"
            notification.informativeText = "The creation process of the macOS install media has failed, see log for more details"
            
            notification.contentImage = stopIcon
        }else{
            image.image = NSImage(named: "check")
            exitButton.title = "Quit"
            continueButton.title = "Create another installer"
            continueButton.isEnabled = true
            continueButton.isHidden = false
            
            notification.title = "macOS install media creation finished"
            notification.informativeText = "The creation process of your macOS install media has been completed with success"
            notification.contentImage = NSImage(named: "check")
        }
        notification.hasActionButton = true
        
        notification.actionButtonTitle = "Close"
        
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }

    @IBAction func exit(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func goNext(_ sender: Any) {
        //if !sharedIsOk {
        clearLog()
        
        if sharedIsOnRecovery{
            openSubstituteWindow(windowStoryboardID: "chooseSide", sender: self)
        }else{
            openSubstituteWindow(windowStoryboardID: "Info", sender: self)
        }
        //}
    }
    
    @IBAction func checkLog(_ sender: Any) {
        /*
        if let b = sender as? NSButton{
            
            if self.log.isHidden{
                b.title = "Hide Log"
                image.frame.size = NSSize(width: image.frame.size.width, height: image.frame.size.height - log.frame.size.height - 8)
                image.frame.origin = NSPoint(x: image.frame.origin.x, y: log.frame.origin.y + log.frame.size.height + 8)
                
            }else{
                b.title = "Show Log"
                
                image.frame.size = NSSize(width: image.frame.size.width, height: image.frame.origin.y - log.frame.origin.y + image.frame.size.height)
                image.frame.origin = NSPoint(x: image.frame.origin.x, y: log.frame.origin.y)
            }
        }
        
        log.isHidden = !log.isHidden
        */
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
 }
    
}

