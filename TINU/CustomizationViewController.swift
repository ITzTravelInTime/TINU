//
//  CustomizationViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 10/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

let idBFR = "1_BootFielsReplacemnt__"
let idGO =  "0_GeneralOptions_______"
let idEFI = "2_EFIFolderReplacement_"

import Cocoa

class CustomizationViewController: GenericViewController {

    private var ps: Bool!
	
	@IBOutlet weak var infoImageView: NSImageView!
	
	@IBOutlet weak var sectionsScrollView: NSScrollView!
	@IBOutlet weak var settingsScrollView: NSScrollView!
	
    @IBOutlet weak var descriptionField: NSTextField!
    
    @IBOutlet weak var titleField: NSTextField!
	
	let itemsHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //avoids some porblems of sharedVolumeNeedsPartitionMethodChange being nill when it should not be
        ps = sharedVolumeNeedsPartitionMethodChange
        
        //just in case of errors
        if sharedVolume == nil || sharedApp == nil{
            openSubstituteWindow(windowStoryboardID: "Confirm", sender: self.view)
        }
		
		infoImageView.image = infoIcon
        
        let customizeIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns"
        let bootFilesIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ExecutableBinaryIcon.icns"
		
		#if useEFIReplacement
			let efiFolderIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns"
		#endif
			
        if sharedInstallMac{
			
			//otherOperationsButton.frame.origin = NSPoint(x: self.view.frame.width / 2 - otherOperationsButton.frame.height / 2, y: otherOperationsButton.frame.origin.y)
            
            descriptionField.stringValue = "Those are options you can use to install macOS, not needed for a standard installation."
            
            //titleField.stringValue = "Options"
            
            if let supportsAPFS = sharedAppNotSupportsAPFS(){
                if !supportsAPFS{
                    descriptionField.stringValue += "\nNote that by default macOS will be installed without forcing to upgrade to APFS."
                    descriptionField.frame.size.height *= (3/2)
                    descriptionField.frame.origin.y -= descriptionField.frame.size.height / 3
                }
            }
        }
		
		
		
		
		var sections = [SettingsSectionItem]()
		
		
		//general options
		
		let generalOptionsSection = getSectionItem()
		
		generalOptionsSection.image.image = getIconFor(path: customizeIconPath, alternate: NSWorkspace.shared().icon(forFileType: ""))
		
		generalOptionsSection.name.stringValue = "General options"
		
		generalOptionsSection.id = idGO
		
		sections.append(generalOptionsSection)
		
		#if !macOnlyMode
			
			#if useEFIReplacement
				//efi replacement
				
				let efiReplacement = getSectionItem()
				
				efiReplacement.image.image = getIconFor(path: efiFolderIconPath, alternate: NSWorkspace.shared().icon(forFile: "/Volumes"))
				
				efiReplacement.name.stringValue = "Replace EFI folder"
				
				efiReplacement.id = idEFI
				
				sections.append(efiReplacement)
				
			#endif
			//bootfiles
			if !sharedInstallMac{
				let bootFielsRepSection = getSectionItem()
				
				bootFielsRepSection.image.image = getIconFor(path: bootFilesIconPath, name: "options")
				
				bootFielsRepSection.name.stringValue = "Boot files replacement"
				
				bootFielsRepSection.id = idBFR
				
				sections.append(bootFielsRepSection)
			}
		#endif
		
		
		//adding items to the view
		
		let container = NSView(frame: NSRect(x: 2, y: 2, width: sectionsScrollView.frame.width - 2, height: itemsHeight * CGFloat(sections.count)))
		
		if container.frame.size.height <= sectionsScrollView.frame.height{
			container.frame.size.height = sectionsScrollView.frame.height - 2
			sectionsScrollView.verticalScrollElasticity = .none
		}else{
			sectionsScrollView.verticalScrollElasticity = .allowed
		}
		
		var h: CGFloat = container.frame.size.height - itemsHeight
		
		for i in sections.sorted(by: { UInt(String($0.id.characters.first!))! < UInt(String($1.id.characters.first!))! }){
			i.frame.origin.y = h
			
			i.itemsScrollView = settingsScrollView
			
			h -= itemsHeight
			
			container.addSubview(i)
		}
		
		sectionsScrollView.documentView = container
		
		if !sections.isEmpty{
			sections.first?.makeSelected()
			sections.first?.addSettingsToScrollView()
		}
		
		
    }
	
	private func getSectionItem() -> SettingsSectionItem{
		return SettingsSectionItem(frame: NSRect(x: 0, y: 0, width: sectionsScrollView.frame.size.width - 2, height: itemsHeight))
	}
    
    
    @IBAction func goBack(_ sender: Any) {
		openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
        //openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
        sharedVolumeNeedsPartitionMethodChange = ps
    }
    
    @IBAction func goNext(_ sender: Any) {
        openSubstituteWindow(windowStoryboardID: "Confirm", sender: sender)
        sharedVolumeNeedsPartitionMethodChange = ps
    }
    
    @IBAction func resetOptions(_ sender: Any) {
        checkOtherOptions()
		
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
}
