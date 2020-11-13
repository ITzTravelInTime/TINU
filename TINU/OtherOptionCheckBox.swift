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
            checkBox.state = .on
        }else{
            checkBox.state = .off
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
	
	@objc func checked(){
		
		log("Trying to change the value of \"\(option.id)\"")
		/*for i in 0...(otherOptions.count - 1){
		if otherOptions[i].id == self.option.id{
		otherOptions[i].isActivated = (checkBox.state == 1)
		option.isActivated = otherOptions[i].isActivated
		log("Activated value changed successfully to \(option.isActivated)")
		}
		}*/
		
		if oom.shared.otherOptions[option.id] == nil { return }
		
		let newState = (checkBox.state.rawValue == 1)
		
		//this as been done in this way instead of an if var because of possible errors
		oom.shared.otherOptions[option.id]?.isActivated = newState
		option.isActivated = newState
		
		//this code here is used to deactivate the APFS convertion stuff if the user has choosen to format the target drive
		if !sharedInstallMac || !cvm.shared.sharedSVReallyIsAPFS || option.id != oom.OtherOptionID.otherOptionForceToFormatID{
			return
		}
		
		for item in self.superview!.subviews{
			guard let opt = item as? OtherOptionsCheckBox else { continue }
			
			if opt.option.id != oom.OtherOptionID.otherOptionDoNotUseApfsID{
				continue
			}
			
			oom.shared.otherOptions[opt.option.id]?.isActivated = newState
			oom.shared.otherOptions[opt.option.id]?.isUsable = newState
			opt.option.isActivated = newState
			opt.option.isUsable = newState
			opt.checkBox.isEnabled = newState
			opt.checkBox.state = checkBox.state
		}
	}
	
	@objc func showInfo(){
		let vc = sharedStoryboard.instantiateController(withIdentifier: "OtherOptionInfoViewController") as! OtherOptionsInfoViewController
		
		vc.associatedOption = option
		
		CustomizationWindowManager.shared.referenceWindow.contentViewController?.presentAsSheet(vc)
		
	}
}
