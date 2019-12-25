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
		
		self.setTitleLabel(text: "Download a macOS installer app from the App Store")
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		if self.presenting == nil{
		//if self.window != sharedWindow{
			closeButton.stringValue = "Close"
			closeButton.title = "Close"
			closeButton.alternateTitle = "Close"
		}
		
		self.showTitleLabel()
	}
	
	/*
	override func viewDidSetVibrantLook() {
		super.viewDidSetVibrantLook()
		
	}
	*/

	@IBAction func buttonClick(_ sender: Any) {
		if self.presenting == nil{
			self.window.close()
		}else{
			self.window.sheetParent?.endSheet(self.window)
		}
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
	
	@IBAction func catClick(_ sender: Any) {
		NSWorkspace.shared().open(URL(string: "macappstores://itunes.apple.com/app/macos-catalina/id1466841314")!)
	}
	
}
