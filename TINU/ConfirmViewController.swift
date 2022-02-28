/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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
import TINURecovery

class ConfirmViewController: GenericViewController, ViewID {
	let id: String = "ConfirmViewController"
	
	var tmpWin: GenericViewController!
	
	let cm = cvm.shared
	private var fail = false
    
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    	
    @IBOutlet weak var warning: NSImageView!
    
    @IBOutlet weak var warningField: NSTextField!
    
	@IBOutlet weak var advancedOptionsButton: NSButton!
    
	@IBOutlet weak var back: NSButton!
    //private var fs: Bool!
	
	
    override func viewDidAppear() {
        super.viewDidAppear()
        
		if let w = UIManager.shared.window{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            //w.canHide = true
        }
		
		self.showTitleLabel()
		
		/*
		if #available(OSX 10.15, *){
			if !CurrentUser.isRoot{
				SIPManager.checkStatusAndLetTheUserKnow()
			}
		}*/
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
        
        self.hideFailureImage()
		self.hideFailureLabel()
        
		warning.image = IconsManager.shared.warningIcon.themedImage()
		
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			//warning.image = warning.image?.withSymbolWeight(.thin)
			warning.contentTintColor = .systemYellow
		}
        //fs = sharedVolumeNeedsFormat
        
        if let a = NSApplication.shared.delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
		
		setUI()
	}
	
	func setUI(){
		var drive = false
		
		var state = false
		
		//just to simulate a failure to get data for the drive and the app
		if !simulateConfirmGetDataFail{
			state = !cvm.shared.checkProcessReadySate(&drive)
		}else{
			state = true
		}
		
		fail = state
		
		back.stringValue = TextManager.getViewString(context: self, stringID: "backButton")
		
		if state {
			
			advancedOptionsButton.isHidden = true
			
			print("Couldn't get valid info about the installation app and/or the drive")
			//yes.isEnabled = false
			
			yes.title = TextManager.getViewString(context: self, stringID: "nextButtonFail")
			yes.image = NSImage(named: NSImage.refreshTemplateName)
			yes.imagePosition = .imageLeft
			
			back.isHidden = true
			info.isHidden = true
			
			driveName.isHidden = true
			driveImage.isHidden = true
			
			appImage.isHidden = true
			appName.isHidden = true
			
			self.warning.isHidden = true
			
			if self.failureImageView == nil || self.failureLabel == nil{
				self.defaultFailureImage()
				self.setFailureLabel(text: TextManager.getViewString(context: self, stringID: "failureText"))
			}
			
			self.showFailureImage()
			self.showFailureLabel()
			
			titleLabel.stringValue = TextManager.getViewString(context: self, stringID: "failureTitle")
		}else{
			
			if cvm.shared.disk.current.isDrive || cvm.shared.disk.shouldErase{
				self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "titleDrive"))
			}
			
			yes.title = TextManager.getViewString(context: self, stringID: "nextButton")
			advancedOptionsButton.stringValue = TextManager.getViewString(context: self, stringID: "optionsButton")
			
			sharedSetSelectedCreationUI(appName: &appName, appImage: &appImage, driveName: &driveName, driveImage: &driveImage, manager: cvm.shared, useDriveName: drive)
			/*
			if #available(macOS 11.0, *), look.usesSFSymbols(){
				driveImage.image = driveImage.image?.withSymbolWeight(.thin)
				appImage.image = appImage.image?.withSymbolWeight(.thin)
			}
			*/
			
			warningField.stringValue = TextManager.getViewString(context: self, stringID: "warningText").parsed(usingKeys: ["{driveName}" : driveName.stringValue])
			
		}
	}
    
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    
    @IBAction func goBack(_ sender: Any) {
        //sharedVolumeNeedsFormat = fs
        /*if sharedInstallMac{
            openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{*/
		swapCurrentViewController("ChoseApp")
        //}
		
		tmpWin = nil
    }
    
    @IBAction func install(_ sender: Any) {
        //sharedVolumeNeedsFormat = fs
		tmpWin = nil
        if fail{
			let _ = swapCurrentViewController("ChoseDrive")
            return
        }
		
        let _ = swapCurrentViewController("Install")
    }
    
	@IBAction func openAdvancedOptions(_ sender: Any) {
		
			//cm.sharedMediaIsCustomized = true
			//openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		
		tmpWin = nil
		tmpWin = UIManager.shared.storyboard.instantiateController(withIdentifier: "Customize") as? GenericViewController
		
		if tmpWin != nil{
		self.presentAsSheet(tmpWin)
		
		tmpWin.window.isFullScreenEnaled = false
		}
	}
}
