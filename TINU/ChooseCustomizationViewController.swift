//
//  ChooseCustomizationViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 19/02/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//


//useless stuff
import Cocoa

class ChooseCustomizationViewController: GenericViewController {
	@IBOutlet weak var infoText: NSTextField!
    @IBOutlet weak var infoImage: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: "")
		self.showTitleLabel()
        
        infoImage.image = IconsManager.shared.infoIcon
		
		if sharedInstallMac{
			titleLabel.stringValue = "Choose the options for the macOS installation"
			infoText.stringValue = "The reccommended default options will: install macOS, apply the icon of the installer app to the target volume, copy create a copy of TINU in /Applications, create the \"README\" file, and reboot the computer"
		}
    }
    
    @IBAction func useCustom(_ sender: Any) {
		DispatchQueue.main.async {
			
			cvm.shared.sharedMediaIsCustomized = true
			self.sawpCurrentViewController(with: "Customize", sender: sender)
		}
    }
    
    @IBAction func useDefault(_ sender: Any) {
		DispatchQueue.main.async {
			
			//restoreOtherOptions()
			checkOtherOptions()
		
			cvm.shared.sharedMediaIsCustomized = false
			self.sawpCurrentViewController(with: "Confirm", sender: sender)
		}
    }
    
    @IBAction func goBack(_ sender: Any) {
		DispatchQueue.main.async {
			if showProcessLicense && sharedInstallMac{
				self.sawpCurrentViewController(with: "License", sender: sender)
			}else{
				self.sawpCurrentViewController(with: "ChoseApp", sender: sender)
			}
		}
    }
}
