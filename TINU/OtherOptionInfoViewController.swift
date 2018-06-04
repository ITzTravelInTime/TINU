//
//  OtherOptionInfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 02/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class OtherOptionsInfoViewController: NSViewController {
	
	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
	@IBOutlet weak var titleView: NSTextField!
	
	public var associatedOption: OtherOptionsObject!
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		if let option = associatedOption{
			titleView.stringValue = "Info about: " + option.displayMessage
			
			if let desc = associatedOption?.description{
				textView.text = desc
			}
		}
		
	}
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		
		if associatedOption == nil{
			self.window.close()
		}
		
		if associatedOption.description == nil{
			self.window.close()
		}
	}
	
	@IBAction func buttonClick(_ sender: Any) {
		self.window.close()
	}
}
