//
//  OptionsViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 10/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//



import Cocoa

class OptionsViewController: GenericViewController {
	
	public enum SectionsID: UInt8{
		
		case undefined = 0
		case generalOptions
		case advancedOptions
		//case bootFilesReplacement
		case eFIFolderReplacementClover
		case eFIFolderReplacementOpenCore
		
	}
	
    private var ps: Bool!
	
	@IBOutlet weak var sectionsScrollView: NSScrollView!
	@IBOutlet weak var settingsScrollView: NSScrollView!
	
	@IBOutlet weak var backButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	
	let itemsHeight: CGFloat = 50
	
	private var sections = [SettingsSectionItem?]()
	private var container: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		settingsScrollView.wantsLayer = true
		settingsScrollView.layer?.cornerRadius = 3.5
		
		self.setTitleLabel(text: "Options")
		self.showTitleLabel()
		
		sections.removeAll()
        //avoids some porblems of sharedVolumeNeedsPartitionMethodChange being nill when it should not be
        ps = cvm.shared.sharedVolumeNeedsPartitionMethodChange
        
        //just in case of errors
        if cvm.shared.sharedVolume == nil || cvm.shared.sharedApp == nil{
            sawpCurrentViewController(with: "Confirm")
        }
		
		//general options
		
		sections.append(getSectionItem())
		sections.last!!.image.image = NSImage(named: NSImageNamePreferencesGeneral)
		sections.last!!.name.stringValue = "General options"
		sections.last!!.id = SectionsID.generalOptions
		
		//advanced options
		
		sections.append(getSectionItem())
		sections.last!!.image.image = NSImage(named: NSImageNameAdvanced)
		sections.last!!.name.stringValue = "Advanced options"
		sections.last!!.id = SectionsID.advancedOptions
		
		#if !macOnlyMode
			
			#if useEFIReplacement
				//efi replacement
		
				for i in SupportedEFIFolders.allCases{
					sections.append(getSectionItem())
			
					sections.last!!.image.image = NSImage(named: NSImageNameFolder)
				
					sections.last!!.name.stringValue = "Install " + i.rawValue + "\nEFI folder"
					
					switch i{
					case .clover:
						sections.last!!.id = SectionsID.eFIFolderReplacementClover
						break
					case.openCore:
						sections.last!!.id = SectionsID.eFIFolderReplacementOpenCore
						break
						
					}
				}
		
			#endif
		#endif
		
		
		//adding items to the view
		
		container = NSView(frame: NSRect(x: 2, y: 2, width: sectionsScrollView.frame.width - 2, height: itemsHeight * CGFloat(sections.count)))
		
		if container!.frame.size.height <= sectionsScrollView.frame.height{
			container!.frame.size.height = sectionsScrollView.frame.height - 2
			sectionsScrollView.verticalScrollElasticity = .none
		}else{
			sectionsScrollView.verticalScrollElasticity = .allowed
		}
		
		var h: CGFloat = container!.frame.size.height - itemsHeight
		
		for i in sections.sorted(by: { $0!.id.rawValue < $1!.id.rawValue }){
			i!.frame.origin.y = h
			
			i!.itemsScrollView = settingsScrollView
			
			h -= itemsHeight
			
			container!.addSubview(i!)
		}
		
		sectionsScrollView.documentView = container!
		
		#if skipChooseCustomization
			backButton.isHidden = true
			nextButton.title = "Done"
		#endif
		
    }
	
	override func viewDidAppear() {
		
		if let win = self.window{
			win.isFullScreenEnaled = false
			CustomizationWindowManager.shared.referenceWindow = win
		}
		
		if !sections.isEmpty{
			sections.first??.makeSelected()
			sections.first??.addSettingsToScrollView()
		}
	}
	
	@inline(__always) private func getSectionItem() -> SettingsSectionItem{
		let sec = SettingsSectionItem(frame: NSRect(x: 0, y: 0, width: sectionsScrollView.frame.size.width - 2, height: itemsHeight))
		sec.needsLayout = true
		return sec
	}
    
    
    @IBAction func goBack(_ sender: Any) {
        cvm.shared.sharedVolumeNeedsPartitionMethodChange = ps
		
		CustomizationWindowManager.shared.referenceWindow = nil
		
		clean()
		
		sawpCurrentViewController(with: "ChooseCustomize")
		//openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
    }
    
    @IBAction func goNext(_ sender: Any) {
		
		clean()
		
		CustomizationWindowManager.shared.referenceWindow = nil
		
		#if skipChooseCustomization
			self.window.sheetParent?.endSheet(self.window)
		#else
        	openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
        	cvm.shared.sharedVolumeNeedsPartitionMethodChange = ps
		#endif
    }
    
    @IBAction func resetOptions(_ sender: Any) {
        checkOtherOptions()
		
		EFIFolderReplacementManager.reset()
		
		if let sections = sectionsScrollView.documentView?.subviews as? [SettingsSectionItem]{
		
		if !sections.isEmpty{
			for s in sections{
				if s.isSelected{
					s.addSettingsToScrollView()
				}
			}
		}
		
		}
    }
	
	override func dismiss(_ sender: Any?) {
		clean()
		
		super.dismiss(sender)
	}
	
	@inline(__always) func clean(){
		SettingsSectionItem.surface = nil
		
		for i in 0..<sections.count{
			if sections[i] != nil{
				sections[i]!.removeFromSuperview()
			}
			sections[i] = nil
		}
		
		sections.removeAll()
		
		
		container = nil
	}
}
