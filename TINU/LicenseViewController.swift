//
//  LicenseViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 06/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class LicenseViewController: GenericViewController {
    
    @IBOutlet weak var continueButton: NSButton!
    
    @IBOutlet var licenseField: NSTextView!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var scroller: NSScrollView!
    
    override func viewDidSetVibrantLook(){
        super.viewDidSetVibrantLook()
        
        if styleView != nil{
            styleView.isHidden = true
        }
        
        if canUseVibrantLook {
            scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
            scroller.borderType = .noBorder
            //scroller.drawsBackground = false
        }else{
            scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
            scroller.borderType = .bezelBorder
            //scroller.drawsBackground = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = false
        spinner.startAnimation(self)
        scroller.isHidden = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            if let rtfPath = Bundle.main.url(forResource: "License", withExtension: "rtf") {
                do {
                    let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                    DispatchQueue.main.sync {
                        self.licenseField.text = attributedStringWithRtf.string
                        
                        self.spinner.isHidden = true
                        self.spinner.stopAnimation(self)
                        self.scroller.isHidden = false
                    }
                    
                } catch let error {
                    print("Get license error, skipping: \(error)")
                    DispatchQueue.main.sync {
                        let _ = self.openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
                    }
                }
            }else{
                print("Get license error, skipping: license file not found")
                DispatchQueue.main.sync {
                    let _ = self.openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func readedChanged(_ sender: Any) {
        if let s = sender as? NSButton{
            if s.state == 1{
                continueButton.isEnabled = true
            }else{
                continueButton.isEnabled = false
            }
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: sender)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        let _ = openSubstituteWindow(windowStoryboardID: "Info", sender: sender)
    }
}
