//
//  AppDelegate.swift
//  EFI Partition Mounter
//
//  Created by Pietro Caruso on 09/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var relatedToThisAppItem: NSMenuItem!
    @IBOutlet weak var otherAppsItem: NSMenuItem!
    
    @IBOutlet weak var diagnosticsItem: NSMenuItem!
    
    var statusItem: NSStatusItem!

    let popover = NSPopover()
    
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        relatedToThisAppItem.isEnabled = !sharedIsOnRecovery
        
        otherAppsItem.isEnabled = !sharedIsOnRecovery
        
        //NSApp.activate(ignoringOtherApps:true)
        
        DispatchQueue.global(qos: .background).async {
            if startsAsMenu{
                
                /*DispatchQueue.main.async {
                    if let del = NSApp.delegate as? AppDelegate{
                        del.setStatusbarItem()
                        
                    }
                }*/
                
                //return
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
                    self.setStatusbarItem()
                })
                
                
            }
        }
        
    }
    
    public func toggleStatusItem(){
        if statusItem != nil{
            unSetStatusBarItem()
        }else{
            setStatusbarItem()
        }
    }
    
    func setStatusbarItem(){
        if statusItem == nil{
            
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        
            statusItem.length = 40
            
            
            
        if let button = statusItem.button {
            button.title = "EFI"
            
            print(NSFontManager.shared().availableFonts)
            
            button.font = NSFont(name: "SanFranciscoText-Regular", size: 22)
            
            //button.image = NSImage(named:NSImage.Name("MenuIcon"))
            //button.imageScaling = .scaleProportionallyUpOrDown
            
            
            button.action = #selector(togglePopover(_:))
        }
            
            
        
            if let controller = NSStoryboard(name: "EFIPartitionMounterTool", bundle: Bundle.main).instantiateController(withIdentifier: "EFIMounter") as? EFIPartitionMounterViewController{
                
                controller.barMode = true
                
                controller.popover = popover
                
                popover.contentViewController = controller
                
                popover.animates = true
                
            }
            
            self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                if let strongSelf = self, let loc = event?.locationInWindow{
                    if loc.y < 0 || loc.y > (strongSelf.popover.contentViewController?.view.frame.height)! || loc.x < 0 || loc.x > (strongSelf.popover.contentViewController?.view.frame.width)!{
                        
                        if strongSelf.popover.isShown{
                            strongSelf.closePopover(sender: event)
                        }
                        
                    }
                    
                }
                
            }
            
            toggleStartsAsMenu()
                // Put your code which should be executed with a delay here
                //showPopover(sender: self)
                
                DispatchQueue.main.async {
                    if toolMainViewController != nil{
                        toolMainViewController.window.orderOut(self)
                    }
                }
                
                NSApp.setActivationPolicy(.accessory)
                //NSApp.completeStateRestoration()
                //NSApp.activate(ignoringOtherApps: false)
                
            
        }
    }
    
    func unSetStatusBarItem(){
        if let item = statusItem{
            NSStatusBar.system().removeStatusItem(item)
            statusItem = nil
            
            NSApp.setActivationPolicy(.regular)
            
            if toolMainViewController != nil{
                toolMainViewController.window.makeKeyAndOrderFront(self)
            }else{
                //toolMainViewController = (NSStoryboard(name: "EFIPartitionMounterTool", bundle: Bundle.main).instantiateInitialController() as? NSWindowController)?.contentViewController
                //toolMainViewController!.window.windowController!.showWindow(nil)
            }
            
            NSApp.activate(ignoringOtherApps: true)
            
            toggleStartsAsMenu()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func useDiagnosticsMode(_ sender: Any) {
        print("trying to use diagnostics mode")
        if let scriptPath = Bundle.main.url(forResource: "DebugScript", withExtension: "sh") {
            let theScript = "do shell script \"chmod -R 771 \'" + scriptPath.path + "\'\" with administrator privileges"
            
            print(theScript)
            
            let appleScript = NSAppleScript(source: theScript)
            
            if let eventResult = appleScript?.executeAndReturnError(nil){
                if let result = eventResult.stringValue{
                    if result.isEmpty || result == "\n" || result == "Password:"{
                        NSWorkspace.shared().openFile(scriptPath.path, withApplication: "Terminal")
                        NSApplication.shared().terminate(self)
                    }else{
                        print("error with the script output: " + result)
                        msgBoxWarning("Impossible to use diagnostics mode", "Something went wrong when preparing EFI Partition Mounter to be run in diagnostics mode.")
                    }
                }
            }else{
                print("impossible to execute the apple script to prepare the app")
                
                msgBoxWarning("Impossible to use diagnostics mode", "Impossible to prepare EFI Partition Mounter to run in diagnostics mode.")
            }
        }else{
            print("no debug file found!")
            
            msgBoxWarning("Impossible to use diagnostics mode", "Needed files inside EFI Partition Mounter are missing, so the diagnostics mode can't be used, try to download again this app and then retry.")
        }
    }
    
    @IBAction func aboutThisApp(_ sender: Any) {
    
    }
    
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        
        if #available(OSX 10.14, *) {
            popover.appearance = NSAppearance.init(named: (statusItem.button?.effectiveAppearance.bestMatch(from: [NSAppearanceNameAqua, NSAppearanceNameDarkAqua])!)!)!
            
        } else {
            popover.appearance = NSAppearance.init(named: NSAppearanceNameAqua)
        }
        
        if let item = statusItem{
            if let button = item.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }else{
            setStatusbarItem()
            showPopover(sender: sender)
        }
        
        eventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func toggleStartsAsMenu(){
        defaults.set(statusItem != nil, forKey: AppManager.SettingsKeys().startsAsMenuKey)
        startsAsMenu = false
    }
    
    
}

