//
//  OtherOptionInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 02/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class OtherOptionsInfoViewController: GenericViewController {
	
	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
	
	public var associatedOption: OtherOptionsObject!
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
		scroller.borderType = .bezelBorder
		
		self.setTitleLabel(text: "")
		showTitleLabel()
		
		if let option = associatedOption{
			titleLabel.stringValue = "Info about: " + option.title
			
			if let desc = associatedOption?.description{
				textView.text = desc
			}
		}
		
		textView.textColor = NSColor.textColor
		
	}
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		
		textView.textColor = NSColor.textColor
		
		if associatedOption == nil || associatedOption.description == nil{
			goBack()
		}
	}
	
	@IBAction func buttonClick(_ sender: Any) {
		
		goBack()
	}
	
	@inline(__always) func goBack(){
		//CustomizationWindowManager.shared.referenceWindow = self.window.sheetParent
		CustomizationWindowManager.shared.referenceWindow.endSheet(self.window!)
	}
	
	/*override func viewDidSetVibrantLook() {
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
}
