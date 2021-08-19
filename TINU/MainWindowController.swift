//
//  mainWindowController.swift
//  TINU
//
//  Created by Pietro Caruso on 05/05/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa
import TINUNotifications

//this class manages the window
public class mainWindowController: GenericWindowController {

    override public func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        
        window?.toolbar = NSApplication.shared.windows[0].toolbar
        
        //we have got all the needed data, so we can setup the look properly
        self.setUI()
        
		UIManager.shared.window = self.window
		TINUNotifications.Alert.window = self.window
		UIManager.shared.storyboard = self.storyboard
		
		self.window?.title = UIManager.shared.windowTitlePrefix
		
        
        //self.contentViewController?.viewDidLoad()
        
        /*
        if sharedIsOnRecovery{
            self.contentViewController?.openSubstituteWindow(windowStoryboardID: "chooseSide", sender: self)
        }*/
    }
	
	public override func windowWillBeginSheet(_ notification: Foundation.Notification) {
		super.windowWillBeginSheet(notification)
		
		//TINUNotifications.Alert.window = nil
		
		if TINUNotifications.Alert.window == self.window{
			TINUNotifications.Alert.window = nil
		}
		
	}
	
	public override func windowDidEndSheet(_ notification: Foundation.Notification) {
		super.windowDidEndSheet(notification)
		
		TINUNotifications.Alert.window = self.window
		
	}
    
	override public func windowWillClose(_ notification: Foundation.Notification){
        NSApplication.shared.terminate(self)
    }
    
    @objc func windowShouldClose(_ sender: Any) -> Bool {
		print("main Window should close called")
		if cvm.shared.process.status == .creation {
			if let d = InstallMediaCreationManager.shared.stopWithAsk(){
				return d
			}else{
				return false
			}
        }
        
		return !(cvm.shared.process.status.isBusy())
    }
    
}
