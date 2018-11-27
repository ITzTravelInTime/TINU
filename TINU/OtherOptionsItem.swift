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
	
	var infoButton = NSButton()
	
	//let mlength = "Delete the .IAPhisicalMedia file (Fixes USB installer no".characters.count

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		
		//let buttonsHeigth: CGFloat = 25

        /*
        if #available(OSX 10.12, *) {
            checkBox = NSButton(checkboxWithTitle: option.displayMessage, target: self, action: #selector(self.checked))
        } else {
            */
            //checkBox = NSButton()
            checkBox.setButtonType(.switch)
            checkBox.title = option.displayMessage
            checkBox.target = self
            checkBox.action = #selector(OtherOptionsItem.checked)
        //}
		
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
		
		/*if #available(OSX 10.14.0, *){
			infoButton.title = "?"
			infoButton.bezelStyle = .circular
			//infoButton.setButtonType(.momentaryPushIn)
		
			
		}else{*/
			infoButton.title = ""
			infoButton.bezelStyle = .helpButton
			
		//}
		
		infoButton.frame.size = NSSize(width: 25, height: 25)
		
		infoButton.frame.origin = NSPoint(x: self.frame.size.width - 25, y: 2.5)
		
		infoButton.font = NSFont.systemFont(ofSize: 13)
		infoButton.isContinuous = true
		infoButton.target = self
		infoButton.action = #selector(OtherOptionsItem.showInfo)
		
		self.addSubview(infoButton)
		
        // Drawing code here.

    }
	
	func checked(){
		log("Trying to change the activated value of \"\(option.id)\"")
		/*for i in 0...(otherOptions.count - 1){
		if otherOptions[i].id == self.option.id{
		otherOptions[i].isActivated = (checkBox.state == 1)
		option.isActivated = otherOptions[i].isActivated
		log("Activated value changed successfully to \(option.isActivated)")
		}
		}*/
		
		if let o = oom.shared.otherOptions[option.id]{
			o.isActivated = (checkBox.state == 1)
			option.isActivated = o.isActivated
			
			if sharedInstallMac && cvm.shared.sharedSVReallyIsAPFS{
				if option.id == oom.shared.ids.otherOptionForceToFormatID{
					
					for item in (self.superview?.subviews)!{
						if let opt = item as? OtherOptionsItem{
							if opt.option.id == oom.shared.ids.otherOptionDoNotUseApfsID{
								log("Trying to change the activated value of \"\(opt.option.id)\"")
								
								if let oo = oom.shared.otherOptions[oom.shared.ids.otherOptionDoNotUseApfsID]{
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
		let win = sharedStoryboard.instantiateController(withIdentifier: "OtherOptionInfoViewController") as! OtherOptionsInfoViewController
		
		win.associatedOption = option
		
		self.superview?.superview?.window?.contentViewController?.presentViewControllerAsSheet(win)
		
		if sharedUseVibrant{
			if let w = sharedWindow.windowController as? GenericWindowController{
				w.deactivateVibrantWindow()
			}
		}
		
	}
}
