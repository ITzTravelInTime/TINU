/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
		if cvm.shared.process.status == .creation && cvm.shared.maker != nil {
			if let d = cvm.shared.maker?.stopWithAsk(){
				return d
			}else{
				return false
			}
        }
        
		return !(cvm.shared.process.status.isBusy())
    }
    
}
