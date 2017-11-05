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
    
    let backgroundDefaultMaterial = NSVisualEffectMaterial.titlebar
    let backgroundUnselectedMaterial = NSVisualEffectMaterial.light
    
    var background: NSVisualEffectView!
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        //sets window
        self.window?.delegate = self
        
        setUI()
    }
    
    func setUI(){
        self.window?.isFullScreenEnaled = false
        self.window?.title = sharedWindowTitlePrefix
        
        checkVibrant()
    }
    
    func checkVibrant(){
        if !sharedIsOnRecovery{
            if sharedUseVibrant {
                activateVibrantBackground()
                activateVibrantWindow()
            }else{
                deactivateVibrantBackground()
                deactivateVibrantWindow()
            }
            
            if let c = self.window?.contentViewController as? GenericViewController{
                c.viewDidSetVibrantLook()
            }
        }
    }
    
    private func activateVibrantWindow(){
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.styleMask.insert(.fullSizeContentView)
        self.window?.isMovableByWindowBackground = true
        
        if sharedTestingMode{
            self.window?.titleVisibility = .visible
        }
    }
    
    private func deactivateVibrantWindow(){
        self.window?.titlebarAppearsTransparent = false
        self.window?.isMovableByWindowBackground = false
        self.window?.titleVisibility = .visible
        if (self.window?.styleMask.contains(.fullSizeContentView))!{
            self.window?.styleMask.remove(.fullSizeContentView)
        }
    }
    
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
