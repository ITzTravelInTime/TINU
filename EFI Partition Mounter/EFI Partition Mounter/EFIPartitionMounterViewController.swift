//
//  EFIPartitionMounterView.swift
//  TINU
//
//  Created by Pietro Caruso on 25/07/18
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)

class EFIPartitionMounterViewController: AppViewController {
	
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var scrollHeight: NSLayoutConstraint!
	
	@IBOutlet weak var spinner: NSProgressIndicator!
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var errorImage: NSImageView!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var errorRefreshButton: NSButton!
    
	@IBOutlet weak var baseLabel: NSTextField!
	@IBOutlet weak var titleLabel: NSTextField!
	
    @IBOutlet weak var iconModeButton: NSButton!
    public let eFIManager = EFIPartitionManager()
    
    public var barMode = false
    public var popover: NSPopover!
	
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
            
        	AppManager.shared.checkUser()
            AppManager.shared.checkSettings()
        }
        
        #endif
        
		self.view.wantsLayer = true
		self.view.superview?.wantsLayer = true
		
		scrollView.frame = CGRect.init(x: 0, y: scrollView.frame.origin.y, width: self.view.frame.width, height: scrollView.frame.height)
		scrollView.borderType = .noBorder
		scrollView.drawsBackground = false
		
		setShadowViewsTopBottomOnly(respectTo: scrollView, topBottomViewsShadowRadius: 5)
		setOtherViews(respectTo: scrollView)
		
		#if !isTool
			closeButton.title = "Close"
            iconModeButton.isHidden = true
		#endif
	}
	
    #if !isTool// && EFIPM
    override func viewWillAppear() {
        super.viewWillAppear()
		self.window.isFullScreenEnaled = false
		
		self.window.styleMask.insert(.resizable)
    }
    #endif
    
	override func viewDidAppear() {
		super.viewDidAppear()
        
        print("Main view view did appear triggered")
        
        self.window?.collectionBehavior.subtract(.fullScreenPrimary)
        
        #if isTool
        
        if !barMode{
            toolMainViewController = self
        }
        
        for c in self.view.subviews{
            if let l = c as? NSTextField{
                l.drawsBackground = true
                (l as NSView).backgroundColor = (l.superview! as NSView).backgroundColor
            }
        }
        
        self.spinner.isDisplayedWhenStopped = false
        self.spinner.usesThreadedAnimation = true
        
        
        if barMode{
            iconModeButton.title = "Window Mode"
        }else{
            iconModeButton.title = "Toolbar Mode"
        }
        
        if !self.barMode && startsAsMenu{
            print("the app is starting as menu item, avoiding losing tiome on a window which will be closed")
            return
        }
        
        #endif
        
        
		
		setScrollView()
        
		DispatchQueue.global(qos: .background).async {
			self.eFIManager.buildPartitionsCache()
		}
	}
	
	override func viewWillDisappear() {
        #if !isTool
            if !(CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress){
                erasePassword()
            }
        #else
            erasePassword()
        
            print("will disappear")
        
        #endif
		
		scrollView.documentView = nil
	}
    
    @IBAction func toggleIconMode(_ sender: Any) {
		#if isTool
		if !sharedIsOnRecovery{
        	if let appDelegate = NSApplication.shared().delegate as? AppDelegate{
            	appDelegate.toggleStatusItem()
            	appDelegate.togglePopover(self)
        	}
            
		}
		#endif
    }
    
	@IBAction func refresh(_ sender: Any) {
		scrollView.isHidden = true
		
		errorImage.isHidden = true
		
		errorLabel.isHidden = true
		
		errorRefreshButton.isHidden = true
		
		refreshButton.isHidden = true
		
		setScrollView()
		
		DispatchQueue.global(qos: .background).async {
			self.eFIManager.clearPartitionsCache()
			self.eFIManager.buildPartitionsCache()
		}
		
	}
	
	@IBAction func close(_ sender: Any) {
		#if !isTool
			self.window.close()
		#else
            NSApplication.shared().terminate(self)
		#endif
	}
	
    private func setScrollView(){
		//DispatchQueue.main.sync{
		
		self.spinner.isHidden = false
		self.spinner.startAnimation(self)
		
		var empty = false
		
		createEFIPartitionItems(response: { response in
			
			if var items = response{
				
				items.reverse()
				
				//items = []
				
				if items.isEmpty{
					empty = true
				}else{
					
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
                        
                        /*if background.frame.height < self.scrollView.frame.height - 2{
                            let newView = NSView(frame: NSRect(x: 0, y: 0, width: background.frame.width, height: self.scrollView.frame.height - 2))
                            
                            //newView.backgroundColor = .green
                            
                            background.frame.origin.x = 0
                            background.frame.origin.y = (newView.frame.height / 2) - background.frame.height / 2
                            
                            newView.addSubview(background)
                            
                            self.scrollView.documentView = newView
                        }else{*/
                            self.scrollView.documentView = background
                        //}
						
						self.scrollHeight.constant = self.scrollView.documentView!.frame.height	// limit window height to the available content in the scroll view
						
						self.scrollView.isHidden = false
						
						self.refreshButton.isHidden = false
						
						self.refreshButton.isHidden = false
						
						if let documentView = self.scrollView.documentView{
							documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
                            if !(self.scrollView.verticalScroller?.isEnabled)!{
                               // documentView.frame.size.width -= 12
                            }
						}
                        
                        
						
					}
				}
			}else{
				empty = true
			}
			
			if empty{
				DispatchQueue.main.sync {
					
					self.scrollView.isHidden = true
					
					self.errorImage.image = IconsManager.shared.warningIcon
					
					self.errorImage.isHidden = false
					
					self.errorLabel.isHidden = false
					
					self.errorRefreshButton.isHidden = false
					
					self.refreshButton.isHidden = true
					
				}
			}
			
			
			DispatchQueue.main.sync {
				self.spinner.isHidden = true
				self.spinner.stopAnimation(self)
			}
			
		})
		//}
	}
	
	private func createEFIPartitionItems(response: @escaping ([EFIPartitionToolInterface.EFIPartitionItem]?) -> Void){
		typealias EFIItem = EFIPartitionToolInterface.EFIPartitionItem
		typealias PartItem = EFIPartitionToolInterface.PartitionItem
		
		EFIPartitionMounterModel.shared.getEFIPartitionsAndSubprtitions(response: { resp in
			
			var items: [EFIItem]! = nil
			
			if let eFIData = resp{
				for drive in eFIData{
					DispatchQueue.main.sync {
					let item = EFIItem()
					
					item.titleLabel.stringValue = drive.displayName
					item.bsdid = drive.bsdName
					
					item.frame.size.height = 100
					
					item.frame.size.width = self.scrollView.frame.size.width - 40
					
					item.isMounted = drive.isMounted
                        
                        item.hasConfig = drive.hasConfig
                        
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
						
						//item.checkMounted()
						
						items.append(item)
						
					}
				}
			}
			
			response(items)
			
		})
	}
	
}

#endif
