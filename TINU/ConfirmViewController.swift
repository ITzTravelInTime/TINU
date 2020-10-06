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
	private var ps: Bool!
    //private var fs: Bool!
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
		
		self.showTitleLabel()
		
		if #available(OSX 10.15, *){
			if !isRootUser{
				SIPManager.checkSIPAndLetTheUserKnow()
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
        
        ps = cm.sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
		
		setUI()
	}
	
	func setUI(){
		var drive = false
		
		var state = false
		
		//just to simulate a failure to get data for the drive and the app
		if !simulateConfirmGetDataFail{
			state = !checkProcessReadySate(&drive)
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
				self.setFailureImage(image: IconsManager.shared.warningIcon)
				self.setFailureLabel(text: TextManager.getViewString(context: self, stringID: "failureText"))
			}
			
			self.showFailureImage()
			self.showFailureLabel()
			
			titleLabel.stringValue = TextManager.getViewString(context: self, stringID: "failureTitle")
		}else{
			
			yes.title = TextManager.getViewString(context: self, stringID: "nextButton")
			advancedOptionsButton.stringValue = TextManager.getViewString(context: self, stringID: "optionsButton")
			
			if drive{
				driveImage.image = IconsManager.shared.removableDiskIcon
				driveName.stringValue = dm.getCurrentDriveName()!
				self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "titleDrive"))
			}else{
				let sv = cm.sharedVolume!
				driveImage.image = NSWorkspace.shared().icon(forFile: sv)
				driveName.stringValue = FileManager.default.displayName(atPath: sv)
			}
			
			let sa = cm.sharedApp!
			appImage.image = IconsManager.shared.getInstallerAppIconFrom(path: sa)
			appName.stringValue = FileManager.default.displayName(atPath: sa)
			
			let reps = ["{driveName}" : driveName.stringValue]
			/*
			if sharedInstallMac{
				warningField.stringValue = "If you go ahead, this app will modify the volume you selected \"${driveName}\", and macOS will be installed on it. If you are sure, continue at your own risk."
			}else{
				warningField.stringValue = "If you go ahead, this app will erase \"${driveName}\"! All the data on it will be lost and replaced with the bootable macOS installer. If you are sure, continue at your own risk."
			}*/
			
			warningField.stringValue = parse(messange: TextManager.getViewString(context: self, stringID: "warningText"), keys: reps)
			
		}
	}
    
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    
    @IBAction func goBack(_ sender: Any) {
        cm.sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        /*if sharedInstallMac{
            openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{*/
		#if skipChooseCustomization
			cm.sharedMediaIsCustomized = false
			sawpCurrentViewController(with: "ChoseApp")
		#else
			if cm.sharedMediaIsCustomized{
				openSubstituteWindow(windowStoryboardID: "Customize")
			}else{
            	openSubstituteWindow(windowStoryboardID: "ChooseCustomize")
			}
		#endif
        //}
		
		tmpWin = nil
    }
    
    @IBAction func install(_ sender: Any) {
        cm.sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        if fail{
            NSApp.terminate(sender)
            return
        }
		
		tmpWin = nil
		
        let _ = sawpCurrentViewController(with: "Install")
    }
    
	@IBAction func openAdvancedOptions(_ sender: Any) {
		#if skipChooseCustomization
			//cm.sharedMediaIsCustomized = true
			//openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		
		tmpWin = nil
		tmpWin = sharedStoryboard.instantiateController(withIdentifier: "Customize") as? GenericViewController
		
		if tmpWin != nil{
		self.presentViewControllerAsSheet(tmpWin)
		
		tmpWin.window.isFullScreenEnaled = false
		}
		
		#endif
	}
}
