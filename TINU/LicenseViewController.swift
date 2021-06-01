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

class LicenseViewController: ShadowViewController, ViewID {
	let id: String = "LicenseViewController"
    
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
		
		//self.setTitleLabel(text: "License agreement")
		
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "mainTitle"))
		self.backButton.title = TextManager.getViewString(context: self, stringID: "backButton")
		self.continueButton.title = TextManager.getViewString(context: self, stringID: "agreeButton")
		self.check.title = TextManager.getViewString(context: self, stringID: "checkboxText")
		
		self.showTitleLabel()
		
		spinner.isHidden = false
		spinner.startAnimation(self)
		scroller.isHidden = true
		
		check.isEnabled = false
		
		if look != .recovery{
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
					self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "macOSLicenseTitle"))
					self.backButton.title = TextManager.getViewString(context: self, stringID: "macOSLicenseBackButton")
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
							
							print(license)
							
							counter += 1
							
							if counter == 20{
								license = "Error: Impossible to get the macOS license agreement"
							}
						}
						
						print("Got license agreement")
						
						processLicense = license
						
						print("set procee license variable")
						
						DispatchQueue.main.sync{
							self.licenseField.text = license
							self.spinner.stopAnimation(self)
							self.spinner.isHidden = true
							self.scroller.isHidden = false
							self.check.isEnabled = true
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
						
						let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: rtfPath, options: convertDictionary([NSAttributedString.DocumentAttributeKey.documentType.rawValue: NSAttributedString.DocumentType.rtf.rawValue]), documentAttributes: nil)
						
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
							let _ = self.swapCurrentViewController("ChoseDrive")
						}
					}
				}else{
					print("Get license error, skipping: license file not found")
					DispatchQueue.main.sync {
						let _ = self.swapCurrentViewController("ChoseDrive")
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
            if s.state.rawValue == 1{
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
				let _ = self.swapCurrentViewController("Confirm")
			#else
				let _ = self.swapCurrentViewController("ChooseCustomize")
			#endif
		}else{
			let _ = self.swapCurrentViewController("ChoseDrive")
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
			let _ = self.swapCurrentViewController("ChoseApp")
		}else{
			showProcessLicense = false
			let _ = self.swapCurrentViewController("Info")
		}
		}
		
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}
