/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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
import TINUSerialization

class ChooseSideViewController: GenericViewController, ViewID {
	let id: String = "ChooseSideViewController"

    @IBOutlet weak var createUSBButton: ChoseButton!
    
    @IBOutlet weak var installButton: ChoseButton!
	
	@IBOutlet weak var efiButton: ChoseButton!
	
	@IBOutlet weak var appDownloadButton: ChoseButton!
    
    @IBOutlet weak var titleField: NSTextField!
	
	@IBOutlet weak var spinner: NSProgressIndicator!
	
	@IBInspectable var usesSameRowForChoseButtons: Bool = true
	
	let background = NSView()
	
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
		appDownloadButton?.isHidden = true
		
		Command.Printer.enabled = sharedEnableDebugPrints
		TINUSerialization.Printer.printDebugLines = sharedEnableDebugPrints
		
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
			
			var count: CGFloat = 0
			
			self.installButton?.isEnabled = Recovery.status
			self.appDownloadButton?.isEnabled = !Recovery.status
			
			#if macOnlyMode
				efiButton.isEnabled = false
			#endif
			
			for cc in self.view.subviews.reversed(){
				guard let c = cc as? ChoseButton else{
					continue
				}
				
				if !c.isEnabled{
					continue
				}
				
				count += 1
			}
			
			self.createUSBButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "externaldrive.badge.plus"), imageName: !look.isRecovery() ? "drive" : nil, alternative: IconsManager.shared.removableDiskIcon.themedImage()).themedImage()
			
			self.installButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "desktopcomputer"), imageName: NSImage.computerName).themedImage()
			
			self.efiButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "tray"), imageName: "EFIIcon").themedImage()
			
			self.appDownloadButton?.cImage.image = Icon(path: nil, symbol: SFSymbol(name: "square.and.arrow.down"), imageName: "InstallApp").themedImage()
			
			self.createUSBButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstaller")//"Create a bootable\nmacOS installer"
			
			self.installButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openInstallation")//"Install macOS"
			
			self.efiButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openEFIMounter")//"Use \nEFI Partition Mounter"
			
			self.appDownloadButton?.cTitle.stringValue = TextManager.getViewString(context: self, stringID: "openAppDownloads")
			
			var spacing: CGFloat = 22
			
			let mcount: CGFloat = count > 3 ? 3 : count
			
			var size = (self.view.frame.width - (spacing * (mcount + 1))) / mcount
			
			if size > 170{
				size = 170
				spacing = (self.view.frame.size.width - (size * mcount)) / (mcount + 1)
			}
			
			let buttonSize = CGSize(width: size, height: size)//CGSize(width: 140, height: 140)
			
			//if !Recovery.status{
				//spacing = (self.view.frame.size.width - (buttonSize.width * 3)) / 4
			//}else{
				//spacing = (self.view.frame.size.width - (buttonSize.width * 4)) / 5
			//}
			
			for v in self.background.subviews{
				for vv in self.background.subviews{
					vv.removeFromSuperview()
				}
				v.removeFromSuperview()
			}
			
			self.background.removeFromSuperview()
			
			//self.background.frame.size.height = 40
			
			//self.background.frame.size.width = spacing//(!sharedIsOnRecovery ? (spacing * 1.25) : spacing)
			
			let rest: CGFloat = CGFloat(UInt(count) % 3)
			let nrows: CGFloat = self.usesSameRowForChoseButtons ? 1 : (CGFloat(UInt(count) / 3) + (rest != 0 ? 1 : 0))
			
			var setted: CGFloat = -1
			
			self.background.frame.size.width = (count > 3 && !self.usesSameRowForChoseButtons ) ? ((spacing * 4) + (buttonSize.width * 3)) : (spacing * (count + 1) + (buttonSize.width * count))
										
			self.background.frame.size.height = (spacing * ( nrows + 1 ) + buttonSize.height * nrows)
			
			let itmpPos: CGPoint = .init(x: /*self.background.frame.width - buttonSize.width -*/ spacing, y: self.background.frame.height - buttonSize.height - spacing)
			
			var tmpPos = itmpPos
			
			for c in self.view.subviews.reversed(){
				guard let b = c as? ChoseButton else{ continue }
				
				setted += 1
				
				b.isHidden.toggle()
				
				b.removeFromSuperview()
				
				if !b.isEnabled { continue }
				
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
				shadowView.frame.origin = tmpPos
				shadowView.needsLayout = true
				//shadowView.layer?.masksToBounds = true
				
				shadowView.addSubview(b)
				self.background.addSubview(shadowView)
				
				//self.view.addSubview(shadowView)
				
				shadowView.updateLayer()
				b.updateLayer()
				
				//self.background.frame.size.width += buttonSize.width + spacing//((!sharedIsOnRecovery && count == 1) ? (spacing * 1.25) : spacing)
				
				if UInt(setted + 1) % 3 == 0 && setted != 0 && !self.usesSameRowForChoseButtons{
					tmpPos.y -= buttonSize.height + spacing
					tmpPos.x = itmpPos.x
				}else{
					tmpPos.x += buttonSize.width + spacing
				}
				
			}
			
			if nrows > 1 {
				let ammount = (spacing + buttonSize.height) * (nrows - 1)
				self.view.frame.size.height += ammount
				var frame = self.window.frame
				frame.size.height += ammount
				frame.origin.y -= ammount / 2
				
				self.window.setFrame(frame, display: true)
			}
			
			if self.usesSameRowForChoseButtons && count >= 4{
				let ammount = (spacing + buttonSize.width) * (count - 3)
				
				var frame = self.window.frame
				frame.size.width += ammount
				frame.origin.x -= ammount / 2
				
				self.window.setFrame(frame, display: true)
			}
		
			self.background.frame.origin = CGPoint(x: self.view.frame.width / 2 - self.background.frame.size.width / 2, y: self.view.frame.height / 2 - self.background.frame.size.height / 2)
			
			self.background.backgroundColor = .transparent
			
			self.view.addSubview(self.background)
			
			self.stopAnimationAndShowbuttons()
			
			for c in self.view.subviews.reversed(){
				guard let _ = c as? ChoseButton else{ continue }
				
				c.isHidden = false
			}
			
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
	
	@IBAction func openAppDownloads(_ sender: Any){
		if let apd = NSApp.delegate as? AppDelegate{
			apd.openDownloadMacApp(sender)
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
