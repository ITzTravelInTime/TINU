//
//  ConfirmViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ConfirmViewController: NSViewController {
    
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var warning: NSImageView!
    @IBOutlet weak var background: NSVisualEffectView!
    
    var notDone = false
    
    private var ps: Bool!
    //private var fs: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if sharedIsOnRecovery || !sharedUseVibrant {
            background.isHidden = true
        }
        
        print(sharedVolumeNeedsPartitionMethodChange)
        //print(sharedVolumeNeedsFormat)
        
        ps = sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        if let w = sharedWindow{
            w.isClosingEnabled = true
            w.isMiniaturizeEnaled = true
        }
        
        if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
        
        notDone = false
        
        if let sa = sharedApp{
            print(sa)
            appImage.image = NSWorkspace.shared().icon(forFile: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installation app that will be used is: " + sa)
        }else{
            notDone = true
        }
        
        
        
        if let sv = sharedVolume{
            print(sv)
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
                if let sb = sharedBSDDrive{
                    
                    sr = getDriveNameFromBSDID(sb)
                    sharedVolume = sr
                    
                    print("corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
            }
            
            driveImage.image = NSWorkspace.shared().icon(forFile: sr)
            driveName.stringValue = FileManager.default.displayName(atPath: sr)
            
            print("The target volume is: " + sr)
        }else{
            notDone = true
        }
        
        //just to simulate a failure to get data for the drive and the app
        if simulateConfirmGetDataFail{
            notDone = true
        }
        
        if notDone {
            print("Couldn't get valid info about the installation app and/or the drive")
            //yes.isEnabled = false
            
            yes.title = "Quit"
            info.isHidden = true
            
            driveName.isHidden = true
            driveImage.isHidden = true
            
            appImage.isHidden = true
            appName.isHidden = true
            
            titleLabel.stringValue = "Impossible to create the macOS install meadia"
            
            let label = NSTextField(frame: NSRect(x: titleLabel.frame.origin.x, y: self.view.frame.size.height / 2 - 15, width: titleLabel.frame.size.width, height: 30))
            label.isEditable = false
            label.isBordered = false
            label.font = NSFont.systemFont(ofSize: 25)
            label.stringValue = "There was an error while getting app and drive data 🙁"
            label.alignment = .center
            label.isSelectable = false
            label.drawsBackground = false
            
            self.warning.isHidden = true
            
            self.view.addSubview(label)
        }else{
            print("Everything is ready to start the installer creation process")
        }
        
    }
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBAction func goBack(_ sender: Any) {
        sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        let _ = openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
    }
    
    @IBAction func install(_ sender: Any) {
        sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        if notDone{
            NSApp.terminate(sender)
            return
        }
        
        let _ = openSubstituteWindow(windowStoryboardID: "Install", sender: sender)
        
    }
    
}
