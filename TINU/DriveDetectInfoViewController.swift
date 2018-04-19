//
//  DriveDetectInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 23/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class DriveDetectInfoViewController: NSViewController {

	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		textView.font = NSFont.systemFont(ofSize: 15)
		
		for i in getTextContent(){
			textView.text += i + "\n\n"
		}
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		if self.window != sharedWindow{
			self.window.title = "Why my storage device is not detected?"
			button.stringValue = "Close"
		}
	}
    
    @IBAction func buttonClick(_ sender: Any) {
        if self.window != sharedWindow{
            self.window.close()
        }
    }
}

extension DriveDetectInfoViewController{
	func getTextContent() -> [String]{
		var text = [String]()
		
		text.append("• Verify that you device is correctly working and correctly connected to the machine")
		text.append("• Verify that any adapters, cables or devices you use to attach your device to the computer are correctly plugged in, working, and if needed, correctly installed, and that your version of macOS does work with the particular devices, adapters or peripherals you are using")
		
		text.append("• Make sure your device is a physical device and not a virtual device, virtual devices may not work properly with this app")
		
		text.append("• Try to format it in disk utility using macOS extended (journaled), before using it with this app")
		
		if sharedInstallMac{
			text.append("• TINU will detect only drives which are usable to install macOS, all the others drives will not be detected by TINU")
			
			text.append("• Make sure the device or the partition you want o to use is at least 20 GB, if your drive is big enought but the partition you want to use is not big enuogh, you have to go in disk utility and create a partition of at least 20 GB in that device, or you have to make bigger enougth the partition you want to use")
		}else{
			text.append("• TINU will detect only drives which are usable to create a macOS install media, all the others drives will not be detected by TINU")
			
			text.append("• Make sure that your device does not contains the partition from which you have booted the system and that it,s not the internal ssd/hard disk of your mac")
			
			text.append("• Make sure the device or the partition you want o to use is at least 8 GB, if your drive is big enought but the partition you want to use is not big enuogth, you have to go in disk utility and create a partition of at least 8 GB in that device, or you have to make bigger enougth the partition you want to use")
		}
		
		return text
	}
}
