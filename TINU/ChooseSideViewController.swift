//
//  chooseSideViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 18/12/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa


class ChooseSideViewController: GenericViewController, ViewID {
	let id: String = "ChooseSideViewController"

    @IBOutlet weak var createUSBButton: ChoseButton!
    
    @IBOutlet weak var installButton: ChoseButton!
	
	@IBOutlet weak var efiButton: ChoseButton!
    
    @IBOutlet weak var titleField: NSTextField!
	
	@IBOutlet weak var spinner: NSProgressIndicator!
	
	let background = NSView()
	
	private var count = 0
	
	
	#if sudoStartup
	private static var _already_prompted = false
	private static let _prompt_sip = "SIPPrompt"
	private static let _prompt_sip_result = "SIPPromptResult"
	#endif
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/*
		DispatchQueue.global(qos: .background).async {
		print(runCommandWithSudo(cmd: "/bin/sh", args: ["-c", "whoami"])!)
		}*/
		
		spinner.isHidden = false
		spinner.startAnimation(self)
		
		createUSBButton.isHidden = true
		installButton.isHidden = true
		
		//checks settings here because this function is the first to be executed in the app
		App.Settings.check()
		
		#if demo
		print("You have successfully enbled the \"demo\" macro!")
		#endif
		
		#if macOnlyMode
		print("This version of the app is compiled to be App Store Friendly!")
		#endif
		
		#if noFirstAuth
		if !Recovery.isOn{
			print("WARNING: this app has been compiled with the first step authentication disabled, it may be less secure to use!")
			//msgBoxWarning("WARNING", "This app has been compiled with first step authentication disabled, it may be less secure to use, use it at your own risk!")
		}
		#endif
		
		//}
		
		if let w = UIManager.shared.window{
			w.title = UIManager.shared.windowTitlePrefix
		}
		
		if #available(macOS 11.0, *), look.usesSFSymbols() {
			createUSBButton.cImage.image = NSImage(systemSymbolName: "externaldrive.badge.plus", accessibilityDescription: nil)?.withSymbolWeight(.ultraLight)
			createUSBButton.cImage.contentTintColor = .systemGray
			installButton.cImage.image = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil)?.withSymbolWeight(.ultraLight)
			installButton.cImage.contentTintColor = .systemGray
			efiButton.cImage.image = NSImage(systemSymbolName: "tray", accessibilityDescription: nil)?.withSymbolWeight(.ultraLight)
			efiButton.cImage.contentTintColor = .systemGray
		} else {
			//createUSBButton.cImage.image = IconsManager.shared.removableDiskIcon //NSImage(named: "Removable")
			if !look.usesSFSymbols() && look.supportsShadows(){
				createUSBButton.cImage.image = NSImage(named: "drive")
				createUSBButton.fullSizeImage = true
				createUSBButton.lowerText     = false
			}else{
				createUSBButton.cImage.image = IconsManager.shared.removableDiskIcon
			}
			
			installButton.cImage.image = NSImage(named: NSImage.computerName)//NSImage(named: "OSInstall")
			
			efiButton.cImage.image = NSImage(named: "EFIIcon")
		}
		
		createUSBButton.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstaller")//"Create a bootable\nmacOS installer"
		
		installButton.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstallation")//"Install macOS"
		
		efiButton.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openEFIMounter")//"Use \nEFI Partition Mounter"
		
		var spacing: CGFloat = 20
		
		if !Recovery.isOn{
			installButton.isEnabled = false
			spacing = (self.view.frame.size.width - (installButton.frame.size.width * 2)) / 3
		}
		
		#if macOnlyMode
		efiButton.isEnabled = false
		#endif
		
		background.frame.size.height = installButton.frame.size.height + 40
		
		background.frame.size.width = spacing//(!sharedIsOnRecovery ? (spacing * 1.25) : spacing)
		
		count = 0
		
		for c in self.view.subviews.reversed(){
			guard let b = c as? ChoseButton else{ continue }
			
			b.isHidden = !b.isEnabled
			
			if !b.isEnabled { continue }
			
			count += 1
			
			b.removeFromSuperview()
			
			b.frame.size = installButton.frame.size
			b.frame.origin = CGPoint.zero
			
			var shadowView: NSView!
			
			if look == .recovery{
				shadowView = NSView()
				shadowView.backgroundColor = NSColor.transparent
				b.fullSizeImage = false
				b.lowerText = true
			}else{
				shadowView = ShadowView()
				
				b.lowerText = !b.fullSizeImage
				
				b.layer?.cornerRadius = shadowView.layer!.cornerRadius
				b.layer?.masksToBounds = true
			}
			
			shadowView.frame.size = b.frame.size
			shadowView.frame.origin = NSPoint(x: background.frame.width, y: 20)
			//shadowView.needsLayout = true
			shadowView.layer?.masksToBounds = true
			
			shadowView.updateLayer()
			b.updateLayer()
			
			shadowView.addSubview(b)
			
			background.addSubview(shadowView)
			
			background.frame.size.width += installButton.frame.size.width + spacing//((!sharedIsOnRecovery && count == 1) ? (spacing * 1.25) : spacing)
		}
		
		background.frame.origin = NSPoint(x: self.view.frame.width / 2 - background.frame.size.width / 2, y: self.view.frame.height / 2 - background.frame.size.height / 2)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		if count < 2{
			DispatchQueue.global(qos: .background).async {
				DispatchQueue.main.sync {
					self.stopAnimationAndShowbuttons()
					
					self.swapCurrentViewController("Info")
					
				}
			}
		}else{
			stopAnimationAndShowbuttons()
		}
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		#if sudoStartup
		
		if #available(OSX 10.15, *){
			if !User.isRoot{
			
				if !ChooseSideViewController._already_prompted{
					if (SIPManager.checkStatus()){
				
						DiagnosticsModeManager.shared.open(withSudo: true)
					
					}else{
					
					}
				
					ChooseSideViewController._already_prompted = true
				
				}
			
				//NSApplication.shared().terminate(self)
			
			}
		}
		
		#endif
	}
	
	func stopAnimationAndShowbuttons(){
		self.spinner.stopAnimation(self)
		self.spinner.isHidden =  true
		
		self.view.addSubview(background)
	}
	
	@IBAction func openEFIMounter(_ sender: Any){
		if let apd = NSApp.delegate as? AppDelegate{
			apd.openEFIPartitionTool(sender)
		}
	}
	
	@IBAction func createUSB(_ sender: Any) {
		if let apd = NSApplication.shared.delegate as? AppDelegate{
			apd.swichMode(isInstall: false)
		}
	}
	
	@IBAction func install(_ sender: Any) {
		if let apd = NSApplication.shared.delegate as? AppDelegate{
			apd.swichMode(isInstall: true)
		}
	}
	
	
}
