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
	
	/*
    func checkVibrant(){
		if (self.window?.styleMask.contains(.fullSizeContentView))! || self.window!.titlebarAppearsTransparent{
			alreadyFullScreen = true
			self.window?.isMovableByWindowBackground = true
				
			if AppManager.shared.sharedTestingMode{
				self.window?.titleVisibility = .visible
			}else{
				self.window?.titleVisibility = .hidden
			}
		}
			
	/*
			if !alreadyFullScreen{
            	if sharedUseVibrant {
                	activateVibrantBackground()
                	activateVibrantWindow()
            	}else{
                	deactivateVibrantBackground()
                	deactivateVibrantWindow()
            	}
			}
			
	
            if let c = self.window?.contentViewController as? GenericViewController{
                c.viewDidSetVibrantLook()
            }
			*/
    }*/
	
	
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
	
	/*
    private func activateVibrantBackground(){
        background = NSVisualEffectView.init(frame: CGRect.init(origin: CGPoint.zero, size: (self.window?.contentView?.frame.size)!))
        background.material = backgroundDefaultMaterial
        background.state = .active
        self.window?.contentViewController?.view.addSubview(background, positioned: .below, relativeTo: window?.contentViewController?.view)
    }
    
    private func deactivateVibrantBackground(){
        //print("\(String(describing: self.window?.contentView?.subviews))\n\n")
        if background != nil{
            background.isHidden = true
            background.removeFromSuperview()
            background = nil
        }
        
        for cc in (self.window?.contentViewController?.view.subviews)!{
            if let c = cc as? NSVisualEffectView{
                c.removeFromSuperview()
                c.isHidden = true
            }
        }
        
    }*/
    
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
		/*if sharedUseVibrant{
			if let w = sharedWindow.windowController as? GenericWindowController{
				w.activateVibrantWindow()
			}
		}*/
	}
	
	
	
	public func windowWillBeginSheet(_ notification: Notification) {
		
		//if alreadyFullScreen{
			deactivateVibrantWindow()
		//}
		
		/*
		if sharedUseVibrant || alreadyFullScreen{
			self.deactivateVibrantWindow()
		}*/
	}
	
	public func windowDidEndSheet(_ notification: Notification) {
		
		//if alreadyFullScreen{
			activateVibrantWindow()
		//}
		
		/*
		if sharedUseVibrant || alreadyFullScreen{
			self.activateVibrantWindow()
		}*/
		
	}
	
    /*
    private func changeBackgroundMaterial(_ material: NSVisualEffectMaterial){
        if canUseVibrantLook{
            if background != nil{
                background.material = material
            }
            
            for cc in (self.window?.contentView?.subviews)!{
                if let c = cc as? NSVisualEffectView{
                    c.material = material
                }
            }
            
            print("called background change: " + (self.window?.title)!)
        }
    }*/
    
    /*
    public func windowDidBecomeMain(_ notification: Notification) {
        changeBackgroundMaterial(backgroundDefaultMaterial)
    }
    
    public func windowDidResignMain(_ notification: Notification) {
        changeBackgroundMaterial(backgroundUnselectedMaterial)
    }
 
    
    public func windowDidBecomeKey(_ notification: Notification) {
        changeBackgroundMaterial(backgroundDefaultMaterial)
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        changeBackgroundMaterial(backgroundUnselectedMaterial)
    }
    */
}
