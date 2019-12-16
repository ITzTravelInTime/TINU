//
//  DriveDetectInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 23/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class DriveDetectInfoViewController: GenericViewController {

	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
	
    override public func viewDidLoad() {
        super.viewDidLoad()
		
		textView.font = NSFont.systemFont(ofSize: 15)
		
		for i in getTextContent(){
			textView.text += i + "\n\n"
		}
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		
		self.setTitleLabel(text: "To make sure that your storage device will be detected:")
		self.showTitleLabel()
		
		textView.textColor = NSColor.textColor
		
		if self.presenting == nil{
		//if self.window != sharedWindow{
			self.button.stringValue = "Close"
			self.button.title = "Close"
			self.button.alternateTitle = "Close"
		}
	}
	
	/*override func viewDidSetVibrantLook() {
		super.viewDidSetVibrantLook()
		if canUseVibrantLook {
			scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
			scroller.borderType = .noBorder
			//scroller.drawsBackground = false
		}else{
			scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
			scroller.borderType = .bezelBorder
			//scroller.drawsBackground = true
		}
	}*/
	
    @IBAction func buttonClick(_ sender: Any) {
		if self.presenting == nil{
			self.window.close()
		}else{
			self.window.sheetParent?.endSheet(self.window)
		}
    }
}

//it's outside the main function class just for ordering purposes
extension DriveDetectInfoViewController{
	func getTextContent() -> [String]{
		var text = [String]()
		
		text.append("• Make sure that your disk device is working, e.g. by copying files to it.") // Don't say "correctly" unless you document what correctly is - a layman will not known what correct is unless you explain.
		text.append("• Verify that any adapters, cables or devices you use to attach your disk device to the computer are correctly plugged in, working, and if needed, correctly installed, and that your version of macOS does work with these particular devices, adapters or peripherals you are using.")
		
		text.append("• Make sure the disk device you have chosen is a physical device and not a virtual device. Virtual devices may not work properly with this app.")
		
		text.append("• Try to format it in Disk Utility using the \"macOS Extended (journaled)\" format before using it with this app.")
		
		if sharedInstallMac{
			text.append("• TINU will only detect drives that can be used to install macOS.") // no need to be redundant by also saying the opposize. It only adds needless text.
			
			text.append("• Make sure the disk device (drive) or the partition you want to use is at least 20 GB. If your drive is big enough but the partition you want to use is not, you have to use Disk Utility to create a partition of at least 20 GB on that drive, or you have resize the partition you want to use.")
		}else{
			text.append("• TINU will detect only disk devices that are usable to create a bootable macOS installer.")	// again, no need to be redundant
			
			text.append("• Make sure that the chosen disk does not contain the partition from which you have booted the system and that it's not the internal SSD or hard disk of your Mac.")	// TODO: TINU could look into the ioregistry to see whether the chosen disk is internal or external, or simply run "diskutil list" and fetch the info from there.
			
			text.append("• Make sure that the disk device (drive) or the partition you want to use is at least 8 GB. If your drive is big enough but the partition you want to use is not, you have to use Disk Utility to create a partition of at least 8 GB on that drive, or you have resize the partition you want to use.")
		}
		
		return text
	}
}
