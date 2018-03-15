//
//  ChooseCustomizationViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 19/02/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

class ChooseCustomizationViewController: GenericViewController {

    @IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var infoText: NSTextField!
    @IBOutlet weak var infoImage: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoImage.image = infoIcon
		
		if sharedInstallMac{
			titleLabel.stringValue = "Choose macOS installation type"
			infoText.stringValue = "The default settings will: install macOS, apply the icon of the installer app to the target volume, copy TINU in /Applications, create the \"README\" file, and reboot the computer"
		}
    }
    
    @IBAction func useCustom(_ sender: Any) {
		sharedMediaIsCustomized = true
		openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
    }
    
    @IBAction func useDefault(_ sender: Any) {
		restoreOtherOptions()
		eraseReplacementFilesData()
		
		sharedMediaIsCustomized = false
		openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
    }
    
    @IBAction func goBack(_ sender: Any) {
		openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
    }
}
