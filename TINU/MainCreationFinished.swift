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
        
        myTitle.stringValue = FinalScreenSmallManager.shared.title
        
        let notification = NSUserNotification()
        if !FinalScreenSmallManager.shared.isOk{
            image.image = IconsManager.shared.stopIcon
            exitButton.title = "Quit"
            continueButton.title = "Retry"
            continueButton.isEnabled = true
            continueButton.frame.size.width = exitButton.frame.size.width
            continueButton.frame.origin.x = exitButton.frame.origin.x
			
			exitButton.isHidden = true
            
            notification.title = "Bootable macOS installer creation failed"
            notification.informativeText = "The creation process of the bootable macOS installer has failed, see log for more details"
            
            notification.contentImage = IconsManager.shared.stopIcon
        }else{
            image.image = NSImage(named: "checkVector")
            exitButton.title = "Quit"
            continueButton.title = "Main menu"
            continueButton.isEnabled = true
            continueButton.isHidden = false
            
            notification.title = "Bootable macOS installer creation finished"
            notification.informativeText = "The creation process of your bootable macOS installer has been completed with success"
            notification.contentImage = NSImage(named: "checkVector")
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
        
       // if sharedIsOnRecovery{
            sawpCurrentViewController(with: "chooseSide", sender: self)
        /*}else{
            openSubstituteWindow(windowStoryboardID: "Info", sender: self)
        }*/
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

