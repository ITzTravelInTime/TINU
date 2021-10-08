/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)

class EFIPartitionMounterViewController: ShadowViewController, ViewID {
	let id: String = "EFIPartitionMounterViewController"
	
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var scrollerHeight: NSLayoutConstraint!
	@IBOutlet weak var spinner: NSProgressIndicator!
    
    public var         barMode:            Bool                     = false
    public var         popover:            NSPopover!
    
    private var        watcher:            FileSystemObserver!
    private var        watcherTriggerd:    Bool                     = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        
        #if isTool
        
        print("checking command line arguments")
        for i in CommandLine.arguments {
            print(i)
            switch i {
            case "-diagnostics":
                if let delegate = NSApplication.shared().delegate as? AppDelegate{
                    delegate.diagnosticsItem.isEnabled = false
                }
                
                print("diagnostics mode detected")
            case "-forcerecovery":
                simulateRecovery = true
            default:
                break
            }
        }
        print("command line args checked")
		
        if startsAsMenu{
            startsAsMenu.toggle()
            
        	App.shared.checkUser()
            App.shared.checkSettings()
        }
        
        #endif
        
		self.view.wantsLayer = true
		self.view.superview?.wantsLayer = true
		
		scrollView.frame = CGRect.init(x: 0, y: scrollView.frame.origin.y, width: self.view.frame.width, height: scrollView.frame.height)
		scrollView.borderType = .noBorder
		scrollView.drawsBackground = false
		
		/*if !look.usesSFSymbols(){
			setShadowViewsTopBottomOnly(respectTo: scrollView, topBottomViewsShadowRadius: 5)
		}*/
        
        //self.setTitleLabel(text: EFIPMTextManager.getViewString(context: self, stringID: "title"))
        self.showTitleLabel()
        
