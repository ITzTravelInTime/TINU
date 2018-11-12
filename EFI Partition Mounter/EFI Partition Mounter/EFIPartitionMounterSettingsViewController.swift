//
//  EFIPartitionMounterSettingsViewController.swift
//  EFI Partition Mounter
//
//  Created by Pietro Caruso on 09/09/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa
import ServiceManagement

public class EFIPartitionMounterSettingsViewController: NSViewController{
    
    let helperBundleName = Bundle.main.bundleIdentifier! + "Launcher"
    
    @IBOutlet weak var autoLaunchCheckbox: NSButton!
    
    @IBAction func toggleAutoLaunch(_ sender: NSButton) {
        let isAuto = (sender.state == 0)
        
        SMLoginItemSetEnabled(helperBundleName as CFString, isAuto)
        
        if isAuto{
            NSWorkspace.shared().launchApplication(Bundle.main.bundlePath + "/Contents/Library/LoginItems/EFIPartitionMounterLauncher.app")
        }else{
            
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let foundHelper = NSWorkspace.shared().runningApplications.contains {
            $0.bundleIdentifier == helperBundleName
        }
        
        autoLaunchCheckbox.state = foundHelper ? 1 : 0
    }

    @IBAction func close(_ sender: NSButton) {
        self.window.close()
    }
    
}
