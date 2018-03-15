//
//  SharedInstances.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import AppKit

//this file just contains some usefoul extensions and methos for the UI

extension NSViewController{
    public func openSubstituteWindow(windowStoryboardID: String, sender: Any){
        
        let tempPos = self.view.window?.frame.origin
        
        let viewController: NSViewController? = storyboard?.instantiateController(withIdentifier: windowStoryboardID) as? NSViewController
        
        if viewController != nil{
            //presentViewControllerAsModalWindow(viewController!)
            
            //self.dismiss(sender)
            //self.view.window?.windowController?.close()
            
            if self.view.window != nil{
                self.view.window?.contentViewController = viewController
                
                self.view.window?.contentView = viewController?.view
                
                if !sharedIsOnRecovery{
                    if let w = viewController?.window.windowController as? GenericWindowController{
                        w.checkVibrant()
                    }
                }
                
                if tempPos != nil{
                    self.view.window?.setFrameOrigin(tempPos!)
                }
                
                self.view.exitFullScreenMode(options: nil)
                
                self.dismiss(self)
            }else{
                // :-(
            }
        }else{
            // :-(
        }
    }
    
    public func exportOptions(enabled: Bool){
        if enabled{
            if let _ = NSApplication.shared().delegate as? AppDelegate{
            //setup menu while windows canges
            }
        }
    }
    
    public var window: NSWindow!{
        get{
            return self.view.window
        }
    }
}

extension NSWindow{
    public var isClosingEnabled: Bool{
        set{
            if newValue{
                self.styleMask.insert(.closable)
                self.standardWindowButton(.closeButton)?.isEnabled = true
            }else{
                self.styleMask.remove(.closable)
                self.standardWindowButton(.closeButton)?.isEnabled = false
            }
        }
        get{
            return self.styleMask.contains(.closable) && (self.standardWindowButton(.closeButton)?.isEnabled)!
        }
    }
    
    public func exitFullScreen(){
        if self.styleMask.contains(.fullScreen){
            self.toggleFullScreen(false)
        }
    }
    
    public func makeFullScreen(){
        if self.styleMask.contains(.fullScreen) == false{
            self.toggleFullScreen(true)
        }
    }
    
    public var isFullScreenEnaled: Bool{
        set{
            if newValue{
                self.styleMask.insert(.resizable)
                self.standardWindowButton(.zoomButton)?.isEnabled = true
            }else{
                self.styleMask.remove([.resizable])
                self.standardWindowButton(.zoomButton)?.isEnabled = false
            }
        }
        get{
            return self.styleMask.contains(.resizable) && (self.standardWindowButton(.zoomButton)?.isEnabled)!
        }
    }
    
    public var isMiniaturizeEnaled: Bool{
        set{
            if newValue{
                self.styleMask.insert(.miniaturizable)
                self.standardWindowButton(.miniaturizeButton)?.isEnabled = true
            }else{
                self.styleMask.remove([.miniaturizable])
                self.standardWindowButton(.miniaturizeButton)?.isEnabled = false
            }
        }
        get{
            return self.styleMask.contains(.miniaturizable) && (self.standardWindowButton(.miniaturizeButton)?.isEnabled)!
        }
    }
}

extension NSTextView{
    public var text: String{
        set{
            self.string = newValue
        }
        get{
            if let s = self.string{
                return s
            }else{
                return ""
            }
        }
    }
}

extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension String{
    public func copy()-> String{
        return String(self.characters)
    }
}

@IBDesignable
class HyperTextField: NSTextField {
    @IBInspectable var href: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName: NSColor.blue
            ,NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject, NSCursorAttributeName: NSCursor.pointingHand()
        ]
        self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        NSWorkspace.shared().open(URL(string: self.href)!)
    }
}

public func msgBox(_ title: String,_ text: String,_ style: NSAlertStyle){
    let a = NSAlert()
    a.messageText = title
    a.informativeText = text
    a.alertStyle = style
    a.runModal()
}

public func msgBoxWarning(_ title: String,_ text: String){
    let a = NSAlert()
    a.messageText = title
    a.informativeText = text
    a.alertStyle = .warning
    a.icon = warningIcon
    a.runModal()
}

public func dialogOKCancel(question: String, text: String, style: NSAlertStyle) -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = style
    myPopup.addButton(withTitle: "OK")
    myPopup.addButton(withTitle: "Cancel")
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
        return false
    }
    return true
}

public func dialogYesNo(question: String, text: String, style: NSAlertStyle) -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = style
    myPopup.addButton(withTitle: "Yes")
    myPopup.addButton(withTitle: "No")
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
        return false
    }
    return true
}

public func dialogOKCancelWarning(question: String, text: String, style: NSAlertStyle) -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = style
    myPopup.addButton(withTitle: "OK")
    myPopup.addButton(withTitle: "Cancel")
    myPopup.icon = warningIcon
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
        return false
    }
    return true
}

public func dialogYesNoWarning(question: String, text: String, style: NSAlertStyle) -> Bool {
    let myPopup: NSAlert = NSAlert()
    myPopup.messageText = question
    myPopup.informativeText = text
    myPopup.alertStyle = style
    myPopup.addButton(withTitle: "Yes")
    myPopup.addButton(withTitle: "No")
    myPopup.icon = warningIcon
    let res = myPopup.runModal()
    if res == NSAlertFirstButtonReturn {
        return false
    }
    return true
}

extension Bundle {
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var build: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var copyright: String? {
        return infoDictionary?["NSHumanReadableCopyright"] as? String
    }
}

extension NSColor {
	public convenience init?(rgbaHex: String) {
		let r, g, b, a: CGFloat
		
		if rgbaHex.hasPrefix("#") {
			var hexColor: String = rgbaHex.copy()
			
			hexColor.characters.removeFirst()
			
			if hexColor.characters.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
					a = CGFloat(hexNumber & 0x000000ff) / 255
					
					self.init(red: r, green: g, blue: b, alpha: a)
					return
				}
			}
		}
		
		return nil
	}
	
	public convenience init?(rgbHex: String) {
		let r, g, b: CGFloat
		
		if rgbHex.hasPrefix("#") {
			var hexColor: String = rgbHex.copy()
			
			hexColor.characters.removeFirst()
			
			if hexColor.characters.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
					
					self.init(red: r, green: g, blue: b, alpha: 1)
					return
				}
			}
		}
		
		return nil
	}
}
