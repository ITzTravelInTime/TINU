//
//  AppDownloadViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 17/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class DownloadAppViewController: GenericViewController {

	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var hsButton: NSButton!
	
	@IBOutlet weak var sButton: NSButton!
	
	@IBOutlet weak var elButton: NSButton!
	
	override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		if self.presenting == nil{
		//if self.window != sharedWindow{
			closeButton.stringValue = "Close"
			closeButton.title = "Close"
			closeButton.alternateTitle = "Close"
		}
	}
	
	override func viewDidSetVibrantLook() {
		super.viewDidSetVibrantLook()
		
	}
	
	@IBAction func buttonClick(_ sender: Any) {
			self.window.close()
	}
	
	@IBAction func mjClick(_ sender: Any) {
		NSWorkspace.shared().open(URL(string: "macappstores://itunes.apple.com/app/macos-mojave/id1398502828")!)
	}
	
	@IBAction func hsClick(_ sender: Any) {
		NSWorkspace.shared().open(URL(string: "macappstores://itunes.apple.com/app/macos-high-sierra/id1246284741")!)
	}
	
	@IBAction func sClick(_ sender: Any) {
		NSWorkspace.shared().open(URL(string: "macappstores://itunes.apple.com/app/macos-sierra/id1127487414")!)
	}
	
	@IBAction func elClick(_ sender: Any) {
		NSWorkspace.shared().open(URL(string: "macappstores://itunes.apple.com/app/os-x-el-capitan/id1147835434")!)
	}
	
}
