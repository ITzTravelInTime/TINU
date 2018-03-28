//
//  DriveDetectInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 23/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

class DriveDetectInfoViewController: NSViewController {

	@IBOutlet var textView: NSTextView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		textView.font = NSFont.systemFont(ofSize: 15)
		
		for i in getTextContent(){
			textView.text += i + "\n\n"
		}
    }
}

extension DriveDetectInfoViewController{
	func getTextContent() -> [String]{
		var text = [String]()
		
		text.append("• Verify that you device is correctly working and correctly coonected to the machine")
		text.append("• Verify that any adapters, cables or devices you use to attach your device to the computer are corrrectly pluggeg in, working, and if needed, correctly installed, and that your version of macOS does work with the particular devices, adapters or peripherials you are using")
		
		text.append("• Make sure your device is a phisical device and not a virtual device, virtual devices may not work properly with this app")
		
		text.append("• Try to format it in disk utility using macOS extended (journaled), before using it with this app")
		
		if sharedInstallMac{
			text.append("• Make sure the device or the partition you want o to use is at least 20 GB, if your drive is big enought but the partition you want to use is not big enuogth, you have to go in disk utility and create a partition of at least 20 GB in that device, or you have to make bigger enougth the partition you want to use")
		}else{
			text.append("• Make sure that your device does not contains the partition from which you have booted the system and that it,s not the internal ssd/hard disk of your mac")
			
			text.append("• Make sure the device or the partition you want o to use is at least 8 GB, if your drive is big enought but the partition you want to use is not big enuogth, you have to go in disk utility and create a partition of at least 8 GB in that device, or you have to make bigger enougth the partition you want to use")
		}
		
		return text
	}
}
