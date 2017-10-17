//
//  AppDelegate.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var verboseItem: NSMenuItem!
    @IBOutlet weak var verboseItemSpace: NSMenuItem!

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        if sharedIsPreCreationInProgress{
            msgBox("You can't quit now", "You can't quit from TINU now, wait for the format to end or press the cancel button on the windows that asks for the password, and then quit if you want", .informational)
            return NSApplicationTerminateReply.terminateCancel
        }
        
        
        if sharedIsCreationInProgress{
            if !dialogYesNo(question: "Installer creation in progress in progess", text: "The installer creation is inprogress do you want to quit?", style: .warning){
                if let i = sharedWindow.contentViewController as? InstallingViewController{
                    i.stop()
                }
            }else{
                return NSApplicationTerminateReply.terminateCancel
            }
        }
        erasePassword()
        return NSApplicationTerminateReply.terminateNow
    }
    
    @IBOutlet weak var QuitMenuButton: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //checkUser()
        //checkAppMode()
        
        if Bundle.main.url(forResource: "DebugScript", withExtension: "sh") == nil || sharedIsOnRecovery{
        verboseItem.isHidden = true
            verboseItemSpace.isHidden = true
            if !sharedIsOnRecovery{
                print("Verbose mode script not present")
            }else{
                print("Verbose mode not usable under recovery")
            }
        }else{
            verboseItem.isHidden = false
            verboseItemSpace.isHidden = false
            print("Verbose mode script present")
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        if sharedIsCreationInProgress{
            if let i = sharedWindow.contentViewController as? InstallingViewController{
                i.stop()
            }
        }
    }
    @IBAction func OpenGithub(_ sender: Any) {
        if let checkURL = NSURL(string: "https://github.com/ITzTravelInTime/TINU") {
            if NSWorkspace.shared().open(checkURL as URL) {
                print("url successfully opened: " + String(describing: checkURL))
            }
        } else {
            print("invalid url")
        }
    }
    
    @IBAction func InsanelyMacThread(_ sender: Any) {
        if let checkURL = NSURL(string: "http://www.insanelymac.com/forum/topic/326959-tinu-the-macos-installer-creator-app-mac-app/") {
            if NSWorkspace.shared().open(checkURL as URL) {
                print("url successfully opened: " + String(describing: checkURL))
            }
        } else {
            print("invalid url")
        }
    }
    
    private var secondWindowController: ContactsWindowController?
    
    @IBAction func openContacts(_ sender: Any) {
        //open here a window with all the contacts inside
        
        if secondWindowController == nil {
            secondWindowController = ContactsWindowController()
        }
        
        secondWindowController?.showWindow(self)
        
    }
    
    private var creditsWindowController: CreditsWindowController?
    
    @IBAction func openCredits(_ sender: Any) {
        //open here a window with all the credits inside
        
        if creditsWindowController == nil {
            creditsWindowController = CreditsWindowController()
        }
        
        creditsWindowController?.showWindow(self)
        
    }
    
    @IBAction func VoodooTSCSyncConfigurator(_ sender: Any) {
        if let checkURL = NSURL(string: "http://www.insanelymac.com/forum/files/file/744-voodootscsync-configurator/") {
            if NSWorkspace.shared().open(checkURL as URL) {
                print("url successfully opened: " + String(describing: checkURL))
            }
        } else {
            print("invalid url")
        }
    }
    
    @IBAction func openVerbose(_ sender: Any) {
        if !sharedIsCreationInProgress{
        if let f = Bundle.main.url(forResource: "DebugScript", withExtension: "sh"){
            if !sharedIsOnRecovery{
                print("Trying to fix script permitions")
                if let e = getErrWithSudo(cmd: "chmod -R 771 \"" + f.path + "\""){
                    if e == "" || e == "Password:\n" || e == "Password:" {
                        print("Script permitions fixed with success")
                        print("Restarting app with log in the terminal")
                        NSWorkspace.shared().openFile(f.path, withApplication: "Terminal")
                        NSApplication.shared().terminate(self)
                    }else{
                        print("Script permitions fix failed")
                        print("Application not opened: " + e)
                    }
                }else{
                    
                }
            }else{
                //recovery special mode
                print("Restarting app with log in the terminal")
                NSWorkspace.shared().openFile(f.path, withApplication: "Terminal")
                NSApplication.shared().terminate(self)
            }
            
        }else{
            
            }
        }else{
            msgBox("You can't switch mode now", "The macOS install media creation process is currenly running, please cancel the operation or wait the end of the operation before switching mode", .warning)
        }
    }
    
    
}