		setOtherViews(respectTo: scrollView)
	}
	
    
    #if !isTool// && EFIPM
    
    override func viewWillAppear() {
        super.viewWillAppear()
    
		//self.window.isFullScreenEnaled = false
		
		self.window.styleMask.insert(.resizable)
    }    
    #endif
    
    
	override func viewDidAppear() {
		super.viewDidAppear()
        
        print("Main view view did appear triggered")
        
        #if isTool
        
        if !barMode{
            
            if startsAsMenu{
                print("the app is starting as menu item, avoiding loosing time on a window which will be closed")
                return
            }
            
            toolMainViewController = self
        }
        
        for c in self.view.subviews{
            if let l = c as? NSTextField{
                l.drawsBackground = true
                c.backgroundColor = (c.superview! as NSView).backgroundColor
            }
        }
        
        self.spinner.isDisplayedWhenStopped = false
        self.spinner.usesThreadedAnimation = true
        
		/*
        if barMode{
            iconModeButton.title = EFIPMTextManager.getViewString(context: self, stringID: "windowMode")
        }else{
            iconModeButton.title = EFIPMTextManager.getViewString(context: self, stringID: "toolbarMode")
        }*/
        
        #endif
        
        //self.window?.collectionBehavior.subtract(.fullScreenPrimary)
        
		self.spinner.isHidden = false
		self.spinner.startAnimation(self)
		
		DispatchQueue.global(qos: .background).async {
			self.watcherTriggerd = true
			self.watcher = FileSystemObserver(url: URL(fileURLWithPath: "/Volumes", isDirectory: false), changeHandler: {
				
				print("Change in /Volumes")
				
				if self.watcherTriggerd{
					DispatchQueue.main.async {
						print("Refreshing list because of a new volume")
						self.refresh(self)
					}
				}
				
			})
			
		}
		
        self.setScrollView()
	}
	
	deinit {
		viewWillDisappear()
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
        /*
		#if !isTool
            if !(CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress){
                erasePassword()
            }
        #else
            erasePassword()
        
            print("will disappear")
        
        #endif
		*/

		scrollView.documentView = nil
        
        watcher = nil
        watcherTriggerd = false
	}
    
    @IBAction func toggleIconMode(_ sender: Any) {
		#if isTool
		if !isOnRecovery{
        	if let appDelegate = NSApplication.shared().delegate as? AppDelegate{
            	appDelegate.toggleStatusItem()
            	appDelegate.togglePopover(self)
        	}
		}
		#endif
    }
    
	@IBAction func refresh(_ sender: Any) {
		self.watcherTriggerd = false
		scrollView.isHidden = true
		
		hideFailureImage()
        hideFailureLabel()
        hideFailureButtons()
		
		//refreshButton.isHidden = true
        
        self.spinner.isHidden = false
        self.spinner.startAnimation(self)
        
        setScrollView()
		
		self.watcherTriggerd = true
	}
	
    private func setScrollView(){
		//DispatchQueue.main.sync{
		/*
		self.spinner.isHidden = false
		self.spinner.startAnimation(self)
		*/
		
		createEFIPartitionItems(response: { response in
			
			guard let items = response?.reversed() else {
				self.empty()
				return
			}
			
			if items.isEmpty{
				self.empty()
				return
			}
			
			DispatchQueue.main.sync {
				
				let background = NSView()
				
				//background.backgroundColor = .red
				
				background.wantsLayer = true
				
				
				background.frame.size.height = 20
				background.frame.size.width = self.scrollView.frame.width - 2
				
				for item in items{
					
					item.frame.origin = NSPoint(x: 20, y: background.frame.height)
					
					item.wantsLayer = true
					
					item.updateLayer()
					
					background.addSubview(item)
					
					background.frame.size.height += item.frame.height + 15
				}
				
				background.frame.size.height += 5
				
				self.scrollView.documentView = background
				self.scrollerHeight.constant = self.scrollView.documentView!.frame.height	// limit window height to the available content in the scroll view
				
				self.scrollView.isHidden = false
				
				if let documentView = self.scrollView.documentView{
					documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
				}
				
				self.spinner.isHidden = true
				self.spinner.stopAnimation(self)
			}
			
		})
	}
	
	private func empty(){
		DispatchQueue.main.sync {
			
			self.scrollView.isHidden = true
			
			self.defaultFailureImage()
			self.showFailureImage()
			
			self.setFailureLabel(text: EFIPMTextManager.getViewString(context: self, stringID: "noEFIPartitions"))//"No EFI partitions found")
			self.showFailureLabel()
			
			self.showFailureButtons()
			
			self.spinner.isHidden = true
			self.spinner.stopAnimation(self)
		}
	}
	
	private func createEFIPartitionItems(response: @escaping ([EFIPartitionToolInterface.EFIPartitionItem]?) -> Void){
		
		typealias EFIItem = EFIPartitionToolInterface.EFIPartitionItem
		typealias PartItem = EFIPartitionToolInterface.PartitionItem
		
		DispatchQueue.global(qos: .background).async {
			
			var items: [EFIItem]! = nil
			
			EFIPartition.clearPartitionsCache()
			
			guard let eFIData = EFIPartitionMounterModel.shared.getEFIPartitionsAndSubprtitionsNew() else {
				response(items)
				return
			}
			
			//var EFIParts = [BSDID]()
			
			for drive in eFIData{
				
				DispatchQueue.main.sync {
					let item = EFIItem()
					
					item.titleLabel.stringValue = drive.displayName
					item.bsdid = drive.bsdName
					
					//EFIParts.append(drive.bsdName)
					
					item.frame.size.height = 110
					
					item.frame.size.width = self.scrollView.frame.size.width - 40
					
					item.isMounted = drive.isMounted
					
					item.configType = drive.configType
					
					item.isEjectable = drive.isRemovable
					
					item.partitions = []
					
					let cnt = drive.completeDrivePartitions.count
					
					if cnt != 0{
						
						for i in 0...cnt - 1{
							let partition = drive.completeDrivePartitions[i]
							
							let part = PartItem()
							
							part.imageView.image = partition.drivePartIcon
							part.nameLabel.stringValue = partition.drivePartDisplayName
							
							item.partitions.append(part)
							
							if i % 3 == 0{
								item.frame.size.height += item.tileHeight + 5
							}
						}
						
					}
					
					if items == nil{
						items = []
					}
					
					items.append(item)
					
				}
			}
			
			//if EFIParts != []{
				//self.eFIManager = EFIPartitions(from: EFIParts) ?? EFIPartitions()
				//self.eFIManager.buildPartitionsCache(fromPartitionsList: EFIParts)
			//}
			
			response(items)
			
		}
		
	}
	
}

#endif
