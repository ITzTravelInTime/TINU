//
//  OtherOptionInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 02/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class OtherOptionsInfoViewController: GenericViewController, ViewID {
	
	public let id: String = "OtherOptionsInfoViewController"
	
	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
	
	public var optionID: CreationProcess.OptionsManager.ID!
	
	private var associatedOption: CreationProcess.OptionsManager.Object!{
		return CreationProcess.shared.options.list[optionID]
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
		scroller.borderType = .bezelBorder
		
		self.setTitleLabel(text: "")
		showTitleLabel()
		
		if let option = associatedOption{
			titleLabel.stringValue = TextManager.getViewString(context: self, stringID: "infoPrefix") + option.description.title
			
			if let desc = associatedOption?.description{
				textView.text = desc.desc
			}
		}
		
		textView.textColor = NSColor.textColor
		
	}
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		
		textView.textColor = NSColor.textColor
		
		if associatedOption == nil{
			goBack()
		}
		
		self.window.minSize = CGSize(width: 620, height: 300)
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
