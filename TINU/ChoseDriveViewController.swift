//
//  ChoseDriveViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ChoseDriveViewController: GenericViewController {
    @IBOutlet weak var scoller: NSScrollView!
    @IBOutlet weak var ok: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    private var empty: Bool = false{
        didSet{
            if self.empty{
                scoller.drawsBackground = false
                scoller.borderType = .noBorder
                ok.title = "Quit"
                ok.isEnabled = true
            }else{
                viewDidSetVibrantLook()
                ok.title = "Next"
                ok.isEnabled = false
            }
        }
    }
    
    
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        if canUseVibrantLook || self.empty {
            scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
            scoller.drawsBackground = false
            scoller.borderType = .noBorder
        }else{
            scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
            scoller.drawsBackground = true
            scoller.borderType = .bezelBorder
        }    }
    
    @IBAction func refresh(_ sender: Any) {
        updateDrives()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        updateDrives()
    }
    
    private func updateDrives(){
        self.scoller.isHidden = true
        self.spinner.isHidden = false
        self.spinner.startAnimation(self)
        
        print("--- Detectin usable drives and volumes")
        scoller.documentView = NSView()
        
        ok.isEnabled = false
        
        var tot: CGFloat = 10
        
        sharedVolume = nil
        sharedBSDDrive = nil
        
        //sharedVolumeNeedsFormat = nil
        sharedVolumeNeedsPartitionMethodChange = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        self.ok.isEnabled = false
        
        //this code just does the parsing of the diskutil list command
        DispatchQueue.global(qos: .userInitiated).async {
            
            let (output, _, _) = runCommand(cmd: "/bin/sh", args: ["-c", "diskutil list"])
            
            //print(output)
            //print(error)
            //print(status)
            
            var drvs = [Part]()
            var currentDrv: Part!
            
            var otherFS = "Apple_HFS"
            
            if #available(OSX 10.13, *){
                print("We are on High Sierra or a more recent version of mac, let's activate APFS support")
                otherFS = "APFS"
            }
            
            for i in output{
                var c = i.components(separatedBy: CharacterSet.whitespacesAndNewlines).split(separator: "")
                //print(c)
                if !c.isEmpty{
                    if let d = c.first?.first{
                        if d.contains("/dev/disk"){
                            currentDrv = Part()
                            print("Scanning new drive")
                            continue
                        }
                    }
                    c.remove(at: 0)
                    
                    if let f = c.first?.first{
                        if f == "TYPE" || f.isEmpty {
                            continue
                        }else if f == "Apple_Boot" || f == "Apple_CoreStorage" || f == "Apple_partition_map" /*|| f == "Linux" || f == "Linux_Swap"*/{
                            print("         volume not usable")
                            continue
                        }else if f == "GUID_partition_scheme"{
                            currentDrv.partScheme = "GUID_partition_scheme"
                            print("     this drive is guid")
                        }else if f == "FDisk_partition_scheme"{
                            currentDrv.partScheme = "FDisk_partition_scheme"
                            print("     this drive is not guid: MBR")
                            
                            if !self.checkDriveSize(c, true){
                                currentDrv.partScheme = ""
                                continue
                            }
                            
                        }else if f == "Apple_partition_scheme"{
                            
                            currentDrv.partScheme = "Apple_partition_scheme"
                            print("     this drive is not guid: Apple")
                            
                            if !self.checkDriveSize(c, true){
                                currentDrv.partScheme = ""
                                continue
                            }
                        }else if f == "EFI"{
                            if c.first?.count == 2{
                                var cc = c.first!
                                cc.remove(at: cc.startIndex)
                                if cc.first == "EFI"{
                                    currentDrv.hasEFI = true
                                    print("     this drive has an efi partition")
                                }
                            }
                        }else{
                            if currentDrv.partScheme.isEmpty{
                                print("     this drive is not usable")
                                continue
                            }
                            
                            let drv = currentDrv.copy()
                            
                            drv.bsdName += (c.last?.last)!
                            
                            if currentDrv.partScheme == "GUID_partition_scheme"{
                                if !self.checkDriveSize(c, false) {
                                    continue
                                }
                            }
                            
                            c.remove(at: c.count - 1)
                            
                            print("     this volume will be added:")
                            if f == "Apple_HFS"{
                                drv.fileSystem = "HFS+"
                                print("         volume File System is HFS")
                            }else if f == otherFS{
                                drv.fileSystem = "APFS"
                                print("         volume File System is APFS")
                            }else{
                                drv.fileSystem = "Other"
                                print("         volume File System is not HFS+ or APFS")
                            }
                            
                            //print("         volume capacity is: \(sz) MB")
                            print("         volume BSD name is: " + drv.bsdName)
                            
                            if c.count == 1{
                                var d = c.first!
                                c.remove(at: 0)
                                d.remove(at: d.startIndex)
                                //print(d)
                                d.remove(at: d.endIndex - 1)
                                d.remove(at: d.endIndex - 1)
                                c.append(d)
                            }else{
                                c.remove(at: c.count - 1)
                                var d = c.first!
                                c.remove(at: 0)
                                d.remove(at: d.startIndex)
                                c.append(d)
                            }
                            
                            if let cc = c.first{
                                for ccc in cc{
                                    
                                    drv.name += ccc + " "
                                }
                                if !drv.name.isEmpty{
                                    drv.name.characters.removeLast(1)
                                }else{
                                    continue
                                }
                            }
                            
                            
                            drv.path += drv.name
                            
                            if drv.name.contains("...") || !FileManager.default.fileExists(atPath: drv.path){
                                print("         volume needs a fix for it's name")
                                if let path = getDriveNameFromBSDID(drv.bsdName){
                                    drv.path = path
                                    drv.name = FileManager.default.displayName(atPath: path)
                                }
                            }
                            
                            print("         volume name is " + drv.name)
                            
                            let drive = DriveObject(frame: NSRect(x: tot, y: 20, width: 130, height: 150))
                            drive.frame.origin.y = (self.scoller.frame.height - 20) / 2 - drive.frame.height / 2
                            drive.isApp = false
                            drive.volumePath = drv.path
                            drive.image.image = NSWorkspace.shared().icon(forFile: drv.path)//NSImage(named: "logo.png")
                            drive.volume.stringValue = drv.name
                            drive.volumeBSD = drv.bsdName
                            drive.part = drv
                            
                            drives.append(drive)
                            drvs.append(drv)
                            tot += 130
                        }
                    }else{
                        continue
                    }
                }
            }
            /*
             if i.contains("GUID_partition_scheme"){
             currentDrv.partScheme = "GUID_partition_scheme"
             print("     this drive is guid")
             }else if i.contains("FDisk_partition_scheme"){
             currentDrv.partScheme = "FDisk_partition_scheme"
             print("     this drive is not guid: MBR")
             }else if (i.contains("Apple_partition_scheme") || i.contains("Apple_partition_map")){
             if currentDrv.partScheme.isEmpty{
             currentDrv.partScheme = "Apple_partition_scheme"
             print("     this drive is not guid: Apple")
             }
             }else if i.contains("/dev/disk"){
             currentDrv = Part()
             print("Scanning new drive")
             }else if i.contains("EFI EFI"){
             currentDrv.hasEFI = true
             print("     this drive has an efi partition")
             }else{
             if currentDrv.partScheme.isEmpty{
             continue
             }
             
             if !c.isEmpty{
             
             //if (i.contains("Apple_HFS")) || i.contains(otherFS) || (i.contains("DOS_FAT_32")) || (i.contains("Microsoft Basic Data")) || (i.contains("Windows_NTFS")){
             
             /*if !currentDrv.hasEFI{
             print("     this drive has not an efi partition")
             }*/
             let drv = currentDrv.copy()
             
             if f == "TYPE" || f == "Apple_Boot" || f == "Apple_CoreStorage" || f.isEmpty{
             continue
             }else if f == "Apple_HFS"{
             drv.fileSystem = "HFS+"
             print("         volume File System is HFS")
             }else if f == otherFS{
             drv.fileSystem = "APFS"
             print("         volume File System is APFS")
             }else{
             drv.fileSystem = "Other"
             print("         volume File System is not HFS+ or APFS")
             }
             
             print("     this volume will be added:")
             
             drv.bsdName += (c.last?.last)!
             print("         volume BSD name is: " + drv.bsdName)
             
             c.remove(at: c.count - 1)
             if c.count == 1{
             var d = c.first!
             c.remove(at: 0)
             d.remove(at: d.startIndex)
             //print(d)
             d.remove(at: d.endIndex - 1)
             d.remove(at: d.endIndex - 1)
             c.append(d)
             }else{
             c.remove(at: c.count - 1)
             var d = c.first!
             c.remove(at: 0)
             d.remove(at: d.startIndex)
             c.append(d)
             }
             
             if let cc = c.first{
             for ccc in cc{
             
             drv.name += ccc + " "
             }
             drv.name.characters.removeLast(1)
             }
             
             drv.path += drv.name
             
             if drv.name.contains("...") || !FileManager.default.fileExists(atPath: drv.path){
             print("         volume needs a fix for it's name")
             if let path = getDriveNameFromBSDID(drv.bsdName){
             drv.path = path
             drv.name = FileManager.default.displayName(atPath: path)
             }
             }
             
             print("         volume name is " + drv.name)
             
             let drive = DriveObject(frame: NSRect(x: tot, y: 10, width: 150, height: 170))
             drive.isApp = false
             drive.volumePath = drv.path
             drive.image.image = NSWorkspace.shared().icon(forFile: drv.path)//NSImage(named: "logo.png")
             drive.volume.stringValue = drv.name
             drive.volumeBSD = drv.bsdName
             drive.part = drv
             
             drives.append(drive)
             drvs.append(drv)
             tot += 160
             */
            //}
            //}
            /*
             if let urls = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) {
             for url in urls {
             let components = url.pathComponents
             if components.count > 1
             && components[1] == "Volumes"
             {
             
             for v in drvs{
             
             let n = components[2]
             if n == v.name{
             let drive = DriveObject(frame: NSRect(x: tot, y: 20, width: 130, height: 170))
             drive.volumePath = "/Volumes/" + n
             drive.image.image = NSWorkspace.shared().icon(forFile: "/Volumes/" + n)//NSImage(named: "logo.png")
             
             
             drive.volume.stringValue = n
             
             drives.append(drive)
             
             tot += 140
             
             
             
             }
             }
             }
             }
             }else{
             
             }*/
            
            //drvs.removeAll()
            
            DispatchQueue.main.sync {
                var content = NSView(frame: NSRect(x: 0, y: 0, width: tot, height: self.scoller.frame.size.height - 20))
                content.backgroundColor = NSColor.white.withAlphaComponent(0)
                
                
                self.scoller.hasVerticalScroller = false
                self.scoller.hasHorizontalScroller = true
                
                var res = (drvs.count == 0)
                
                //this is just to test if there are no usable drives
                if simulateNoUsableDrives {
                    res = true
                }
                
                self.empty = res
                
                if res{
                    print("No usable drives found!")
                    //fail :(
                    let label = NSTextField(frame: self.scoller.frame)
                    label.frame.size.width -= 10
                    label.stringValue = "No usable drives or devices found"
                    label.alignment = .center
                    label.isEditable = false
                    label.isBordered = false
                    label.font = NSFont.systemFont(ofSize: 20)
                    label.frame.origin = CGPoint(x: 0, y: (self.scoller.frame.size.height / 2) - 15)
                    label.drawsBackground = false
                    label.frame.size.height = 30
                    content = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.size.width - 10, height: self.scoller.frame.size.height - 10))
                    content.addSubview(label)
                    
                    self.scoller.hasHorizontalScroller = false
                }else{
                    var temp: CGFloat = 10
                    for d in drives.reversed(){
                        d.frame.origin.x = temp
                        temp += d.frame.width
                        content.addSubview(d)
                    }
                }
                self.scoller.documentView = content
                self.scoller.isHidden = false
                self.spinner.isHidden = true
                self.spinner.stopAnimation(self)
                
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if showLicense{
            let _ = openSubstituteWindow(windowStoryboardID: "License", sender: self)
        }else{
            let _ = openSubstituteWindow(windowStoryboardID: "Info", sender: self)
        }
    }
    
    @IBAction func next(_ sender: Any) {
        if !empty{
            if sharedVolumeNeedsPartitionMethodChange != nil /*&& sharedVolumeNeedsFormat != nil*/{
                /*
                 if sharedVolumeNeedsFormat{
                 if dialogOKCancel(question: "Format the volume?", text: "This volume will be erased to be used to create a macOS install media, this will permanently erase all the data on it, do you want to continue?", style: .warning){
                 return
                 }
                 }else*/ if sharedVolumeNeedsPartitionMethodChange{
                    if dialogOKCancel(question: "Format the drive?", text: "This drive needs to be formatted to be used to craete a macOS install media, all the data in it will be erased, do you want ot continue?", style: .warning){
                        return
                    }
                }
            }
            let _ = openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: self)
        }else{
            NSApplication.shared().terminate(sender)
        }
    }
    
    private func checkDriveSize(_ cc: [ArraySlice<String>], _ isDrive: Bool) -> Bool{
        var c = cc
        
        c.remove(at: c.count - 1)
        
        var sz: Float = 0
        
        if c.count == 1{
            let f: String = (c.last?.last!)!
            var cl = c.last!
            cl.remove(at: cl.index(before: cl.endIndex))
            let ff: String = cl.last!
            
            c.removeAll()
            
            c.append([ff, f])
            
        }
        
        if var n = c.last?.first{
            if isDrive{
                n.characters.remove(at: n.startIndex)
            }else{
                let s = String(describing: n.characters.first)
                if s == "*" || s == "+"{
                    print("         volume size is not fixed, skipping it")
                    return false
                }
            }
            
            if let s = Float(n){
                sz = s
            }
        }
        
        if let n = c.last?.last{
            if n == "KB"{
                sz /= 1024
            }else if n == "GB"{
                sz *= 1024
            }else if n == "TB"{
                sz *= 1024 * 1024
            }else if n != "MB"{
                if isDrive{
                    print("     this drive has a size unit unkown, skipping this drive")
                }else{
                    print("         volume size unit unkown, skipping this volume")
                }
                return false
            }
        }
        
        var minSize: Float = 7000
        if sharedInstallMac{
            minSize = 20000
        }
        
        if sz <= minSize{
            if isDrive{
                print("     this drive is too small to be used for a macOS installer, skipping this drive")
            }else{
                print("     this volume too small for a macOS installer")
            }
            return false
        }
        
        return true
    }
    
}


