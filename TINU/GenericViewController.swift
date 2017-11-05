//
//  GenericViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

// This is used to manage somw views that needs to change when the graphcis mode is changed
import Cocoa

class GenericViewController: NSViewController {
    
    var styleView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        viewDidSetVibrantLook()
    }
    
    override func viewDidAppear() {
        viewDidSetVibrantLook()
    }
    /**Function called when the aspect mode of tyhe window is changed, you can override it as well, just remember to call super.viewDidSetVibrantLook()*/
    func viewDidSetVibrantLook(){
        if canUseVibrantLook && sharedUseFocusArea{
            if styleView == nil{
                styleView = NSView.init(frame: CGRect.init(x: 0, y: 73, width: self.view.frame.width, height: 205))
                styleView.backgroundColor = NSColor.white
                self.view.addSubview(styleView, positioned: .below, relativeTo: self.view)
            }else{
                styleView.frame = CGRect.init(x: 0, y: 73, width: self.view.frame.width, height: 205)
                styleView.backgroundColor = NSColor.white
                self.view.addSubview(styleView, positioned: .below, relativeTo: self.view)
                for cc in self.view.subviews{
                    if let c = cc as? NSVisualEffectView{
                        self.view.addSubview(c, positioned: .below, relativeTo: self.view)
                    }
                }
                styleView.isHidden = false
            }
            
        }else{
            if styleView != nil{
                styleView.isHidden = true
            }
        }
    }
}
