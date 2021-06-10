//
//  GenericTINUWindow.swift
//  TINU
//
//  Created by ITzTravelInTime on 17/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

//generic tinu windows, that can change aspect mode
import Cocoa

public class GenericWindowController: NSWindowController, NSWindowDelegate {
    
   public let backgroundDefaultMaterial = NSVisualEffectView.Material.titlebar
   public let backgroundUnselectedMaterial = NSVisualEffectView.Material.light
    
    var background: NSVisualEffectView!
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
		if AppManager.shared.sharedTestingMode{
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
