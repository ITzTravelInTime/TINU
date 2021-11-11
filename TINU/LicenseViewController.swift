/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa
import Command

public var showProcessLicense = false

public var processLicense = ""

class LicenseViewController: ShadowViewController, ViewID {
	let id: String = "LicenseViewController"
	
	public var sheetMode: Bool {
		return self.window?.sheetParent != nil
	}
    
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
		
		if !look.isRecovery(){
			scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
			scroller.borderType = .noBorder
			//scroller.drawsBackground = false
			
			if look.supportsShadows(){
				setShadowViewsTopBottomOnly(respectTo: scroller, topBottomViewsShadowRadius: 5)
				setOtherViews(respectTo: scroller)
			
				self.topView.isHidden = false
				self.bottomView.isHidden = false
			}
			
			/*
			self.lView.isHidden = false
			self.rView.isHidden = false
			*/
		}
		
		DispatchQueue.global(qos: .background).async {
			
			if !(showProcessLicense && cvm.shared.installMac){
				
				guard let rtfPath = Bundle.main.url(forResource: "License", withExtension: "rtf") else{
					print("Get license error, skipping: license file not found")
					DispatchQueue.main.sync {
						let _ = self.swapCurrentViewController("ChoseDrive")
					}
					
					return
				}
					
				do {
					
					let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: rtfPath, options: convertDictionary([NSAttributedString.DocumentAttributeKey.documentType.rawValue: NSAttributedString.DocumentType.rtf.rawValue]), documentAttributes: nil)
					
					DispatchQueue.main.async {
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
				
				
				return
			}
			
			DispatchQueue.main.async {
				self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "macOSLicenseTitle"))
				self.backButton.title = TextManager.getViewString(context: self, stringID: "macOSLicenseBackButton")
			}
			
			if !processLicense.isEmpty{
				DispatchQueue.main.async{
					self.licenseField.text = processLicense
					self.spinner.stopAnimation(self)
					self.spinner.isHidden = true
					self.scroller.isHidden = false
					self.check.isEnabled = true
				}
				return
			}
			
			guard let app = cvm.shared.app.path, let volume = cvm.shared.disk.path else{
				DispatchQueue.main.async{
					self.licenseField.text = processLicense
					self.spinner.stopAnimation(self)
					self.spinner.isHidden = true
					self.scroller.isHidden = false
					self.check.isEnabled = true
				}
				return
			}
			
			print("Getting the license agreement from the installer app")
			
			var cmd: [String] = []
			
			var noAPFSSupport = true
			
			if let ap = cvm.shared.app.info.notSupportsAPFS(){
				noAPFSSupport = ap
			}
			
			var mojaveSupport = true
			
			if let ms = cvm.shared.app.info.isNotMojave(){
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
					cmd += ["--applicationpath", app, "--volume", volume,  "--license"]
				case prios[1]:
					cmd += ["--applicationpath", app, "--license"]
				case prios[2]:
					cmd += ["--license"]
				default:
					cmd = ["--volume", volume,  "--license"]
				}
				
				//print("Getting installer license with the command: " + cmd)
				
				//license = Command.getOut(cmd: cmd) ?? ""
				
				let output = Command.run(cmd: app + "/Contents/Resources/" + cvm.shared.executableName, args: cmd)?.output
				
				//var license = ""
				
				license = ""
				
				for i in output ?? []{
					license += i + "\n"
				}
				
				if !license.isEmpty{
					license.removeLast()
				}
				
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
		
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		if !sheetMode { return }
		
		self.check.isHidden = true
		self.continueButton.isHidden = true
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
		if showProcessLicense && cvm.shared.installMac{
			let _ = self.swapCurrentViewController("Confirm")
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
			
			if self.sheetMode{
				self.window.sheetParent!.endSheet(self.window, returnCode: NSApplication.ModalResponse.OK)
				self.window.close()
				return
			}
			
		if showProcessLicense && cvm.shared.installMac{
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
