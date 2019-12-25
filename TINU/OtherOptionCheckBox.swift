//
//  OtherOptionsItem.swift
//  TINU
//
//  Created by ITzTravelInTime on 14/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class OtherOptionsCheckBox: NSView {
    
    var option = OtherOptionsObject()
    
    var checkBox = NSButton()
	
	var infoButton = NSButton()
	
	//let mlength = "Delete the .IAPhisicalMedia file (Fixes USB installer no".characters.count

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
            checkBox.setButtonType(.switch)
            checkBox.title = option.title
            checkBox.target = self
            checkBox.action = #selector(OtherOptionsCheckBox.checked)
		
		checkBox.isEnabled = option.isUsable
		
        if option.isActivated{
            checkBox.state = 1
        }else{
            checkBox.state = 0
        }
		
		checkBox.font = NSFont.systemFont(ofSize: 13)
		
        checkBox.frame.origin = NSPoint(x: 10, y: 7)
        checkBox.frame.size = NSSize(width: self.frame.size.width - 30, height: 16)

        self.addSubview(checkBox)
		
			infoButton.title = ""
			infoButton.bezelStyle = .helpButton
		
		infoButton.frame.size = NSSize(width: 25, height: 25)
		
		infoButton.frame.origin = NSPoint(x: self.frame.size.width - 25, y: 2.5)
		
		infoButton.font = NSFont.systemFont(ofSize: 13)
		infoButton.isContinuous = true
		infoButton.target = self
		infoButton.action = #selector(OtherOptionsCheckBox.showInfo)
		
		self.addSubview(infoButton)
    }
	
	func checked(){
		log("Trying to change the value of \"\(option.id)\"")
		/*for i in 0...(otherOptions.count - 1){
		if otherOptions[i].id == self.option.id{
		otherOptions[i].isActivated = (checkBox.state == 1)
		option.isActivated = otherOptions[i].isActivated
		log("Activated value changed successfully to \(option.isActivated)")
		}
		}*/
		
		if var o = oom.shared.otherOptions[option.id]{
			o.isActivated = (checkBox.state == 1)
			option.isActivated = o.isActivated
			
			if sharedInstallMac && cvm.shared.sharedSVReallyIsAPFS{
				if option.id == oom.OtherOptionID.otherOptionForceToFormatID{
					
					for item in (self.superview?.subviews)!{
						if let opt = item as? OtherOptionsCheckBox{
							if opt.option.id == oom.OtherOptionID.otherOptionDoNotUseApfsID{
								log("Trying to change the value of \"\(opt.option.id)\"")
								
								if var oo = oom.shared.otherOptions[opt.option.id]{
									oo.isActivated = o.isActivated
									oo.isUsable = o.isActivated
								}
								
								opt.option.isActivated = o.isActivated
								opt.option.isUsable = o.isActivated
									
								opt.checkBox.isEnabled = o.isActivated
								
								if o.isActivated{
									opt.checkBox.state = 1
								}else{
									opt.checkBox.state = 0
								}
							}
						}
					}
					
				}
			}
		}
	}
	
	@objc func showInfo(){
		let vc = sharedStoryboard.instantiateController(withIdentifier: "OtherOptionInfoViewController") as! OtherOptionsInfoViewController
		
		vc.associatedOption = option
		
		CustomizationWindowManager.shared.referenceWindow.contentViewController?.presentViewControllerAsSheet(vc)
		
		/*if sharedUseVibrant{
			if let w = sharedWindow.windowController as? GenericWindowController{
				w.deactivateVibrantWindow()
			}
		}*/
		
	}
}
