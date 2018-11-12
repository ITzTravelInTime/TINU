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
	
	@IBOutlet weak var efiButton: AdvancedOptionsButton!
    
    @IBOutlet weak var titleField: NSTextField!
	
	@IBOutlet weak var spinner: NSProgressIndicator!
	
	let background = NSView()
	
	var count = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		spinner.isHidden = false
		spinner.startAnimation(self)
		
		createUSBButton.isHidden = true
		installButton.isHidden = true
		
        // Do view setup here.
		//DispatchQueue.global(qos: .background).sync {
			//those functions are executed here and not into the app delegate, because this is executed first
			AppManager.shared.checkAppMode()
			AppManager.shared.checkUser()
			AppManager.shared.checkSettings()
		
			#if demo
				print("You have sucessfully enbled the \"demo\" macro!")
			#endif
		
			#if recovery
				print("Running with Local Authentication APIs supported")
			#endif
		
			#if macOnlyMode
				print("This version of the app is compiled to be App Store Friendly!")
			#endif
		
			#if noFirstAuth
				if !sharedIsOnRecovery{
					print("WARNING: this app has been compiled with the first step authentication disabled, it may be less secure to use!")
					//msgBoxWarning("WARNING", "This app has been compiled with first step authentication disabled, it may be less secure to use, use it at your own risk!")
				}
			#endif
			
		//}
		
        //code setup
        
        if let w = sharedWindow{
            w.title = sharedWindowTitlePrefix
        }
		
        //ui setup
        
        createUSBButton.upperImage.image = NSImage(named: "Removable")
        createUSBButton.upperTitle.stringValue = "Create a bootable\nmacOS installer"
        
        installButton.upperImage.image = NSImage(named: "OSInstall")
        installButton.upperTitle.stringValue = "Install macOS"
		
		efiButton.upperImage.image = NSImage(named: "EFIIcon")
		efiButton.upperTitle.stringValue = "Use \nEFI Partition Mounter"
		
        
        /*if sharedIsOnRecovery{
            //titleField.stringValue = "TINU (TINU Is Not Unib***t): The macOS tool"
            /*let delta = (self.view.frame.size.width - (createUSBButton.frame.size.width * 2)) / 4
            
            createUSBButton.frame.origin.x = delta
            
            installButton.frame.origin.x = (delta * 3) + createUSBButton.frame.size.width*/
            
            installButton.isHidden = false
        }else{
            createUSBButton.frame.origin.x = self.view.frame.width / 2 - createUSBButton.frame.width / 2
            installButton.isHidden = true
        }*/
		
		var spacing: CGFloat = 20
		
		if !sharedIsOnRecovery{
			installButton.isEnabled = false
			spacing = (self.view.frame.size.width - (installButton.frame.size.width * 2)) / 3
		}
		
		#if macOnlyMode
			efiButton.isEnabled = false
		#endif
		
		background.frame.size.height = installButton.frame.size.height + 40
		
		background.frame.size.width = spacing//(!sharedIsOnRecovery ? (spacing * 1.25) : spacing)
		
		count = 0
		
		for c in self.view.subviews.reversed(){
			if let b = c as? AdvancedOptionsButton{
				if b.isEnabled{
					
					count += 1
					
					b.frame.size = installButton.frame.size
					b.frame.origin = CGPoint.zero
					b.wantsLayer = true
					
					b.upperTitle.textColor = NSColor.textColor
					
					var shadowView: NSView!
					
					if !(sharedIsOnRecovery || simulateDisableShadows){
						shadowView = ShadowView()
						b.isBordered = false
						
						b.layer?.masksToBounds = true
						b.layer?.cornerRadius = 15
						
					}else{
						shadowView = NSView()
						shadowView.backgroundColor = NSColor.white.withAlphaComponent(0)
					}
					
					shadowView.frame.size = b.frame.size
					
					shadowView.frame.origin = NSPoint(x: background.frame.width, y: 20)
					
					shadowView.needsLayout = true
					
					b.removeFromSuperview()
					
					shadowView.addSubview(b)
					
					b.isHidden = false
					
					background.addSubview(shadowView)
					
					background.frame.size.width += installButton.frame.size.width + spacing//((!sharedIsOnRecovery && count == 1) ? (spacing * 1.25) : spacing)
					
				}else{
					b.isHidden = true
				}
			}
		}
		
		background.frame.origin = NSPoint(x: self.view.frame.width / 2 - background.frame.size.width / 2, y: self.view.frame.height / 2 - background.frame.size.height / 2)
        
    }
	
	override func viewWillAppear() {
		
		if count < 2{
			DispatchQueue.global(qos: .background).async {
				DispatchQueue.main.async {
					self.stopAnimationAndShowbuttons()
					
					
					self.openSubstituteWindow(windowStoryboardID: "Info", sender: self.view)
				}
			}
		}else{
			stopAnimationAndShowbuttons()
		}
	}
	
	func stopAnimationAndShowbuttons(){
		self.spinner.stopAnimation(self)
		self.spinner.isHidden =  true
		
		self.view.addSubview(background)
	}
	
	@IBAction func openEFIMounter(_ sender: Any){
		if let apd = NSApp.delegate as? AppDelegate{
			apd.openEFIPartitionTool(sender)
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
