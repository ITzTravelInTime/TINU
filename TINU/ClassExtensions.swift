//
//  SharedInstances.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import AppKit

//this file just contains some usefoul extensions and methods for system classes

extension NSViewController{
    public func sawpCurrentViewController(with storyboardID: String, sender: Any){
        
        let tempPos = self.view.window?.frame.origin
        
        let viewController: NSViewController? = storyboard?.instantiateController(withIdentifier: storyboardID) as? NSViewController
        
        if viewController != nil{
            //presentViewControllerAsModalWindow(viewController!)
            
            //self.dismiss(sender)
            //self.view.window?.windowController?.close()
			
            if self.view.window != nil{
                self.view.window?.contentViewController = viewController
                
                self.view.window?.contentView = viewController?.view
				
				/*
                #if !isTool
                if !sharedIsOnRecovery{
                    if let w = viewController?.window.windowController as? GenericWindowController{
                        w.checkVibrant()
                    }
                }
                #endif
				*/
				
                if tempPos != nil{
                    self.view.window?.setFrameOrigin(tempPos!)
                }
                
				//self.view.exitFullScreenMode(options: [:])
                
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
        if !self.styleMask.contains(.fullScreen){
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

extension FileManager{
	func directoryExistsAtPath(_ path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = self.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
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

//english grammar
extension Character{
	func isVowel() -> Bool{
		return "aeiou".contains("\(self)".lowercased())
	}
}

extension String {
	subscript (bounds: CountableClosedRange<Int>) -> String {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return String(self[start...end])
	}
	
	subscript (bounds: CountableRange<Int>) -> String {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return String(self[start..<end])
	}
}

extension String{
    @inline(__always) public func copy()-> String{
        return String("\(self)")
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
	
	@inline(__always) mutating func deletePrefix(_ prefix: String){
		 self = self.deletingPrefix(prefix)
	}
	
	@inline(__always) mutating func deleteSuffix(_ suffix: String){
		self = self.deletingSuffix(suffix)
	}
	
	var isNumber: Bool {
		return !isEmpty && Int(self) != nil
	}
	
	var number: Int! {
		return Int(self)
	}
	
	var isUnsignedNumber: Bool {
		return !isEmpty && UInt(self) != nil
	}
	
	var unsignedNumber: UInt! {
		return UInt(self)
	}
	
	func contains(_ str: String) -> Bool{
		return self.range(of: str) != nil
	}
}

@IBDesignable
class HyperTextField: NSTextField {
    @IBInspectable var href: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName: NSColor.linkColor
            ,NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject, NSCursorAttributeName: NSCursor.pointingHand()
        ]
        self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        NSWorkspace.shared().open(URL(string: self.href)!)
    }
}

@IBDesignable
public class HyperMenuItem: NSMenuItem {
	@IBInspectable var href: String = ""
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		action = #selector(HyperMenuItem.click(_:))
		target = self
	}
	
	@objc func click(_ sender: Any){
		NSWorkspace.shared().open(URL(string: self.href)!)
	}
	
	//func mouseDown(with event: NSEvent) {
		//NSWorkspace.shared().open(URL(string: self.href)!)
	//}
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
	var name: String? {
		return infoDictionary?["CFBundleName"] as? String
	}
}

extension NSColor {
	public convenience init?(rgbaHex: String) {
		let r, g, b, a: CGFloat
		
		if rgbaHex.hasPrefix("#") {
			var hexColor: String = rgbaHex.copy()
			
			hexColor.removeFirst()
			
			if hexColor.count == 8 {
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
			
			hexColor.removeFirst()
			
			if hexColor.count == 8 {
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
