//
//  EFIPartitionMounterCompletingViewControllers.swift
//  EFI Partition Mounter
//
//  Created by Pietro Caruso on 10/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class AboutEFIPartitionMounter: AppVC{
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrigthLabel: NSTextField!
    
    @IBOutlet weak var sourceCodeButton: NSButton!
    @IBOutlet weak var contactUsButton: NSButton!
    
    @IBOutlet weak var appIcon: NSImageView!
    
    @IBAction func closeClick(_ sender: Any) {
        self.window.close()
    }
    
    @IBAction func viewSourceCode(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://github.com/ITzTravelInTime/EFI-Partition-Mounter")!)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceCodeButton.isEnabled = !sharedIsOnRecovery
        
        contactUsButton.isEnabled = !sharedIsOnRecovery
        
        versionLabel.stringValue = "Version: " + Bundle.main.version! + " (" + Bundle.main.build! + ")"
        
        copyrigthLabel.stringValue = Bundle.main.copyright!
        
    }
}

public class ContactUsEFIPartitionMounter: AppVC{
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeClick(_ sender: Any) {
        self.window.close()
    }
}
