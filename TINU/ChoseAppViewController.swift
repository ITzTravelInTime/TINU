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
                //viewDidSetVibrantLook()
				
				if let document = scoller.documentView{
					if document.identifier == spacerID{
						document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
						if let content = document.subviews.first{
							content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
						}
						self.scoller.documentView = document
					}
				}
				
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
    
    
    /*override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        if let document = scoller.documentView{
            if document.identifier == spacerID{
                document.frame = NSRect(x: 0, y: 0, width: self.scoller.frame.width - 2, height: self.scoller.frame.height - 2)
                if let content = document.subviews.first{
                    content.frame.origin = NSPoint(x: document.frame.width / 2 - content.frame.width / 2, y: 0)
                }
                self.scoller.documentView = document
            }
        }
		
    }*/
    
    @IBOutlet weak var ok: NSButton!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var refreshButton: NSButton!
	
	@IBOutlet weak var DownloadAppsAlways: NSButton!
    
    @IBOutlet weak var normalOpen: NSButton!
    
    private var tempRefresh: CGFloat = 0
    
    private var ps: Bool!
    //private var fs: Bool!
    
    private let spacerID = "spacer"
    
    @IBAction func goBack(_ sender: Any) {
        let _ = sawpCurrentViewController(with: "ChoseDrive", sender: self)
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
				sawpCurrentViewController(with: "License", sender: sender)
			}else{
				#if skipChooseCustomization
				let _ = self.sawpCurrentViewController(with: "Confirm", sender: sender)
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
	
	@IBAction func chooseElsewere( _ sender: Any){
		chooseExternal()
	}
	
	private static var installerAppNeededFiles: [[String]]{
		get{
			return ([ ["/Contents/Resources/" + sharedExecutableName],["/Contents/Info.plist"],["/Contents/SharedSupport"], ["/Contents/SharedSupport/InstallESD.dmg", "/Contents/SharedSupport/SharedSupport.dmg"]])
		}
	}
	
    func chooseExternal() {
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
						
						var tmpURL: URL?
						if let isAlias = FileAliasManager.finderAlias(open.urls.first!, resolvedURL: &tmpURL){
							if isAlias{
								path = tmpURL!.path
							}
						}else{
							if let name = open.urls.first?.lastPathComponent{
								msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable because it's Finder Alias can't be resolved.")
							}else{
								msgBoxWarning("Invalid file", "The app you chose is not usable because it's Finder Alias can't be resolved.")
							}
						}
						
						let needed = ChoseAppViewController.installerAppNeededFiles
						var check: Int = needed.count
						for c in needed{
							if c.isEmpty{
								check-=1
								continue
							}
							for d in c{
								if manager.fileExists(atPath: path + d){
									check-=1
									break
								}
							}
						}
						
						if check == 0 {
							
							cvm.shared.sharedApp = path
							
							cvm.shared.sharedVolumeNeedsPartitionMethodChange = self.ps
							
							#if skipChooseCustomization
							let _ = self.sawpCurrentViewController(with: "Confirm", sender: self)
							#else
							let _ = self.openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: self)
							#endif
							
						}else{
							if let name = open.urls.first?.lastPathComponent{
								msgBoxWarning("Invalid file", "The app you chose, \"\(name)\", is not usable to create macOS installers or macOS installations because it isn't a macOS installer or is a damaged macOS installer.")
							}else{
								msgBoxWarning("Invalid file", "The app you chose is not usable to create macOS installers or macOS installations because it isn't a macOS installer or is a damaged macOS installer.")
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.setTitleLabel(text: "Choose the macOS installer app to use for the macOS installer")
		self.showTitleLabel()
		
		if !sharedIsOnRecovery && !simulateDisableShadows{
			scoller.frame = CGRect.init(x: 0, y: scoller.frame.origin.y, width: self.view.frame.width, height: scoller.frame.height)
			scoller.drawsBackground = false
			scoller.borderType = .noBorder
			
		}else{
			scoller.frame = CGRect.init(x: 20, y: scoller.frame.origin.y, width: self.view.frame.width - 40, height: scoller.frame.height)
			scoller.drawsBackground = true
			scoller.borderType = .bezelBorder
		}
		
		showProcessLicense = false
        
        if sharedInstallMac{
            titleLabel.stringValue = "Choose the macOS installer app to use to install macOS"
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
	
	func openGetAnApp(){
		self.presentViewControllerAsSheet(sharedStoryboard.instantiateController(withIdentifier: "DownloadAppVC") as! NSViewController)
	}
    
    private func loadApps(){
        ps = cvm.shared.sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        scoller.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        print("--- Apps detection started")
        scoller.documentView = NSView(frame: scoller.frame)
        scoller.hasHorizontalScroller = false
		
		self.DownloadAppsAlways.isHidden = sharedIsOnRecovery
		
		self.hideFailureLabel()
		self.hideFailureImage()
		self.hideFailureButtons()
        
        self.normalOpen.isHidden = false
        
        self.refreshButton.frame.origin.x = self.tempRefresh
		
        cvm.shared.sharedApp = nil
        
        //here loads drives
        //let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey]
        
        ok.isEnabled = false
		
        DispatchQueue.global(qos: .background).async {
            let fm = FileManager.default
            
            var foldersURLS = [URL?]()
			
			//TINU looks for installer apps in those folders: /Applications ~/Desktop /~Downloads ~/Documents
            
            if !sharedIsReallyOnRecovery{
                foldersURLS = [URL(fileURLWithPath: "/Applications"), fm.urls(for: .applicationDirectory, in: .systemDomainMask).first, fm.urls(for: .desktopDirectory, in: .userDomainMask).first, fm.urls(for: .downloadsDirectory, in: .userDomainMask).first, fm.urls(for: .documentDirectory, in: .userDomainMask).first, fm.urls(for: .allApplicationsDirectory, in: .systemDomainMask).first, fm.urls(for: .allApplicationsDirectory, in: .userDomainMask).first]
            }
			
			
			
			let driveb = dm.getDriveNameFromBSDID(cvm.shared.sharedBSDDrive)
			
			for d in fm.mountedVolumeURLs(includingResourceValuesForKeys: [URLResourceKey.isVolumeKey], options: [.skipHiddenVolumes])!{
				let p = d.path
				
				if p == driveb || sharedIsOnRecovery{
					continue
				}
				
				foldersURLS.append(d)
				
				var isDir : ObjCBool = false
				
				if fm.fileExists(atPath: p + "/Applications", isDirectory: &isDir){
					if isDir.boolValue && p != "/"{
						foldersURLS.append(URL(fileURLWithPath: p + "/Applications"))
					}
				}
				
				isDir = false
				
				if fm.fileExists(atPath: p + "/System/Applications", isDirectory: &isDir){
					if isDir.boolValue && p != "/"{
						foldersURLS.append(URL(fileURLWithPath: p + "/System/Applications"))
					}
				}
				
			}
			
			print("TINU will look for installer apps in: ")
			
			for pathURL in foldersURLS{
				
				if let p = pathURL{
					print("    " + p.path)
					
					do{
						
						for content in (try fm.contentsOfDirectory(at: p, includingPropertiesForKeys: nil, options: []).filter{ fm.directoryExistsAtPath($0.path) }){
							print("    " + content.path)
							foldersURLS.append(content)
							
						}
						
					} catch let err{
						print("Error while trying to retrive subfolders of: " + p.path + "\n" + err.localizedDescription)
					}
					
				}
				
			}
			
			/*
			print("This contains the URLs for the paths in which we will try find the installer apps:")
			print("[")
			
			for f in foldersURLS{
				if let ff = f{
					print("\(ff), ")
				}
			}
			print("]\n\n")
			*/

			print("Starting installer apps scan ...")
			
			var h: CGFloat = 0
			
			DispatchQueue.main.sync {
				h = ((self.scoller.frame.height - 17) / 2) - (DriveView.itemSize.height / 2)
			}
			
			let ex = sharedExecutableName
			
			print("Current executable name: \(ex)")
			
			var dirs = [String]()
			var drives = [DriveView]()
			let needed = ChoseAppViewController.installerAppNeededFiles
			
			do {
				for dir in foldersURLS{
					if let d = dir{
						
						if !fm.fileExists(atPath: d.path){
							continue
						}
						
						print("Scanning for usable apps in \(d.path)")
						//let fileNames = try manager.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }
						
						for appOriginPath in (try fm.contentsOfDirectory(at: d, includingPropertiesForKeys: nil, options: []).filter{ $0.pathExtension == "app" }.map{ $0.path }) {
							
							var appPath = appOriginPath
							
							var tempPath: String?
							
							if let isAlias = FileAliasManager.finderAlias(appOriginPath, resolvedPath: &tempPath){
								if isAlias{
									print("This application \"\(appOriginPath)\" is an alias")
									appPath = tempPath!
									print("Alias resolved: \n        alias path: \(appOriginPath) \n        file path:  \(appPath)")
								}
							}else{
								print("Alias resolution for \"\(appOriginPath)\" has failed, skipping it")
								continue
							}
							
							if dirs.contains(appPath){
								continue
							}
							
							//only installer apps from now
							if !fm.fileExists(atPath: appPath + "/Contents/Resources/" + ex) {
								continue
							}
							
							print("A new app that contains the needed \"" + ex + "\" executable has been found")
							//DispatchQueue.main.sync {
							dirs.append(appPath)
							
							DispatchQueue.main.sync {
								
								let drive = DriveView(frame: NSRect(x: 0, y: h, width: DriveView.itemSize.width, height: DriveView.itemSize.height))
								drive.isApp = true
								drive.applicationPath = appPath
								print("     App path is " + appPath)
								
								drive.image.image = IconsManager.shared.getInstallerAppIconFrom(path: appPath)
								
								drive.volume.stringValue = FileManager.default.displayName(atPath: appPath)
								print("     App name is " + drive.volume.stringValue)
								
								/*if fp{
								drive.isEnabled = false
								}*/
								
								var check: Int = needed.count
								for c in needed{
									if c.isEmpty{
										check-=1
										continue
									}
									
									let tmp = check
									for d in c{
										print("       Checking if app contains \"\(d)\"")
										if fm.fileExists(atPath: appPath + d){
											print("       +App does contain \"\(d)\"")
											check-=1
											break
										}
									}
									
									if tmp == check{
										for d in c{
											print("       -App does not contain \"\(d)\"")
										}
										print("     App is not usable to make installers")
										break
									}
								}
								
								drive.isEnabled = (check == 0)
								
								print("     App checked, adding it to the apps list")
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
				
				self.empty = simulateNoUsableApps ? true : (dirs.count == 0)
				
				if !sharedIsOnRecovery{
					self.DownloadAppsAlways.isHidden = self.empty
				}
				
				if self.empty {
					
					self.scoller.isHidden = true
					self.normalOpen.isHidden = true
					
					if self.failureLabel == nil || self.failureImageView == nil || self.failureButtons.isEmpty{
						self.setFailureImage(image: IconsManager.shared.warningIcon)
						self.setFailureLabel(text: "No macOS Installer apps where detected")
						
						if !sharedIsOnRecovery{
							self.addFailureButton(buttonTitle: "Get an Installer", target: self, selector: #selector(ChoseAppViewController.openGetAnApp))
						}
						self.addFailureButton(buttonTitle: "Open an installer ...", target: self, selector: #selector(ChoseAppViewController.chooseExternal))
					}
					
					self.showFailureImage()
					self.showFailureLabel()
					self.showFailureButtons()
					
					self.refreshButton.frame.origin.x = self.view.frame.width / 2 - self.refreshButton.frame.width / 2
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
