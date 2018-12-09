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
    
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var errorImage: NSImageView!
    
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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		var useAlternate = false
		var apfs = false
        
        errorImage.isHidden = true
        errorLabel.isHidden = true
		
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
            appImage.image = IconsManager.shared.getInstallerAppIcon(forApp: sa)
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
            driveName.stringValue = FileManager.default.displayName(atPath: sr)
			
			if useAlternate{
				driveName.stringValue += " \n(The entire drive \"\(dm.getCurrentDriveName()!)\" will be used)"
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
            
            errorImage.image = IconsManager.shared.warningIcon
            
            errorImage.isHidden = false
            errorLabel.isHidden =  false
            
            titleLabel.stringValue = "Impossible to create the macOS install meadia"
            
            /*let label = NSTextField(frame: NSRect(x: titleLabel.frame.origin.x, y: self.view.frame.size.height / 2 - 15, width: titleLabel.frame.size.width, height: 30))
            label.isEditable = false
            label.isBordered = false
            label.font = NSFont.systemFont(ofSize: 25)
            label.stringValue = "There was an error while getting app and drive data 🙁"
            label.alignment = .center
            label.isSelectable = false
            label.drawsBackground = false
            
            self.view.addSubview(label)*/
        }else{
			
			if useAlternate{
				warningField.stringValue = "If you go ahead, this app will erase the drive \"\(dm.getCurrentDriveName()!)\"! It will be erased because the volume you selected \"\(cvm.shared.currentPart.name)\" belongs to it, but it doesn't use the required GUID format. If you are sure, continue at your own risk."
			}else{
				if sharedInstallMac{
					warningField.stringValue = "If you go ahead, this app will modify the volume you selected \"\(cvm.shared.currentPart.name)\", and macOS will be installed on it. If you are sure, continue at your own risk."
					
				}else{
					warningField.stringValue = "If you go ahead, this app will erase the volume \"\(cvm.shared.currentPart.name)\", so all the data on it will be lost and replaced with the bootable macOS installer. If you are sure, continue at your own risk."
					
				}
			}
			
            print("Everything is ready to start the installer creation process")
        }
        
    }
    
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBAction func goBack(_ sender: Any) {
        cm.sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        /*if sharedInstallMac{
            openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{*/
		#if skipChooseCustomization
			cm.sharedMediaIsCustomized = false
			openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
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
        
        let _ = openSubstituteWindow(windowStoryboardID: "Install", sender: sender)
        
    }
    
	@IBAction func openAdvancedOptions(_ sender: Any) {
		#if skipChooseCustomization
			//cm.sharedMediaIsCustomized = true
			//openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		
		let win = sharedStoryboard.instantiateController(withIdentifier: "Customize") as! GenericViewController
		
		self.presentViewControllerAsSheet(win)
		
		win.window.isFullScreenEnaled = false
		
		if sharedUseVibrant{
			if let w = sharedWindow.windowController as? GenericWindowController{
				w.deactivateVibrantWindow()
			}
		}
		#endif
	}
}
