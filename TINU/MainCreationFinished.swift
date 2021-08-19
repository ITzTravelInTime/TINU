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
	
	static var title: String = ""
	
	let id: String = "MainCreationFinishedViewController"
    
    @IBOutlet weak var exitButton: NSButton!
	@IBOutlet weak var logButton: NSButton!
	@IBOutlet weak var continueButton: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let w = UIManager.shared.window{
            w.isClosingEnabled = true
            w.isMiniaturizeEnaled = true
        }
        
        if let a = NSApplication.shared.delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
		
		let suffix = ((cvm.shared.process.status == .doneSuccess) ? "Yes" : "No")
		continueButton.title = TextManager.getViewString(context: self, stringID: "continueButton" + suffix)
		logButton.title = TextManager.getViewString(context: self, stringID: "logButton")
		exitButton.title = TextManager.getViewString(context: self, stringID: "exitButton")
		
		var image: NSImage!
        if (cvm.shared.process.status != .doneSuccess){
			image = IconsManager.shared.roundStopIcon.themedImage()
			
            continueButton.isEnabled = true
            continueButton.frame.size.width = exitButton.frame.size.width
            continueButton.frame.origin.x = exitButton.frame.origin.x
        }else{
			image = IconsManager.shared.checkIcon.themedImage()
            continueButton.isEnabled = true
            continueButton.isHidden = false
        }
		
		setFailureImage(image: image)
		
		if #available(macOS 11.0, *), look.usesSFSymbols(){
			if failureImageView != nil{
				//failureImageView.contentTintColor = .systemGray
				//failureImageView.image = failureImageView.image?.withSymbolWeight(.thin)
				failureImageView.contentTintColor = (cvm.shared.process.status == .doneSuccess) ? .systemGreen : .systemRed
			}
		}
		
		showFailureImage()
		
		setFailureLabel(text: MainCreationFinishedViewController.title)
		
		let old = failureLabel.frame.size.height
		failureLabel.frame.size.height *= 3
		failureLabel.frame.origin.y -= old * 2
		
		showFailureLabel()
		
		Notifications.justSendWith(id: "processEnd" + suffix, icon: nil)
    }

    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func goNext(_ sender: Any) {
        //LogManager.clear(true)
		LogManager.clearLog()
		
		swapCurrentViewController("chooseSide")
    }
    
    @IBAction func checkLog(_ sender: Any) {
        if UIManager.shared.logWC == nil {
			UIManager.shared.logWC = LogWindowController()
        }
        
		UIManager.shared.logWC?.showWindow(self)
 }
    
}

