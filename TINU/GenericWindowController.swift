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

//generic tinu windows, that can change aspect mode
import Cocoa

public class GenericWindowController: NSWindowController, NSWindowDelegate {
	//var alreadyFullScreen: Bool = false
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        //sets window
        self.window?.delegate = self
        
        setUI()
    }
    
    func setUI(){
        //self.window?.isFullScreenEnaled = false
        
        #if !isTool
        self.window?.title = UIManager.shared.windowTitlePrefix
        #endif
        
        //checkVibrant()
		activateVibrantWindow()
    }
	
	
    func activateVibrantWindow(){
		self.window?.titlebarAppearsTransparent = true
		self.window?.styleMask.insert(.fullSizeContentView)
		self.window?.isMovableByWindowBackground = true
		
        #if !isTool
		if App.isTesting{
			self.window?.titleVisibility = .visible
		}else{
			self.window?.titleVisibility = .hidden
		}
        #endif
		
    }
    
	func deactivateVibrantWindow(){
		self.window?.titlebarAppearsTransparent = false
		self.window?.isMovableByWindowBackground = false
		
		if (self.window?.styleMask.contains(.fullSizeContentView))!{
			self.window?.styleMask.remove(.fullSizeContentView)
		}
		
		self.window?.titleVisibility = .visible
    }
	
	
	public func windowWillClose(_ notification: Notification) {
		
	}
	
	public func windowWillBeginSheet(_ notification: Notification) {
		deactivateVibrantWindow()
	}
	
	public func windowDidEndSheet(_ notification: Notification) {
		activateVibrantWindow()
	}
}
