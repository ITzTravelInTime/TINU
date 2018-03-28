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
        
        if let document = scoller.documentView{
            if document.identifier == spacerID{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
    }
    
    @IBOutlet weak var ok: NSButton!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var titleField: NSTextField!
    
    @IBOutlet weak var refreshButton: NSButton!
    
	@IBOutlet weak var DownloadApps: NSButton!
	
    @IBOutlet weak var errorImage: NSImageView!
    
    @IBOutlet weak var errorLabel: NSTextField!
    
    @IBOutlet weak var normalOpen: NSButton!
    
    @IBOutlet weak var specialOpen: NSButton!
    
    private var tempRefresh: CGFloat = 0
    
    private var ps: Bool!
    //private var fs: Bool!
    
    private let spacerID = "spacer"
    
    @IBAction func goBack(_ sender: Any) {
        let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
    }
    
    @IBAction func next(_ sender: Any) {
        if !empty{
            sharedVolumeNeedsPartitionMethodChange = ps
            //sharedVolumeNeedsFormat = fs
            /*if sharedInstallMac{
             openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
             }else{*/
			
			
			if sharedInstallMac{
				showProcessLicense = true
				openSubstituteWindow(windowStoryboardID: "License", sender: sender)
			}else{
				openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
			}
			
            //openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
            //}
        }else{
            NSApplication.shared().terminate(self)
        }
    }
    @IBAction func refreshPressed(_ sender: Any) {
        loadApps()
    }
    
    @IBOutlet weak var scoller: NSScrollView!
    
    @IBAction func chooseElsewhere(_ sender: Any) {
        let open = NSOpenPanel()
        open.allowsMultipleSelection = false
        open.canChooseDirectories = false
        open.canChooseFiles = true
        open.isExtensionHidden = false
        open.showsHiddenFiles = true
        open.allowedFileTypes = ["app"]
        
        if open.runModal() == NSModalResponseOK{
            if !open.urls.isEmpty{
                if let path = open.urls.first?.path{
                    let manager = FileManager.default
                    
                    if manager.fileExists(atPath: path + "/Contents/Resources/" + sharedExecutableName) && manager.fileExists(atPath: path + "/Contents/SharedSupport/InstallESD.dmg") && manager.fileExists(atPath: path + "/Contents/Info.plist") {
                        
                        sharedApp = path
                        
                        sharedVolumeNeedsPartitionMethodChange = ps
                        openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
                        
                    }else{
                        if let name = open.urls.first?.lastPathComponent{
                            msgBoxWarning("Impossible to use this app!", "The app you choosed \"\(name)\" is not usable with TINU, because it does not contains all the needed files to work with TINU")
                        }else{
                            msgBoxWarning("Impossible to use this app!", "The app you choosed is not usable with TINU, because it does not contains all the needed files to work with TINU")
                        }
                    }
                }else{
                    msgBoxWarning("Error while opening the file", "There was an error opening the item you choosed")
                }
            }else{
                msgBoxWarning("Error while opening the file", "There was an error opening the item you choosed")
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		showProcessLicense = false
        
        if sharedInstallMac{
            titleField.stringValue = "Choose the macOS installer app to use to install macOS"
        }
        
        tempRefresh = refreshButton.frame.origin.x
        
        loadApps()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    /*@IBAction func openAppDownload(_ sender: Any) {
		if downloadAppWindowController == nil{
			downloadAppWindowController = DownloadAppWindowController()
		}
		
		downloadAppWindowController?.showWindow(sender)
    }*/
    
    private func loadApps(){
        ps = sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        scoller.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        print("--- Apps detection started")
        scoller.documentView = NSView(frame: scoller.frame)
        scoller.hasHorizontalScroller = false
		
		DownloadApps.isHidden = true
        
        self.errorLabel.isHidden = true
        
        self.errorImage.isHidden =  true
        
        self.normalOpen.isHidden = false
        
        self.specialOpen.isHidden = true
        
        self.refreshButton.frame.origin.x = self.tempRefresh
		
        sharedApp = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        ok.isEnabled = false
        
        var dirs = [String]()
        
        DispatchQueue.global(qos: .background).async {
            let fm = FileManager.default
            
            var documentsUrls = [URL?]()
            
            if !sharedIsOnRecovery || simulateRecovery {
                documentsUrls = [fm.urls(for: .applicationDirectory, in: .systemDomainMask).first, fm.urls(for: .desktopDirectory, in: .userDomainMask).first, fm.urls(for: .downloadsDirectory, in: .userDomainMask).first, fm.urls(for: .documentDirectory, in: .userDomainMask).first]
            }
			
			let driveb = getDriveNameFromBSDID(sharedBSDDrive)
			for d in fm.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.isVolumeKey], options: [.skipHiddenVolumes])!{
				let p = d.path
				
				if p == driveb || (sharedIsOnRecovery && p == "/"){
					continue
				}
				
				documentsUrls.append(d)
				
				var isDir : ObjCBool = false
				if fm.fileExists(atPath: p + "/Applications", isDirectory: &isDir){
					if isDir.boolValue && p != "/"{
						documentsUrls.append(URL(fileURLWithPath: p + "/Applications"))
					}
				}
			}
			
            print("This contains the urls for the paths in witch we will try find the installation apps")
            print(documentsUrls)
            print("Starting installation apps scan ...")
            
            let h = (self.scoller.frame.height) / 2 - 80
            
			do {
				for dir in documentsUrls{
					if let d = dir{
						print("Scanning for usable apps in \(d.path)")
						//let fileNames = try manager.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }
						for appPath in (try fm.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }) {
							
							if !dirs.contains(appPath){
								if fm.fileExists(atPath: appPath + "/Contents/Resources/" + sharedExecutableName) {
									
									print("An new app that contains the " + sharedExecutableName + " has been found")
									//DispatchQueue.main.sync {
									dirs.append(appPath)
									
									let drive = DriveObject(frame: NSRect(x: 0, y: h, width: itmSz.width, height: itmSz.height))
									drive.isApp = true
									drive.applicationPath = appPath
									print("     App path is " + appPath)
									
									drive.image.image = getInstallerAppIcon(forApp: appPath)
									
									drive.volume.stringValue = FileManager.default.displayName(atPath: appPath)
									print("     App name is " + drive.volume.stringValue)
									
									/*if fp{
									drive.isEnabled = false
									}*/
									
									if !((fm.fileExists(atPath: appPath + "/Contents/SharedSupport/InstallESD.dmg") &&  fm.fileExists(atPath: appPath + "/Contents/Info.plist"))){
										drive.isEnabled = false
									}
									
									drives.append(drive)
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
			
			
			
            DispatchQueue.main.sync {
                
                self.scoller.hasVerticalScroller = false
                
                var res = (dirs.count == 0)
				
				/*if !res{
					res = true
					for a in drives{
						res = !a.isEnabled
					}
				}*/
				
                //just to test the screen when there are no apps found
                if simulateNoUsableApps{
                    res = true
                }
				
                self.empty = res
				
				if sharedIsOnRecovery{
					self.DownloadApps.isHidden = true
				}else{
					self.DownloadApps.isHidden = !res
				}
				
                if res {
                    //fail :(
                    /*
                    print("No usable installation apps where found!")
                    
                    self.scoller.hasHorizontalScroller = false
                    
                    let label = NSTextField()
                    label.stringValue = "No usable macOS installer apps found"
                    label.alignment = .center
                    label.isEditable = false
                    label.isBordered = false
                    label.drawsBackground = false
                    label.font = NSFont.systemFont(ofSize: 20)
                    label.frame.origin = CGPoint(x: 0, y: (self.scoller.frame.size.height / 2) - 15)
                    label.frame.size = NSSize(width: self.scoller.frame.width - 10, height: 30)
                    
                    content = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.size.width - 2, height: self.scoller.frame.size.height - 2))
                    content.addSubview(label)
					
                    self.scoller.documentView = content
                    */
                    
                    self.scoller.isHidden = true
                    
                    self.errorLabel.isHidden = false
                    
                    self.errorImage.image = warningIcon
                    
                    self.errorImage.isHidden =  false
                    
                    
                    self.normalOpen.isHidden = true
                    
                    self.specialOpen.isHidden = false
                    
                    self.refreshButton.frame.origin.x = self.view.frame.width / 2 - self.refreshButton.frame.width / 2
                    
                }else{
                    
                    let content = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: self.scoller.frame.size.height - 2 - 20))
                    
                    
                    self.scoller.hasHorizontalScroller = true
                    
                    
                    DispatchQueue.global(qos: .background).sync {
                        var temp: CGFloat = 10
                        for d in drives{
                            d.frame.origin.x = temp
                            temp += d.frame.width
                            content.addSubview(d)
                        }
                        
                        content.frame.size.width = temp + 10
                    }
                    if content.frame.size.width < self.scoller.frame.width{
                        let spacer = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2))
                        spacer.backgroundColor = NSColor.white.withAlphaComponent(0)
                        spacer.identifier = self.spacerID
                        content.frame.origin = NSPoint(x: spacer.frame.width / 2 - content.frame.width / 2, y: 0)
                        spacer.addSubview(content)
                        self.scoller.documentView = spacer
                    }else{
                        self.scoller.documentView = content
                    }
                }
                
                self.spinner.stopAnimation(self)
                self.spinner.isHidden = true
                self.scoller.isHidden = false
            }
            
        }
    }
    
}
