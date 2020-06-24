//
//  ConfirmViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ConfirmViewController: GenericViewController {
	
	let cm = cvm.shared
    
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    
    @IBOutlet weak var warning: NSImageView!
    
    @IBOutlet weak var warningField: NSTextField!
    
	@IBOutlet weak var advancedOptionsButton: NSButton!
	
    var notDone = false
    
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
		
		self.setTitleLabel(text: "The volume and macOS installer below will be used, are you sure?")
		
		var useAlternate = false
		var apfs = false
        
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
        
        notDone = false
        
        if let sa = cm.sharedApp{
            print(sa)
			appImage.image = IconsManager.shared.getInstallerAppIconFrom(path: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installation app that will be used is: " + sa)
        }else{
            notDone = true
        }
		
        if let sv = cm.sharedVolume{
            print(sv)
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
                if let sb = cm.sharedBSDDrive{
                    if let sd = dm.getDriveNameFromBSDID(sb){
                        sr = sd
                        cm.sharedVolume = sr
                    }else{
                        notDone = true
                    }
                    
                    
                    print("corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
			}else{
				InstallMediaCreationManager.shared.OtherOptionsBeforeformat(canFormat: &useAlternate, useAPFS: &apfs)
			}
            
            driveImage.image = NSWorkspace.shared().icon(forFile: sr)
			
			if useAlternate{
				driveName.stringValue = "\(dm.getCurrentDriveName()!)"
				self.setTitleLabel(text: "The drive and macOS installer below will be used, are you sure?")
			}else{
				driveName.stringValue = FileManager.default.displayName(atPath: sr)
			}
            
            print("The target volume is: " + sr)
			
        }else{
            notDone = true
        }
        
        //just to simulate a failure to get data for the drive and the app
        if simulateConfirmGetDataFail{
            notDone = true
        }
        
        if notDone {
			
			advancedOptionsButton.isHidden = true
			
            print("Couldn't get valid info about the installation app and/or the drive")
            //yes.isEnabled = false
            
            yes.title = "Quit"
            info.isHidden = true
            
            driveName.isHidden = true
            driveImage.isHidden = true
            
            appImage.isHidden = true
            appName.isHidden = true
            
            self.warning.isHidden = true
			
			if self.failureImageView == nil || self.failureLabel == nil{
				self.setFailureImage(image: IconsManager.shared.warningIcon)
				self.setFailureLabel(text: "Error while getting volume/drive and installer app information")
			}
			
			self.showFailureImage()
			self.showFailureLabel()
			
            titleLabel.stringValue = "Impossible to create the macOS install meadia"
        }else{
			
			let vname = useAlternate ? dm.getCurrentDriveName()! : cvm.shared.currentPart.name
			warningField.stringValue = "If you go ahead, this app will erase \"\(vname)\"! All the data on it will be lost and replaced with the bootable macOS installer. If you are sure, continue at your own risk."
			
			if !useAlternate{
				if sharedInstallMac{
					warningField.stringValue = "If you go ahead, this app will modify the volume you selected \"\(cvm.shared.currentPart.name)\", and macOS will be installed on it. If you are sure, continue at your own risk."
				}
			}
			
            print("Everything is ready to start the installer creation process")
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
			sawpCurrentViewController(with: "ChoseApp", sender: sender)
		#else
			if cm.sharedMediaIsCustomized{
				openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
			}else{
            	openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
			}
		#endif
        //}
    }
    
    @IBAction func install(_ sender: Any) {
        cm.sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        if notDone{
            NSApp.terminate(sender)
            return
        }
        
        let _ = sawpCurrentViewController(with: "Install", sender: sender)
        
    }
    
	@IBAction func openAdvancedOptions(_ sender: Any) {
		#if skipChooseCustomization
			//cm.sharedMediaIsCustomized = true
			//openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		
		let win = sharedStoryboard.instantiateController(withIdentifier: "Customize") as! GenericViewController
		
		self.presentViewControllerAsSheet(win)
		
		win.window.isFullScreenEnaled = false
		#endif
	}
}
