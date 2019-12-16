//
//  EFIPartitionMounterLicenseViewController.swift
//  EFI Partition Mounter
//
//  Created by Pietro Caruso on 20/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class EFIPartitionMounterLicenseViewController: AppVC{
    
    //@IBOutlet weak var warningImage: NSImageView!
    //@IBOutlet weak var warningLabel: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var scroller: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var licenseInfoLink: HyperTextField!
    @IBAction func back(_ sender: Any) {
        self.window.close()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleLabel(text: "License")
        showTitleLabel()
        
        self.scroller.isHidden = true
        
        self.spinner.isHidden = false
        self.spinner.startAnimation(self)
        
        DispatchQueue.global(qos: .background).async {
        if let rtfPath = Bundle.main.url(forResource: "License", withExtension: "rtf") {
            do {
                let attributedStringWithRtf:NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                
                DispatchQueue.main.sync {
                    self.textView.text = attributedStringWithRtf.string
                    
                    self.spinner.isHidden = true
                    self.spinner.stopAnimation(self)
                    
                    self.scroller.isHidden = false
                }
                
            } catch let error {
                print("Get license error, skipping: \(error)")
                DispatchQueue.main.sync {
                    self.setWarning()
                }
            }
        }else{
            print("Get license error, skipping: license file not found")
            DispatchQueue.main.sync {
                self.setWarning()
            }
        }
            
        }
        
    }
    
    func setWarning(){
        //warningImage.image = IconsManager.shared.warningIcon
        //warningImage.isHidden = false
        
        //warningLabel.isHidden = false
        
        setFailureImage(image: IconsManager.shared.warningIcon)
        setFailureLabel(text: "Can't load the license agreement")
        showFailureImage()
        showFailureLabel()
        
        licenseInfoLink.isHidden = false
        
        spinner.stopAnimation(self)
        spinner.isHidden = true
        
    }
    
}
