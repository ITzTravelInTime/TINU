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
    
   public let backgroundDefaultMaterial = NSVisualEffectMaterial.titlebar
   public let backgroundUnselectedMaterial = NSVisualEffectMaterial.light
    
    var background: NSVisualEffectView!
	//var alreadyFullScreen: Bool = false
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        //sets window
        self.window?.delegate = self
        
        setUI()
    }
    
    func setUI(){
        self.window?.isFullScreenEnaled = false
        
        #if !isTool
        self.window?.title = sharedWindowTitlePrefix
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
    
    func makeStandard(){
        //self.window?.isResizable = true
        
        self.window?.exitFullScreen()
        
        self.window?.isFullScreenEnaled = false
        
    }
    
    func makeEditable(){
        //self.window?.isResizable = false
        
        self.window?.makeFullScreen()
        
        self.window?.isFullScreenEnaled = true
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
