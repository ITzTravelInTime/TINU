//
//  OtherOptionsItem.swift
//  TINU
//
//  Created by ITzTravelInTime on 14/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class OtherOptionsItem: NSView {
    
    var option = OtherOptionsObject()
    
    var checkBox = NSButton()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        /*
        if #available(OSX 10.12, *) {
            checkBox = NSButton(checkboxWithTitle: option.displayMessage, target: self, action: #selector(self.checked))
        } else {
            */
            //checkBox = NSButton()
            checkBox.setButtonType(.switch)
            checkBox.title = option.displayMessage
            checkBox.target = self
            checkBox.action = #selector(self.checked)
        //}
        
        if option.isActivated{
            checkBox.state = 1
        }else{
            checkBox.state = 0
        }
        
        checkBox.isEnabled = option.isUsable
        
        checkBox.font = NSFont.systemFont(ofSize: 13)
        
        checkBox.frame.origin = NSPoint(x: 10, y: (self.frame.height / 2) - 10)
        checkBox.frame.size = NSSize(width: self.frame.width - 30, height: 20)
        
        self.addSubview(checkBox)
        
        // Drawing code here.
    }
	
	func checked(){
		log("Trying to change the activated value of \"\(option.id)\"")
		/*for i in 0...(otherOptions.count - 1){
		if otherOptions[i].id == self.option.id{
		otherOptions[i].isActivated = (checkBox.state == 1)
		option.isActivated = otherOptions[i].isActivated
		log("Activated value changed sucessfully to \(option.isActivated)")
		}
		}*/
		
		if let o = otherOptions[option.id]{
			o.isActivated = (checkBox.state == 1)
			option.isActivated = o.isActivated
			
			if sharedInstallMac && sharedSVReallyIsAPFS{
				if option.id == otherOptionForceToFormatID{
					
					for item in (self.superview?.subviews)!{
						if let opt = item as? OtherOptionsItem{
							if opt.option.id == otherOptionDoNotUseApfsID{
								log("Trying to change the activated value of \"\(opt.option.id)\"")
								if let oo = otherOptions[otherOptionDoNotUseApfsID]{
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
	
}
