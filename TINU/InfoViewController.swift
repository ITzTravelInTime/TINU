//
//  InfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//the first screen of the app, it has just some labels and a button
class InfoViewController: GenericViewController{
    @IBOutlet weak var infoField: NSTextField!
    
    @IBOutlet weak var backButton: NSButton!
    
    @IBOutlet weak var driveIcon: NSImageView!
    @IBOutlet weak var appIcon: NSImageView!
    
    @IBOutlet weak var driveLabel: NSTextField!
    @IBOutlet weak var appLabel: NSTextField!
    
    @IBOutlet weak var titleField: NSTextField!
    
    @IBOutlet weak var tinuLabel: NSTextField!
    @IBOutlet weak var sloganLabel: NSTextField!
    
    @IBOutlet weak var stuffContainer: NSView!
    
    @IBOutlet weak var sep: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		if !sharedIsOnRecovery{
			backButton.isHidden = true
        }else{
            let delta = titleField.frame.origin.y - tinuLabel.frame.origin.y
            
            titleField.frame.origin.y -= delta
            
            stuffContainer.frame.origin.y = sep.frame.origin.y - stuffContainer.frame.size.height
            
            //stuffContainer.frame.origin.y = self.view.frame.height / 2 - stuffContainer.frame.height / 2
            
            sep.isHidden = true
            
            tinuLabel.isHidden = true
            sloganLabel.isHidden = true
        }
        
        if sharedInstallMac{
            
            infoField.stringValue = "This is a tool that helps you to create a macOS install media and also to install macOS\nBefore starting you need:\n   - At least a 20 gb drive or partition\n   - A copy of the macOS installer app (of any version starting from El Capitan) in\n     the root of a storage device connected to the computer"
            
            driveIcon.image = NSImage(named: "Internal")
			
            driveLabel.stringValue = "A drive or partition of 20 GB or higher"
            
            appLabel.stringValue = "A macOS installer app downloaded from the App Store\n(El Capitan or more recent)"
			
			sloganLabel.stringValue = "TINU Is Not Unib***t: The macOS tool"
            
            //titleField.stringValue = "To install macOS you need:"
		}else{
			sloganLabel.stringValue = "TINU Is Not Unib***t: The macOS install media creation tool"
		}
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		#if noFirstAuth
			if !sharedIsOnRecovery{
				msgBoxWarning("WARNING", "This app has been compiled with first step authentication disabled.\nIt may be less secure to use, use it at your own risk!")
			}
		#endif
	}

    @IBAction func ok(_ sender: Any) {
        if sharedShowLicense{
            let _ = openSubstituteWindow(windowStoryboardID: "License", sender: self)
        }else{
            let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
        }
    }

    @IBAction func back(_ sender: Any) {
        openSubstituteWindow(windowStoryboardID: "chooseSide", sender: sender)
    }
}
