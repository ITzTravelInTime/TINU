//
//  AppDelegate.swift
//  EFIPartitionMounterLauncher
//
//  Created by Pietro Caruso on 09/09/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        print("EFI Partition Mounter Launcher Helper")
        
        let runningApps = NSWorkspace.shared().runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == "com.pietrocaruso.TINU.EFIPartitionMounter"
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            
            print(path)
            
            NSWorkspace.shared().launchApplication(path as String)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

