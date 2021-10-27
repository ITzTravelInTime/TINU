/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import Cocoa
import TINURecovery
import Command

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
		
		spinner?.isHidden = false
		spinner?.startAnimation(self)
		
		createUSBButton?.isHidden = true
		installButton?.isHidden = true
		efiButton?.isHidden = true
		
		Command.Printer.enabled = sharedEnableDebugPrints
		
		#if demo
		print("You have successfully enbled the \"demo\" macro!")
		#endif
		
		#if macOnlyMode
		print("This version of the app is compiled to be App Store Friendly!")
		#endif
		
		#if noFirstAuth
		if !Recovery.status{
			print("WARNING: this app has been compiled with the first step authentication disabled, it may be less secure to use!")
			//msgBoxWarning("WARNING", "This app has been compiled with first step authentication disabled, it may be less secure to use, use it at your own risk!")
		}
		#endif
		
		//}
		
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		/*if count < 2{
			DispatchQueue.global(qos: .background).async {
				DispatchQueue.main.sync {
					self.stopAnimationAndShowbuttons()
					self.swapCurrentViewController("Info")
				}
			}
		}else{*/
		//stopAnimationAndShowbuttons()
		//}
	}
	
	private var showed = false
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		if showed{
			return
		}
		
		showed = true
		
		#if sudoStartup
		
		if #available(OSX 10.15, *){
			
			DispatchQueue.global(qos: .background).async {
				DispatchQueue.main.sync {
					
						if ChooseSideViewController._already_prompted{
							return						}
						
						ChooseSideViewController._already_prompted = true
						
						if (SIPManager.status.isOkForTINU || CommandLine.arguments.contains("-disgnostics-mode")){
							return
						}
						
						Alert.window = self.window
						
						//todo: localize this
						//let alert = Alert(message: "TINU needs be re-opened using diagnostics mode!", description: "SIP (System Integrity Protection) is currently enabled, and it will prevent TINU from working (this is due to a problem introduced in Catalina).\n\nYou can avoid this by chosing to use the diagnostics mode with administrator privileges (because it avoids this issue by using the privileges provvided by the terminal).").adding(button: .init(text: "Use diagnostics mode", keyEquivalent: "\r")).adding(button: .init(text: "Continue anyway")).send().isFirstButton()
						
						let alert = dialogGenericWithManagerBool(self, name: "SIPDialog")
						
						if alert{
							DiagnosticsModeManager.shared.open(withSudo: true)
						}
				}
			}
			
		}
		
		#endif
		
		DispatchQueue.main.async {
		if #available(macOS 11.0, *), look.usesSFSymbols() {} else {
			if look != .recovery{
				self.createUSBButton.fullSizeImage = true
				self.createUSBButton.lowerText     = false
			}
		}
		
			self.createUSBButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "externaldrive.badge.plus"), imageName: !look.isRecovery() ? "drive" : nil, alternative: IconsManager.shared.removableDiskIcon.themedImage()).themedImage()
		
			self.installButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "desktopcomputer"), imageName: NSImage.computerName).themedImage()
		
			self.efiButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "tray"), imageName: "EFIIcon").themedImage()
		
			self.createUSBButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstaller")//"Create a bootable\nmacOS installer"
		
			self.installButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstallation")//"Install macOS"
		
			self.efiButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openEFIMounter")//"Use \nEFI Partition Mounter"
		
		var spacing: CGFloat = 22
		let buttonSize = CGSize(width: 180, height: 180)
		
		if !Recovery.status{
			self.installButton?.isEnabled = false
			spacing = (self.view.frame.size.width - (buttonSize.width * 2)) / 3
			spacing *= 1.2//1.05
		}else{
			self.installButton?.isEnabled = true
			spacing = (self.view.frame.size.width - (buttonSize.width * 3)) / 4
		}
		
		#if macOnlyMode
		efiButton.isEnabled = false
		#endif
			
			for v in self.background.subviews{
				for vv in self.background.subviews{
					vv.removeFromSuperview()
				}
				v.removeFromSuperview()
			}
			
			self.background.removeFromSuperview()
		
			self.background.frame.size.height = buttonSize.height + 40
		
			self.background.frame.size.width = spacing//(!sharedIsOnRecovery ? (spacing * 1.25) : spacing)
		
			self.count = 0
		
		for c in self.view.subviews.reversed(){
			guard let b = c as? ChoseButton else{ continue }
			
			b.isHidden = !b.isEnabled
			
			b.removeFromSuperview()
			
			if !b.isEnabled { continue }
			
			self.count += 1
			
			//b.frame.size = installButton.frame.size
			
			var shadowView: NSView!
			
			if look == .recovery{
				shadowView = NSView()
				shadowView.backgroundColor = NSColor.transparent
				b.fullSizeImage = false
				b.lowerText = true
			}else{
				 let _shadowView = ShadowView()
				
				_shadowView.setModeFromCurrentLook()
				
				b.lowerText = !b.fullSizeImage
				
				b.layer?.cornerRadius = _shadowView.layer?.cornerRadius ?? 5
				b.layer?.masksToBounds = true
				
				shadowView = _shadowView as NSView
			}
			
			shadowView.frame.size = buttonSize
			b.frame.size = buttonSize
			b.frame.origin = CGPoint.zero
			shadowView.frame.origin = NSPoint(x: self.background.frame.width, y: 20)
			shadowView.needsLayout = true
			//shadowView.layer?.masksToBounds = true
			
			shadowView.addSubview(b)
			self.background.addSubview(shadowView)
			
			//self.view.addSubview(shadowView)
			
			shadowView.updateLayer()
			b.updateLayer()
			
			self.background.frame.size.width += buttonSize.width + spacing//((!sharedIsOnRecovery && count == 1) ? (spacing * 1.25) : spacing)
		}
		
			self.background.frame.origin = NSPoint(x: self.view.frame.width / 2 - self.background.frame.size.width / 2, y: self.view.frame.height / 2 - self.background.frame.size.height / 2)
			self.background.backgroundColor = .transparent
			
			self.view.addSubview(self.background)
			
			self.createUSBButton?.isHidden = false
			self.installButton?.isHidden = false
			self.efiButton?.isHidden = false
			
			self.stopAnimationAndShowbuttons()
		}
	}
	
	func stopAnimationAndShowbuttons(){
		self.spinner.stopAnimation(self)
		self.spinner.isHidden =  true
		
		self.view.addSubview(background)
		
		self.window?.makeKey()
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
