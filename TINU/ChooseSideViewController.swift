//
//  chooseSideViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 18/12/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa


class ChooseSideViewController: GenericViewController {

    @IBOutlet weak var createUSBButton: AdvancedOptionsButton!
    
    @IBOutlet weak var installButton: AdvancedOptionsButton!
    
    @IBOutlet weak var titleField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //those functions are executed here and not into the app delegate, because this is executed first
        checkAppMode()
        checkUser()
        checkSettings()
		
		#if demo
			print("You have sucessfully enbled the \"demo\" macro!")
		#endif
		
        #if recovery
            print("Running with Local Authentication APIs supported")
        #endif
		
		#if noFirstAuth
			if !sharedIsOnRecovery{
				print("WARNING: this app has been compiled with the first step authentication disabled, it may be less secure to use!")
				//msgBoxWarning("WARNING", "This app has been compiled with first step authentication disabled, it may be less secure to use, use it at your own risk!")
			}
		#endif
        
        //code setup
        
        if let w = sharedWindow{
            w.title = sharedWindowTitlePrefix
        }
		
        //ui setup
        
        createUSBButton.upperImage.image = NSImage(named: "Removable")
        createUSBButton.upperTitle.stringValue = "Create a bootable\nmacOS install media"
        
        installButton.upperImage.image = NSImage(named: "OSInstall")
        installButton.upperTitle.stringValue = "Install macOS"
		
		
        
        if sharedIsOnRecovery{
            //titleField.stringValue = "TINU (TINU Is Not Unib***t): The macOS tool"
            /*let delta = (self.view.frame.size.width - (createUSBButton.frame.size.width * 2)) / 4
            
            createUSBButton.frame.origin.x = delta
            
            installButton.frame.origin.x = (delta * 3) + createUSBButton.frame.size.width*/
            
            installButton.isHidden = false
        }else{
            createUSBButton.frame.origin.x = self.view.frame.width / 2 - createUSBButton.frame.width / 2
            installButton.isHidden = true
        }
        
    }
	
	override func viewWillAppear() {
		if !sharedIsOnRecovery{
			DispatchQueue.global(qos: .background).async {
				self.openSubstituteWindow(windowStoryboardID: "Info", sender: self.view)
			}
			return
		}
	}
    
    @IBAction func createUSB(_ sender: Any) {
        if let apd = NSApplication.shared().delegate as? AppDelegate{
            apd.swichMode(isInstall: false)
        }
    }
    
    @IBAction func install(_ sender: Any) {
        if let apd = NSApplication.shared().delegate as? AppDelegate{
            apd.swichMode(isInstall: true)
        }
    }
}
