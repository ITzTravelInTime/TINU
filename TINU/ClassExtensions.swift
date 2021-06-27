//
//  SharedInstances.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this file just contains some usefoul extensions and methods for system classes

extension NSViewController{
	
	internal static var tmpViewController: [NSViewController?] = []
	
	public func swapCurrentViewController(_ storyboardID: String, storyboard customStoryboard: NSStoryboard! = nil){
		
		let cstoryboard: NSStoryboard = customStoryboard ?? storyboard!
		
		print("Swapping current View Controller with: \"\(storyboardID)\" from storyboard \"\(String(describing: cstoryboard))\"")
		
		let tempPos = self.view.window?.frame.origin
		
		NSViewController.tmpViewController.append(cstoryboard.instantiateController(withIdentifier: storyboardID) as? NSViewController)
		
		if NSViewController.tmpViewController.last! == nil{
			// :-(
			
			let msg = "ViewController \"\(storyboardID)\" not found in the storyboard: \n    \(String(describing: cstoryboard))"
			print(msg)
			fatalError(msg)
		}
		
		if self.view.window == nil{
			// :-(
			//fatalError("Target window is nil")
			print("    Don't have any window to reference unfortunately")
			NSViewController.tmpViewController[NSViewController.tmpViewController.count - 1] = nil
			return
		}
		
		print("    Performing View Controller sawp...")
		
		self.view.window?.contentViewController = NSViewController.tmpViewController.last!!
		self.view.window?.contentView = NSViewController.tmpViewController.last!!.view
		
		if tempPos != nil{
			self.view.window?.setFrameOrigin(tempPos!)
		}
		
		self.removeFromParent()
		//self.dismiss(self)
		
		print("    View controller swapped successfully")
		
		print("    View controller memory system: Memory clean attempt")
		
		if !NSViewController.tmpViewController.contains(self){
			print("        Memory clean is unnecessary")
			return
		}
		
		for i in 0..<NSViewController.tmpViewController.count{
			if NSViewController.tmpViewController[i] != self{
				continue
			}
				
			NSViewController.tmpViewController[i] = nil
			NSViewController.tmpViewController.remove(at: i) //we need this too since the array is made of optional values
			print("        Memory cleaned: \(NSViewController.tmpViewController.count) items in controls memory")
			return
		}
		
		print("        Memory empty or already cleaned")
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

extension NSTextView{
    public var text: String{
        set{
            self.string = newValue
        }
        get{
            return self.string
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
        return String(self)
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
	
	var isInt: Bool {
		if isEmpty { return false }
		return Int(self) != nil
	}
	
	var intValue: Int! {
		return Int(self)
	}
	
	var isUInt: Bool {
		if isEmpty { return false }
		return UInt(self) != nil
	}
	
	var uIntValue: UInt! {
		return UInt(self)
	}
	
	var isUInt64: Bool{
		if isEmpty { return false }
		return UInt64(self) != nil
	}
	
	var uInt64Value: UInt64! {
		return UInt64(self)
	}
	
	func contains(_ str: String) -> Bool{
		return self.range(of: str) != nil
	}
	
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

/*
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
*/

extension NSColor{
	static let transparent = NSColor.white.withAlphaComponent(0)
}

extension FileManager {
	
	func fileSize(of: URL) -> Int?{
		do {
			let val = try of.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
			return val.totalFileAllocatedSize ?? val.fileAllocatedSize
		} catch {
			print(error)
			return nil
		}
	}
		
	func directorySize(_ dir: URL) -> Int? { // in bytes
		if let enumerator = self.enumerator(at: dir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey], options: [], errorHandler: { (_, error) -> Bool in
			print(error)
			return false
		}) {
			var bytes = 0
			for case let url_ as URL in enumerator {
				//bytes += url_.fileSize ?? 0
				bytes += fileSize(of: url_) ?? 0
			}
			return bytes
		} else {
			return nil
		}
	}
	
	func directoryExistsAtPath(_ path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = self.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
	}
}

fileprivate extension URL {
	var fileSize: Int? { // in bytes
		return FileManager.default.fileSize(of: self)
	}
}

extension NSImage{
	func withSymbolWeight( _ weight: NSFont.Weight ) -> NSImage?{
		if #available(macOS 11.0, *) {
			return self.withSymbolConfiguration(.init(pointSize: 20, weight: weight))
		} else {
			return self
		}
	}
}

