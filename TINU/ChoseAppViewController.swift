//
//  ChoseAppViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ChoseAppViewController: GenericViewController {
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
        }
    }
    
    @IBOutlet weak var ok: NSButton!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    private var ps: Bool!
    //private var fs: Bool!
    
    @IBAction func goBack(_ sender: Any) {
        let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
    }
    
    @IBAction func next(_ sender: Any) {
        if !empty{
            sharedVolumeNeedsPartitionMethodChange = ps
            //sharedVolumeNeedsFormat = fs
            let _ = openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
        }else{
            NSApplication.shared().terminate(self)
        }
    }
    @IBAction func refreshPressed(_ sender: Any) {
        loadApps()
    }
    
    @IBOutlet weak var scoller: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loadApps()
    }
    
    private func loadApps(){
        ps = sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        scoller.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        print("--- Apps detection started")
        scoller.documentView = NSView(frame: scoller.frame)
        scoller.hasHorizontalScroller = false
        
        var tot: CGFloat = 10
        
        sharedApp = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        ok.isEnabled = false
        
        var dirs = [String]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            
            var documentsUrls = [URL?]()
            
            if !sharedIsOnRecovery{
                documentsUrls = [fm.urls(for: .applicationDirectory, in: .systemDomainMask).first, fm.urls(for: .desktopDirectory, in: .userDomainMask).first, fm.urls(for: .downloadsDirectory, in: .userDomainMask).first, fm.urls(for: .documentDirectory, in: .userDomainMask).first]
            }
            
            for d in FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.isVolumeKey], options: [.skipHiddenVolumes])!{
                let p = d.path
                if p != getDriveNameFromBSDID(sharedBSDDrive){
                    
                    documentsUrls.append(d)
                    
                    var isDir : ObjCBool = false
                    if FileManager.default.fileExists(atPath: p + "/Applications", isDirectory: &isDir){
                        if isDir.boolValue && d.path != "/"{
                            documentsUrls.append(URL(fileURLWithPath: p + "/Applications"))
                        }
                    }
                    
                }
            }
            
            //documentsUrls += [URL(fileURLWithPath: "/Volumes/Image Volume", isDirectory: true)]
            
            print("This contains the urls for the paths in witch we will try find the installation apps")
            print(documentsUrls)
            print("Starting installation apps scan ...")
            
            
            do {
                for dd in documentsUrls{
                    if let d = dd{
                        print("Scanning for usable apps in \(d.path)")
                        let fileNames = try FileManager.default.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }
                        for f in fileNames{
                            if FileManager.default.fileExists(atPath: f + "/Contents/Resources/" + sharedExecutableName) && !dirs.contains(f){
                                print("An new app that contains the createinstallmedia has been found")
                                DispatchQueue.main.sync {
                                    dirs.append(f)
                                    
                                    let drive = DriveObject(frame: NSRect(x: tot, y: 20, width: 130, height: 150))
                                    drive.frame.origin.y = (self.scoller.frame.height - 20) / 2 - drive.frame.height / 2
                                    drive.isApp = true
                                    drive.applicationPath = f
                                    print("     App path is " + f)
                                    drive.image.image = NSWorkspace.shared().icon(forFile: f)//NSImage(named: "logo.png")
                                    drive.volume.stringValue = FileManager.default.displayName(atPath: f)
                                    print("     App name is " + drive.volume.stringValue)
                                    drives.append(drive)
                                    tot += 130
                                }
                            }
                        }
                    }
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            print("Apps scanning finished, \(dirs.count) app/s found")
            
            print("--- App detection complete")
            
            var content = NSView(frame: NSRect(x: 0, y: 0, width: tot, height: self.scoller.frame.size.height - 20))
            
            DispatchQueue.main.sync {
                self.scoller.hasHorizontalScroller = true
                self.scoller.hasVerticalScroller = false
                
                var res = (dirs.count == 0)
                
                //just to test the screen when there are no apps found
                if simulateNoUsableApps{
                    res = true
                }
                
                self.empty = res
                
                if res {
                    //fail :(
                    print("No usable installation apps where found!")
                    let label = NSTextField(frame: self.scoller.frame)
                    label.stringValue = "No usable macOS installer apps found"
                    label.frame.size.width -= 10
                    label.alignment = .center
                    label.isEditable = false
                    label.isBordered = false
                    label.font = NSFont.systemFont(ofSize: 20)
                    label.frame.origin = CGPoint(x: 0, y: (self.scoller.frame.size.height / 2) - 15)
                    label.frame.size.height = 30
                    label.drawsBackground = false
                    content = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.size.width - 10, height: self.scoller.frame.size.height - 10))
                    content.addSubview(label)
                    self.scoller.hasHorizontalScroller = false
                }else{
                    for d in drives.reversed(){
                        content.addSubview(d)
                    }
                }
                self.scoller.documentView = content
                
                self.spinner.stopAnimation(self)
                self.spinner.isHidden = true
                self.scoller.isHidden = false
            }
            
        }
    }
    
}
