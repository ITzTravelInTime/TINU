//
//  DriveObject.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this class is an UI object used to represent a drive or a insteller app that can be selected by the user
class DriveObject: NSView {
    
    override init(frame: NSRect){
        super.init(frame: frame)
        
        //self.borderColor = NSColor.red.cgColor
        //self.backgroundColor = NSColor.blue
        self.layer?.cornerRadius = 15
        
        image = NSImageView(frame: NSRect(x: 5, y: 40, width: self.frame.size.width - 10, height: self.frame.size.height - 50))
        image.isEditable = false
        image.imageAlignment = .alignCenter
        image.imageScaling = .scaleProportionallyUpOrDown
        self.addSubview(image)
        
        volume = NSTextField(frame: NSRect(x: 5, y: -5, width: self.frame.size.width - 10, height: 40))
        volume.font = NSFont.boldSystemFont(ofSize: 10)
        volume.stringValue = ""
        volume.isEditable = false
        volume.isBordered = false
        volume.alignment = .center
        volume.backgroundColor = NSColor.white.withAlphaComponent(0)
        
        //volume.isSelectable = false
        self.addSubview(volume)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public var isApp = false
    
    public var volumePath = ""
    public var volumeBSD = ""
    public var applicationPath = ""
    
    public var part: Part!
    
    var image = NSImageView()
    var volume = NSTextField()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        //self.setDefaultAspect()
    }
    
    override func mouseDown(with event: NSEvent) {
        
        for c in (self.superview?.subviews)!{
            if let d = c as? DriveObject{
               d.setDefaultAspect()
            }
        }
        
        setSelectedAspect()
        
        if !isApp{
            //sharedVolumeNeedsFormat = nil
            sharedVolumeNeedsPartitionMethodChange = nil
            
            if part != nil{
                if part.partScheme != "GUID_partition_scheme" || !part.hasEFI{
                    sharedVolumeNeedsPartitionMethodChange = true
                    /*}else{
                     sharedVolumeNeedsPartitionMethodChange = false*/
                }
                
                /*
                 if part.fileSystem == "Other" && !sharedVolumeNeedsPartitionMethodChange{
                 sharedVolumeNeedsFormat = true
                 }else{
                 sharedVolumeNeedsFormat = false
                 }*/
            }
            
            sharedVolume = volumePath
            sharedBSDDrive = volumeBSD
            Swift.print("The volume that the user has selected is: " + volumePath)
            if let s = self.window?.contentViewController as? ChoseDriveViewController{
                s.ok.isEnabled = true
            }
        }else{
            sharedApp = applicationPath
            Swift.print("The application that the user has selected is: " + applicationPath)
            if let s = self.window?.contentViewController as? ChoseAppViewController{
                s.ok.isEnabled = true
            }
        }
        
    }
    
    public func setDefaultAspect(){
        //self.layer?.backgroundColor = NSColor.white.withAlphaComponent(0).cgColor
        self.backgroundColor = NSColor.white.withAlphaComponent(0)
        volume.textColor = NSColor.black
        
    }
    
    public func setSelectedAspect(){
        //self.layer?.backgroundColor = NSColor.blue.cgColor
        self.backgroundColor = NSColor.blue
        volume.textColor = NSColor.white
        self.layer?.cornerRadius = 15
    }
    
}
