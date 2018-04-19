//
//  AppDownloadViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 17/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

class DownloadAppViewController: GenericViewController {

	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var hsButton: NSButton!
	
	@IBOutlet weak var sButton: NSButton!
	
	@IBOutlet weak var elButton: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if self.window != sharedWindow{
			self.window.title = "Download a macOS installer app from the app store"
			closeButton.stringValue = "Close"
		}
	}
	
	@IBAction func buttonClick(_ sender: Any) {
		if self.window != sharedWindow{
			self.window.close()
		}
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
