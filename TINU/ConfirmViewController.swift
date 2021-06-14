//
//  ConfirmViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ConfirmViewController: GenericViewController, ViewID {
	let id: String = "ConfirmViewController"
	
	#if skipChooseCustomization
	var tmpWin: GenericViewController!
	#endif
	
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
	private var ps: Bool = false
    //private var fs: Bool!
    override func viewDidAppear() {
        super.viewDidAppear()
        
		if let w = UIManager.shared.window{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
		
		self.showTitleLabel()
		
		if #available(OSX 10.15, *){
			if !isRootUser{
				SIPManager.checkStatusAndLetTheUserKnow()
			}
		}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
        
        self.hideFailureImage()
		self.hideFailureLabel()
		
		#if !skipChooseCustomization
			advancedOptionsButton.isHidden = true
		#endif
        
		warning.image = IconsManager.shared.warningIcon
		
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			warning.image = warning.image?.withSymbolWeight(.light)
			warning.contentTintColor = .systemYellow
		}
        
		ps = cm.disk.shouldErase
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
			
			yes.title = TextManager.getViewString(context: self, stringID: "nextButton")
			advancedOptionsButton.stringValue = TextManager.getViewString(context: self, stringID: "optionsButton")
			
			if drive{
				driveName.stringValue = cvm.shared.disk.driveName()!
				self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "titleDrive"))
			}else{
				let sv = cvm.shared.disk.path!
				driveName.stringValue = FileManager.default.displayName(atPath: sv)
			}
			
			driveImage.image = IconsManager.shared.getCorrectDiskIcon(cvm.shared.disk.bSDDrive)
			
			if #available(macOS 11.0, *), look.usesSFSymbols(){
				driveImage.contentTintColor = .systemGray
				driveImage.image = driveImage.image?.withSymbolWeight(.thin)
			}
			
			let sa = cm.app.path!
			if look.usesSFSymbols(){
				appImage.image = IconsManager.shared.genericInstallerAppIcon
			}else{
				appImage.image = IconsManager.shared.getInstallerAppIconFrom(path: sa)
			}
			
			if #available(macOS 11.0, *), look.usesSFSymbols(){
				appImage.contentTintColor = .systemGray
				appImage.image = appImage.image?.withSymbolWeight(.thin)
			}
			
			appName.stringValue = FileManager.default.displayName(atPath: sa)
			
			let reps = ["{driveName}" : driveName.stringValue]
			
			warningField.stringValue = parse(messange: TextManager.getViewString(context: self, stringID: "warningText"), keys: reps)
			
		}
	}
    
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    
    @IBAction func goBack(_ sender: Any) {
		cm.disk.shouldErase = ps
        //sharedVolumeNeedsFormat = fs
        /*if sharedInstallMac{
            openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{*/
		#if skipChooseCustomization
			swapCurrentViewController("ChoseApp")
		#else
			if cm.disk.usesCustomSettings{
				openSubstituteWindow(windowStoryboardID: "Customize")
			}else{
            	openSubstituteWindow(windowStoryboardID: "ChooseCustomize")
			}
		#endif
        //}
		
		tmpWin = nil
    }
    
    @IBAction func install(_ sender: Any) {
		cm.disk.shouldErase = ps
        //sharedVolumeNeedsFormat = fs
        if fail{
            NSApp.terminate(sender)
            return
        }
		
		tmpWin = nil
		
        let _ = swapCurrentViewController("Install")
    }
    
	@IBAction func openAdvancedOptions(_ sender: Any) {
		#if skipChooseCustomization
			//cm.sharedMediaIsCustomized = true
			//openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		
		tmpWin = nil
		tmpWin = UIManager.shared.storyboard.instantiateController(withIdentifier: "Customize") as? GenericViewController
		
		if tmpWin != nil{
		self.presentAsSheet(tmpWin)
		
		tmpWin.window.isFullScreenEnaled = false
		}
		
		#endif
	}
}
