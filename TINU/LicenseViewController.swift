//
//  LicenseViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 06/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

public var showProcessLicense = false

public var processLicense = ""

class LicenseViewController: ShadowViewController {
    
    @IBOutlet var licenseField: NSTextView!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var scroller: NSScrollView!
	
	@IBOutlet weak var check: NSButton!
	
	@IBOutlet weak var continueButton: NSButton!
	
	@IBOutlet weak var backButton: NSButton!
	
    /*override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        
        if styleView != nil{
            styleView.isHidden = true
        }
        
        /*if canUseVibrantLook {
            scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
            scroller.borderType = .noBorder
            //scroller.drawsBackground = false
        }else{
            scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
            scroller.borderType = .bezelBorder
            //scroller.drawsBackground = true
        }*/
    }*/
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setTitleLabel(text: "License agreement")
		self.showTitleLabel()
		
		spinner.isHidden = false
		spinner.startAnimation(self)
		scroller.isHidden = true
		
		check.isEnabled = false
		
		if !(sharedIsOnRecovery || simulateDisableShadows){
			scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
			scroller.borderType = .noBorder
			//scroller.drawsBackground = false
			
			setShadowViewsTopBottomOnly(respectTo: scroller, topBottomViewsShadowRadius: 5)
			setOtherViews(respectTo: scroller)
			
			self.topView.isHidden = false
			self.bottomView.isHidden = false
			
			/*
			self.lView.isHidden = false
			self.rView.isHidden = false
			*/
		}
		
		DispatchQueue.global(qos: .background).async {
			
			if showProcessLicense && sharedInstallMac{
				DispatchQueue.main.async {
					self.titleLabel.stringValue = "macOS License Agreement"
					
					self.backButton.title = "Disagree"
				}
				
				if processLicense.isEmpty{
					if let app = cvm.shared.sharedApp, let volume = cvm.shared.sharedVolume{
						var cmd = ""
						
						var noAPFSSupport = true
						
						if let ap = iam.shared.sharedAppNotSupportsAPFS(){
							noAPFSSupport = ap
						}
						
						var mojaveSupport = true
						
						if let ms = iam.shared.sharedAppNotIsMojave(){
							mojaveSupport = !ms
						}
						
						var license = ""
						var counter = 0
						
						var prios = [0,1,2]
						
						if noAPFSSupport{
							prios = [1, 2, 0]
						}
						
						if mojaveSupport{
							prios = [1, 2, 0]
						}
						
						while(license.isEmpty){
							
							switch(counter % prios.count){
							case prios[0]:
								cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\" --applicationpath \"" + app + "\" --volume \"" + volume + "\" --license"
							case prios[1]:
								cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\" --applicationpath \"" + app + "\" --license"
							case prios[2]:
								cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\"  --license"
							default:
								cmd = "\"" + app + "/Contents/Resources/" + sharedExecutableName + "\" --applicationpath \"" + app + "\" --volume \"" + volume + "\" --license"
							}
							
							print("Getting installer license with the command: " + cmd)
							
							license = getOut(cmd: cmd)
							
							counter += 1
							
							if counter == 20{
								license = "Impossible to get the macOS license agreement"
							}
						}
						
						print("Got license agreement")
						
						processLicense = license
						
						print("set procee license variable")
						
						DispatchQueue.main.sync{
							self.licenseField.text = license
							
							print("license assigned")
							
							self.spinner.stopAnimation(self)
							print("stopped spinner")
							self.spinner.isHidden = true
							print("hidden spinner")
							self.scroller.isHidden = false
							print("scoller shown")
							self.check.isEnabled = true
							print("check enabled")
							
							print("License shown")
						}
					}
				}else{
					DispatchQueue.main.async{
						self.spinner.stopAnimation(self)
						self.spinner.isHidden = true
						self.scroller.isHidden = false
						
						self.check.isEnabled = true
					}
					
					self.licenseField?.string = processLicense
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
							let _ = self.sawpCurrentViewController(with: "ChoseDrive", sender: self)
						}
					}
				}else{
					print("Get license error, skipping: license file not found")
					DispatchQueue.main.sync {
						let _ = self.sawpCurrentViewController(with: "ChoseDrive", sender: self)
					}
				}
				
			}
		}
	}
	
    override func viewDidAppear() {
        super.viewDidAppear()
		
		licenseField.textColor = NSColor.textColor
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
		DispatchQueue.main.async {
		self.spinner.isHidden = true
		self.spinner.stopAnimation(self)
		self.scroller.isHidden = false
		if showProcessLicense && sharedInstallMac{
			#if skipChooseCustomization
				let _ = self.sawpCurrentViewController(with: "Confirm", sender: sender)
			#else
				let _ = self.openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
			#endif
		}else{
			let _ = self.sawpCurrentViewController(with: "ChoseDrive", sender: sender)
		}
		}
    }
    
    @IBAction func backPressed(_ sender: Any) {
		
		DispatchQueue.main.async {
		self.spinner.isHidden = true
		self.spinner.stopAnimation(self)
		self.scroller.isHidden = false
		if showProcessLicense && sharedInstallMac{
			showProcessLicense = false
			let _ = self.sawpCurrentViewController(with: "ChoseApp", sender: sender)
		}else{
			showProcessLicense = false
			let _ = self.sawpCurrentViewController(with: "Info", sender: sender)
		}
		}
		
    }
}
