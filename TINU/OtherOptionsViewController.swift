//
//  OptionsViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 10/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//



import Cocoa

class OtherOptionsViewController: GenericViewController, ViewID {
	
	let id: String = "OtherOptionsViewController"
	
	public enum SectionsID: UInt8{
		
		case undefined = 0
		case generalOptions
		case advancedOptions
		case eFIFolderReplacementClover
		case eFIFolderReplacementOpenCore
		
	}
	
    private var ps: Bool!
	
	@IBOutlet weak var sectionsScrollView: NSScrollView!
	@IBOutlet weak var settingsScrollView: NSScrollView!
	
	@IBOutlet weak var defaultButton: NSButton!
	@IBOutlet weak var backButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	
	let itemsHeight: CGFloat = 50
	
	private var sections = [SettingsSectionItem?]()
	private var container: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		settingsScrollView.wantsLayer = true
		settingsScrollView.layer?.cornerRadius = 3.5
		
		if look.usesSFSymbols(){
			settingsScrollView.frame.origin.x -= sectionsScrollView.frame.origin.x - 5
			settingsScrollView.frame.size.width = self.view.frame.width - settingsScrollView.frame.origin.x - 5
		
			sectionsScrollView.frame.origin.x = 5
			sectionsScrollView.borderType = .noBorder
		}
		
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
		self.showTitleLabel()
		
		sections.removeAll()
        //avoids some porblems of sharedVolumeNeedsPartitionMethodChange being nill when it should not be
        ps = cvm.shared.sharedVolumeNeedsPartitionMethodChange
        
        //just in case of errors
        if cvm.shared.sharedVolume == nil || cvm.shared.sharedApp == nil{
            swapCurrentViewController("Confirm")
        }
		
		//general options
		
		sections.append(getSectionItem())
		sections.last!!.image.image = IconsManager.shared.optionsIcon
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			sections.last!!.image.image?.isTemplate = true
			sections.last!!.image.contentTintColor = .systemGray
			sections.last!!.imageColor = sections.last!!.image.contentTintColor!
		}
		sections.last!!.name.stringValue = TextManager.getViewString(context: self, stringID: "optionsSection")
		sections.last!!.id = SectionsID.generalOptions
		
		//advanced options
		
		sections.append(getSectionItem())
		sections.last!!.image.image = IconsManager.shared.advancedOptionsIcon
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			sections.last!!.image.image?.isTemplate = true
			sections.last!!.image.contentTintColor = .systemGray
			sections.last!!.imageColor = sections.last!!.image.contentTintColor!
		}
		sections.last!!.name.stringValue = TextManager.getViewString(context: self, stringID: "advancedOptionsSection")
		sections.last!!.id = SectionsID.advancedOptions
		
		#if !macOnlyMode
			
			#if useEFIReplacement
				//efi replacement
		
				for i in SupportedEFIFolders.allCases{
					sections.append(getSectionItem())
			
					sections.last!!.image.image = IconsManager.shared.folderIcon//NSImage(named: NSImage.folderName)
					if #available(macOS 11.0, *), look.usesSFSymbols(){
						sections.last!!.image.image?.isTemplate = true
						//sections.last!!.image.contentTintColor = .systemBlue
						sections.last!!.image.contentTintColor = .systemGray
						sections.last!!.imageColor = sections.last!!.image.contentTintColor!
					}
					
					let rep = ["{bootloader}" : i.rawValue]
				
					sections.last!!.name.stringValue = parse(messange: TextManager.getViewString(context: self, stringID: "bootloaderSection" ), keys: rep)
					
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
		
		defaultButton.title = TextManager.getViewString(context: self, stringID: "defaultButton")
		
		#if skipChooseCustomization
			backButton.isHidden = true
			nextButton.title = TextManager.getViewString(context: self, stringID: "nextButton")
		#else
			backButton.title = TextManager.getViewString(context: self, stringID: "backButton")
			nextButton.title = TextManager.getViewString(context: self, stringID: "nextButtonChoose")
		#endif
		
    }
	
	override func viewDidAppear() {
		
		if let win = self.window{
			win.isFullScreenEnaled = false
			CustomizationWindowManager.shared.referenceWindow = win
		}
		
		DispatchQueue.main.async {
			if !self.sections.isEmpty{
				self.sections.first!!.select()
			}
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
		
		swapCurrentViewController("ChooseCustomize")
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
		cvm.shared.options.checkOtherOptions()
		
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
