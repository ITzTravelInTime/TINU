//
//  LicenseViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 06/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

var showProcessLicense = false

var processLicense = ""

class LicenseViewController: GenericViewController {
    
    @IBOutlet weak var continueButton: NSButton!
    
    @IBOutlet var licenseField: NSTextView!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var scroller: NSScrollView!
    
	@IBOutlet weak var titleField: NSTextField!
	
	@IBOutlet weak var check: NSButton!
	
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        
        if styleView != nil{
            styleView.isHidden = true
        }
        
        if canUseVibrantLook {
            scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
            scroller.borderType = .noBorder
            //scroller.drawsBackground = false
        }else{
            scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
            scroller.borderType = .bezelBorder
            //scroller.drawsBackground = true
        }
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		spinner.isHidden = false
		spinner.startAnimation(self)
		scroller.isHidden = true
		
		check.isEnabled = false
		
		DispatchQueue.global(qos: .background).async {
			
			if showProcessLicense && sharedInstallMac{
				self.titleField.stringValue = "macOS License Agreement"
				
				if processLicense == ""{
					if let app = sharedApp, let volume = sharedVolume{
						
						var noAPFSSupport = true
						var cmd = ""
						
						if let ap = sharedAppNotSupportsAPFS(){
							noAPFSSupport = ap
						}
						
						if noAPFSSupport{
							cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\" --applicationpath \"" + app + "\" --volume \"" + volume + "\" --license"
						}else{
							cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\"  --license"
						}
						
						print("Getting installer license with the command: " + cmd)
						
						let license = getOut(cmd: cmd)
						
						DispatchQueue.main.async{
							self.spinner.stopAnimation(self)
							self.spinner.isHidden = true
							self.scroller.isHidden = false
						
							self.check.isEnabled = true
						}
						
						processLicense = license
						
						self.licenseField.text = license
					}
				}else{
					DispatchQueue.main.async{
						self.spinner.stopAnimation(self)
						self.spinner.isHidden = true
						self.scroller.isHidden = false
						
						self.check.isEnabled = true
					}
					
					self.licenseField.text = processLicense
				}
			}else{
				
				if let rtfPath = Bundle.main.url(forResource: "License", withExtension: "rtf") {
					do {
						let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
						DispatchQueue.main.sync {
							self.licenseField.text = attributedStringWithRtf.string
							
							self.spinner.isHidden = true
							self.spinner.stopAnimation(self)
							self.scroller.isHidden = false
							
							self.check.isEnabled = true
						}
						
					} catch let error {
						print("Get license error, skipping: \(error)")
						DispatchQueue.main.sync {
							let _ = self.openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
						}
					}
				}else{
					print("Get license error, skipping: license file not found")
					DispatchQueue.main.sync {
						let _ = self.openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
					}
				}
				
			}
		}
	}
	
    override func viewDidAppear() {
        super.viewDidAppear()
    }
	
    @IBAction func readedChanged(_ sender: Any) {
        if let s = sender as? NSButton{
            if s.state == 1{
                continueButton.isEnabled = true
            }else{
                continueButton.isEnabled = false
            }
        }
    }
	
    @IBAction func continuePressed(_ sender: Any) {
		self.spinner.isHidden = true
		self.spinner.stopAnimation(self)
		self.scroller.isHidden = false
		if showProcessLicense && sharedInstallMac{
			let _ = openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
		}else{
			let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: sender)
		}
    }
    
    @IBAction func backPressed(_ sender: Any) {
		
		
		self.spinner.isHidden = true
		self.spinner.stopAnimation(self)
		self.scroller.isHidden = false
		if showProcessLicense && sharedInstallMac{
			showProcessLicense = false
			let _ = openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{
			showProcessLicense = false
			let _ = openSubstituteWindow(windowStoryboardID: "Info", sender: sender)
		}
    }
}
