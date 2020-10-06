//
//  MainCreationFinished.swift
//  TINU
//
//  Created by Pietro Caruso on 31/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import Cocoa

class MainCreationFinishedViewController: GenericViewController, ViewID{
	
	let id: String = "MainCreationFinishedViewController"
    
    @IBOutlet weak var exitButton: NSButton!
	@IBOutlet weak var logButton: NSButton!
	@IBOutlet weak var continueButton: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let w = sharedWindow{
            w.isClosingEnabled = true
            w.isMiniaturizeEnaled = true
        }
        
        if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
		
		let suffix = (FinalScreenSmallManager.shared.isOk ? "Yes" : "No")
		continueButton.title = TextManager.getViewString(context: self, stringID: "continueButton" + suffix)
		logButton.title = TextManager.getViewString(context: self, stringID: "logButton")
		
		var image = NSImage()
        if !FinalScreenSmallManager.shared.isOk{
            image = IconsManager.shared.stopIcon
            continueButton.isEnabled = true
            continueButton.frame.size.width = exitButton.frame.size.width
            continueButton.frame.origin.x = exitButton.frame.origin.x
			exitButton.isHidden = true
        }else{
			exitButton.title = TextManager.getViewString(context: self, stringID: "exitButton")
            image = NSImage(named: "checkVector")!
            continueButton.isEnabled = true
            continueButton.isHidden = false
        }
		
		setFailureImage(image: image)
		showFailureImage()
		
		setFailureLabel(text: FinalScreenSmallManager.shared.title)
		failureLabel.font = NSFont.boldSystemFont(ofSize: failureLabel.font!.pointSize)
		let old = failureLabel.frame.size.height
		failureLabel.frame.size.height *= 3
		failureLabel.frame.origin.y -= old * 2
		
		showFailureLabel()
		
		let _ = NotificationsManager.sendWith(id: "processEnd" + suffix, image: nil)
    }

    @IBAction func exit(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func goNext(_ sender: Any) {
        LogManager.clearLog(true)
		
		sawpCurrentViewController(with: "chooseSide")
    }
    
    @IBAction func checkLog(_ sender: Any) {
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        
        logWindow!.showWindow(self)
 }
    
}

