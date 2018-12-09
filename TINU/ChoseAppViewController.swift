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
				
				if !(sharedIsOnRecovery || simulateDisableShadows){
					scoller.drawsBackground = false
					scoller.borderType = .noBorder
				}else{
					scoller.drawsBackground = true
					scoller.borderType = .bezelBorder
				}
            }
        }
    }
    
    
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        /*if canUseVibrantLook || self.empty {
            scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
            scoller.drawsBackground = false
            scoller.borderType = .noBorder
        }else{
            scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
            scoller.drawsBackground = true
            scoller.borderType = .bezelBorder
        }*/
        
        if let document = scoller.documentView{
            if document.identifier == spacerID{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
		
		//self.empty.toggle()
		//self.empty.toggle()
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
            cvm.shared.sharedVolumeNeedsPartitionMethodChange = ps
            //sharedVolumeNeedsFormat = fs
            /*if sharedInstallMac{
             openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
             }else{*/
			
			
			if sharedInstallMac{
				showProcessLicense = true
				openSubstituteWindow(windowStoryboardID: "License", sender: sender)
			}else{
				#if skipChooseCustomization
				let _ = self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
				#else
				let _ = self.openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
				#endif
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
		
		open.beginSheetModal(for: self.window, completionHandler: {response in
			
			if response == NSModalResponseOK{
				if !open.urls.isEmpty{
					if var path = open.urls.first?.path{
						let manager = FileManager.default
						
						if FileAliasManager.isAlias(open.urls.first!){
							if let newPath = FileAliasManager.resolveFinderAlias(at: open.urls.first!){
								path = newPath
							}else{
								if let name = open.urls.first?.lastPathComponent{
									msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable because its Finder Alias can't be resolved.")
								}else{
									msgBoxWarning("Invalid file", "The app you chose is not usable because its Finder Alias can't be resolved.")
								}
							}
						}
						
						if manager.fileExists(atPath: path + "/Contents/Resources/" + sharedExecutableName) && manager.fileExists(atPath: path + "/Contents/SharedSupport/InstallESD.dmg") && manager.fileExists(atPath: path + "/Contents/Info.plist") {
							
							cvm.shared.sharedApp = path
							
							cvm.shared.sharedVolumeNeedsPartitionMethodChange = self.ps
							
							#if skipChooseCustomization
							let _ = self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
							#else
							let _ = self.openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
							#endif
							
						}else{
							if let name = open.urls.first?.lastPathComponent{
								msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable to create macOS installers or macOS installations because it does not contain all the needed files to do that or it isn't a macOS installer.")
							}else{
								msgBoxWarning("Invalid file", "The app you chose is not usable to create macOS installers or macOS installations because it does not contain all the needed files to do that or it isn't a macOS installer.")
							}
						}
					}else{
						msgBoxWarning("Error while opening the file", "Impossible to obtain the file's location")
					}
				}else{
					msgBoxWarning("Error while opening the file", "No files choosen")
				}
			}
			
		})
        
        /*if open.runModal() == NSModalResponseOK{
            if !open.urls.isEmpty{
                if var path = open.urls.first?.path{
                    let manager = FileManager.default
					
					if FileAliasManager.isAlias(open.urls.first!){
						if let newPath = FileAliasManager.resolveFinderAlias(at: open.urls.first!){
							path = newPath
						}else{
							if let name = open.urls.first?.lastPathComponent{
								msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable because its Finder Alias can't be resolved.")
							}else{
								msgBoxWarning("Invalid file", "The app you chose is not usable because its Finder Alias can't be resolved.")
							}
						}
					}
                    
                    if manager.fileExists(atPath: path + "/Contents/Resources/" + sharedExecutableName) && manager.fileExists(atPath: path + "/Contents/SharedSupport/InstallESD.dmg") && manager.fileExists(atPath: path + "/Contents/Info.plist") {
                        
                        cvm.shared.sharedApp = path
                        
                        cvm.shared.sharedVolumeNeedsPartitionMethodChange = ps
						
						#if skipChooseCustomization
						let _ = self.openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
						#else
						let _ = self.openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
						#endif
                        
                    }else{
                        if let name = open.urls.first?.lastPathComponent{
                            msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable to create macOS installers or macOS installations because it does not contain all the needed files to do that or it isn't a macOS installer.")
                        }else{
                            msgBoxWarning("Invalid file", "The app you chose is not usable to create macOS installers or macOS installations because it does not contain all the needed files to do that or it isn't a macOS installer.")
                        }
                    }
                }else{
                    msgBoxWarning("Error while opening the file", "Impossible to obtain the file's location")
                }
            }else{
                msgBoxWarning("Error while opening the file", "No files choosen")
            }
        }
        
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		if !sharedIsOnRecovery && !simulateDisableShadows{
			scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
			scoller.drawsBackground = false
			scoller.borderType = .noBorder
			
			/*if !simulateDisableShadows{
				
				setShadowViewsAll(respectTo: scoller, topBottomViewsShadowRadius: 5, sideViewsShadowRadius: 3)
				setOtherViews(respectTo: scoller)
			
				self.uView.isHidden = true
				self.bView.isHidden = true
				
				self.lView.isHidden = true
				self.rView.isHidden = true
			
			}*/
		}else{
			scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
			scoller.drawsBackground = true
			scoller.borderType = .bezelBorder
		}
		
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
        ps = cvm.shared.sharedVolumeNeedsPartitionMethodChange
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
		
        cvm.shared.sharedApp = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        var drives = [DriveObject]()
        
        ok.isEnabled = false
        
        var dirs = [String]()
        
        DispatchQueue.global(qos: .background).async {
            let fm = FileManager.default
            
            var documentsUrls = [URL?]()
            
            if !sharedIsReallyOnRecovery{
                documentsUrls = [fm.urls(for: .applicationDirectory, in: .systemDomainMask).first, fm.urls(for: .desktopDirectory, in: .userDomainMask).first, fm.urls(for: .downloadsDirectory, in: .userDomainMask).first, fm.urls(for: .documentDirectory, in: .userDomainMask).first]
            }
			
			let driveb = dm.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive)
			
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
			
			print("This contains the URLs for the paths in which we will try find the installer apps:")
			print(documentsUrls)
			print("Starting installer apps scan ...")
			
			var h: CGFloat = 0
			
			DispatchQueue.main.sync {
				h = ((self.scoller.frame.height - 17) / 2) - (DriveObject.itemSize.height / 2)
			}
			
			let ex = sharedExecutableName
			
			do {
				for dir in documentsUrls{
					if let d = dir{
						
						if !fm.fileExists(atPath: d.path){
							continue
						}
						
						print("Scanning for usable apps in \(d.path)")
						//let fileNames = try manager.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }
						
						for appOriginPath in (try fm.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }) {
							
							var appPath = appOriginPath
							
							
							
							if let isAlias = FileAliasManager.isAlias(appOriginPath){
								if isAlias{
									
									print("This applications \"\(appOriginPath)\" is an alias")
									
									appPath = FileAliasManager.resolveFinderAlias(at: appOriginPath)!
									
									print("Alias resolved: \n        alias path: \(appOriginPath) \n        file path:  \(appPath)")
									
								}
							}else{
								continue
							}
							
							if dirs.contains(appPath){
								continue
							}
							
							if !fm.fileExists(atPath: appPath + "/Contents/Resources/" + ex) {
								continue
							}
							
							print("A new app that contains the needed \"" + ex + "\" executable has been found")
							//DispatchQueue.main.sync {
							dirs.append(appPath)
							
							DispatchQueue.main.sync {
								
								let drive = DriveObject(frame: NSRect(x: 0, y: h, width: DriveObject.itemSize.width, height: DriveObject.itemSize.height))
								drive.isApp = true
								drive.applicationPath = appPath
								print("     App path is " + appPath)
								
								drive.image.image = IconsManager.shared.getInstallerAppIcon(forApp: appPath)
								
								drive.volume.stringValue = FileManager.default.displayName(atPath: appPath)
								print("     App name is " + drive.volume.stringValue)
								
								/*if fp{
								drive.isEnabled = false
								}*/
								
								print("     Checking app's info.plist")
								if !fm.fileExists(atPath: appPath + "/Contents/Info.plist"){
									print("       No app's info.plist found!")
									drive.isEnabled = false
								}else{
									print("     App's info.plist checked")
								}
								
								print("     Checking app's SharedSupport directory")
								if fm.fileExists(atPath: appPath + "/Contents/SharedSupport"){
									
									print("       Checking SharedSupport/InstallESD.dmg")
									if !fm.fileExists(atPath: appPath + "/Contents/SharedSupport/InstallESD.dmg"){
										print("       SharedSupport/InstallESD.dmg does not exists!")
										drive.isEnabled = false
									}else{
										print("       SharedSupport/InstallESD.dmg present")
									}
									
									print("     App's SharedSupport directory check ended")
								}else{
									print("     App's SharedSupport directory does not exists!")
									drive.isEnabled = false
								}
								
								print("     Adding app to the apps list")
								drives.append(drive)
								print("     App added to the apps list")
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
				
				self.topView.isHidden = res || sharedIsOnRecovery
				self.bottomView.isHidden = res || sharedIsOnRecovery
				
				self.leftView.isHidden = res || sharedIsOnRecovery
				self.rightView.isHidden = res || sharedIsOnRecovery
				
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
					
					self.errorImage.image = IconsManager.shared.warningIcon
					
					self.errorImage.isHidden =  false
					
					
					self.normalOpen.isHidden = true
					
					self.specialOpen.isHidden = false
					
					self.refreshButton.frame.origin.x = self.view.frame.width / 2 - self.refreshButton.frame.width / 2
					
					if sharedIsOnRecovery{
						self.specialOpen.frame.origin.x = self.view.frame.width / 2 - self.specialOpen.frame.width / 2
					}
					
				}else{

					
					let content = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: self.scoller.frame.size.height - 17))
					
					
					self.scoller.hasHorizontalScroller = true
					
					
					DispatchQueue.global(qos: .background).sync {
						var temp: CGFloat = 20
						for d in drives{
							d.frame.origin.x = temp
							if !(sharedIsOnRecovery || simulateDisableShadows){
								temp += d.frame.width + 15
							}else{
								temp += d.frame.width
							}
							content.addSubview(d)
						}
						
						if !(sharedIsOnRecovery || simulateDisableShadows){
							content.frame.size.width = temp + 5
						}else{
							content.frame.size.width = temp + 20
						}
					}
					
					if content.frame.size.width < self.scoller.frame.width{
						let spacer = NSView(frame: NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2))
						spacer.backgroundColor = NSColor.white.withAlphaComponent(0)
						spacer.identifier = self.spacerID
						content.frame.origin = NSPoint(x: spacer.frame.width / 2 - content.frame.width / 2, y: 15 / 2)
						spacer.addSubview(content)
						self.scoller.documentView = spacer
					}else{
						self.scoller.documentView = content
					}
					
					if let documentView = self.scoller.documentView{
						documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
						self.scoller.automaticallyAdjustsContentInsets = true
					}
					
					self.scoller.usesPredominantAxisScrolling = true
					
				}
				
				self.spinner.stopAnimation(self)
				self.spinner.isHidden = true
				self.scoller.isHidden = false
			}
			
		}
	}
	
}
