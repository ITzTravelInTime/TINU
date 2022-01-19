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

import Foundation
import AppKit

public class LogWindowController: NSWindowController, ViewID, NSSharingServicePickerDelegate, NSSharingServiceDelegate {
	
	public let id: String = "LogWindowController"
	
	@IBOutlet var saveLogItem: NSToolbarItem!
	@IBOutlet var copyLogItem: NSToolbarItem!
	@IBOutlet var shareLogItem: NSToolbarItem!
	
	@IBOutlet var saveLogButton: NSButton!
	@IBOutlet var copyLogButton: NSButton!
	@IBOutlet var shareLogButton: NSButton!
	
	override public func windowDidLoad() {
		super.windowDidLoad()
		
		self.saveLogItem.label = TextManager.getViewString(context: self, stringID: "saveButton")
		self.copyLogItem.label = TextManager.getViewString(context: self, stringID: "copyButton")
		self.shareLogItem.label = TextManager.getViewString(context: self, stringID: "shareButton")
		
		//Do not use the SFSymbols class for this
		if #available(OSX 11.0, *) {
			self.saveLogItem.image = SFSymbol(name: "tray.and.arrow.down").justImage()
			self.shareLogItem.image = SFSymbol(name: "square.and.arrow.up").justImage()
			self.copyLogItem.image = SFSymbol(name: "doc.on.clipboard").justImage()
		} else {
			self.saveLogItem.image = IconsManager.shared.internalDiskIcon.themedImage()
			self.copyLogItem.image = NSImage(named: NSImage.multipleDocumentsName)
		}
		
		if #available(macOS 10.15, *) {
			/*self.copyLogItem.target = self
			self.saveLogItem.target = self
			self.shareLogItem.target = self
			
			self.copyLogItem.action = #selector(self.copyLog(_:))
			self.saveLogItem.action = #selector(self.saveLog(_:))
			self.shareLogItem.action = #selector(self.shareLog(_:))*/
			return
		}
		
		DispatchQueue.global(qos: .userInteractive).async {
			var ok = false
			
			while(!ok){
				
				DispatchQueue.main.sync {
					
					guard let vc = self.contentViewController as? LogViewController else{
						log("view controller is still nil or not of the right kind, continuing")
						return }
					ok = true
					
					//For some reason connection actions won't work on high sierra and below
					self.copyLogItem.target = vc
					self.saveLogItem.target = vc
					self.shareLogItem.target = vc
					
					self.copyLogItem.action = #selector(vc.copyLog(_:))
					self.saveLogItem.action = #selector(vc.saveLog(_:))
					self.shareLogItem.action = #selector(vc.shareLog(_:))
					
					self.copyLogButton.target = vc
					self.saveLogButton.target = vc
					self.shareLogButton.target = vc
					
					self.copyLogButton.action = #selector(vc.copyLog(_:))
					self.saveLogButton.action = #selector(vc.saveLog(_:))
					self.shareLogButton.action = #selector(vc.shareLog(_:))
					
				}
				
			}
		}
	}
	
	@IBAction func saveLog( _ sender: Any){
		guard let vc = self.contentViewController as? LogViewController, let win = self.window else {
			log("Wrong view controller!")
			return }
		
		let open = NSSavePanel()
		open.isExtensionHidden = false
		//open.showsHiddenFiles = true
		
		open.allowedFileTypes = ["txt"]
		
		open.beginSheetModal(for: win, completionHandler: { response in
			if response == NSApplication.ModalResponse.OK{
				return
			}
			
			guard let u = open.url?.path else { return }
			//read ui stuff just from the main thread
			
			
			DispatchQueue.global(qos: .userInteractive).async {
				do{
					let text = LogManager.readAllLog() ?? ""
					try text.write(toFile: u, atomically: true, encoding: .utf8)
				}catch let error{
					log(error.localizedDescription)
					//msgBoxWarning("Error while saving the log file", "There was an error while saving the log file: \n\n" + error.localizedDescription)
					let prev = Alert.window
					Alert.window = win
					msgboxWithManager(vc, name: "saveError", parseList: ["{desc}" : error.localizedDescription])
					Alert.window = prev
				}
			}
			
		})
		
	}
	
	@IBAction func copyLog( _ sender: Any){
		DispatchQueue.global(qos: .background).async {
			
			NSPasteboard.general.clearContents()
			NSPasteboard.general.writeObjects([NSString(string: LogManager.readAllLog() ?? "")])
			
			Notifications.justSendWith(id: "copyLog", icon: nil)
		}
		
		print("Log copied to clipboard")
	}
	
	@IBAction func shareLog( _ sender: Any){
		print("Shared called")
		
		DispatchQueue.global(qos: .userInteractive).async {
			let text = LogManager.readAllLog() ?? ""
			
			DispatchQueue.main.sync {
				guard let sen = sender as? NSView else { return }
				
				print("Share good")
				
				let service = NSSharingServicePicker(items: [text])
				service.delegate = self
				service.show(relativeTo: sen.bounds, of: sen, preferredEdge: .minY)
				
			}
			
		}
	}
	
	convenience init() {
		//creates an instace of the window
		self.init(window: (UIManager.shared.storyboard.instantiateController(withIdentifier: "Log") as! NSWindowController).window)
	}
	
	override public func close() {
		UIManager.shared.logWC = nil
		super.close()
	}
	
	public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?){
		if let serv = service{
			serv.delegate = self
		}
	}
	
	public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate?{
		
		return self
	}
	
	public func sharingService(_ sharingService: NSSharingService,
							   sourceWindowForShareItems items: [Any],
							   sharingContentScope: UnsafeMutablePointer<NSSharingService.SharingContentScope>) -> NSWindow?{
		return self.window
	}
	
}
