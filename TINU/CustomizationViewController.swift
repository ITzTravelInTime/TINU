//
//  CustomizationViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 10/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

let idBFR = "0_BootFielsReplacemnt__"
let idGO = "1_GeneralOptions_______"

import Cocoa

class CustomizationViewController: GenericViewController {

    private var ps: Bool!
	
	@IBOutlet weak var infoImageView: NSImageView!
	
	@IBOutlet weak var sectionsScrollView: NSScrollView!
	@IBOutlet weak var settingsScrollView: NSScrollView!
	
    @IBOutlet weak var descriptionField: NSTextField!
    
    @IBOutlet weak var titleField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //avoids some porblems of sharedVolumeNeedsPartitionMethodChange being nill when it should not be
        ps = sharedVolumeNeedsPartitionMethodChange
        
        //just in case of errors
        if sharedVolume == nil || sharedApp == nil{
            openSubstituteWindow(windowStoryboardID: "Confirm", sender: self.view)
        }
		
		infoImageView.image = infoIcon
        
        let sPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns"
        let fPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ExecutableBinaryIcon.icns"
		
		
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
		
		
		let itemsHeight: CGFloat = 50
		
		var sections = [SettingsSectionItem]()
		
		
		//general options
		
		let generalOptionsSection = SettingsSectionItem(frame: NSRect(x: 0, y: 0, width: sectionsScrollView.frame.size.width - 2, height: itemsHeight))
		
		generalOptionsSection.image.image = getIconFor(path: sPath, alternate: NSWorkspace.shared().icon(forFileType: ""))
		
		generalOptionsSection.name.stringValue = "General options"
		
		generalOptionsSection.id = idGO
		
		sections.append(generalOptionsSection)
		
		#if !macOnlyMode
		//bootfiles
		if !sharedInstallMac{
			let bootFielsRepSection = SettingsSectionItem(frame: NSRect(x: 0, y: 0, width: sectionsScrollView.frame.size.width - 2, height: itemsHeight))
		
			bootFielsRepSection.image.image = getIconFor(path: fPath, name: "options")
		
			bootFielsRepSection.name.stringValue = "Boot files replacement"
		
			bootFielsRepSection.id = idBFR
		
			sections.append(bootFielsRepSection)
		}
		#endif
		
		
		//adding items to the view
		
		let container = NSView(frame: NSRect(x: 2, y: 2, width: sectionsScrollView.frame.width - 2, height: sectionsScrollView.frame.height - 2))
		
		var h: CGFloat = sectionsScrollView.frame.height - 2 - itemsHeight
		
		for i in sections{
			i.frame.origin.y = h
			
			i.itemsScrollView = settingsScrollView
			
			h -= itemsHeight
			
			container.addSubview(i)
		}
		
		sectionsScrollView.documentView = container
		
		if container.frame.size.height <= sectionsScrollView.frame.height{
			sectionsScrollView.verticalScrollElasticity = .none
		}else{
			sectionsScrollView.verticalScrollElasticity = .allowed
		}
		
		if !sections.isEmpty{
			sections.first?.makeSelected()
			sections.first?.addSettingsToScrollView()
		}
		
		
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
