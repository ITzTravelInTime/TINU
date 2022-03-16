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

//this file just contains some usefoul extensions and methods for system classes

extension NSViewController{
	
	internal static var tmpViewController: [NSViewController?] = []
	
	public func swapCurrentViewController(_ storyboardID: String, storyboard customStoryboard: NSStoryboard! = nil){
		
		let cstoryboard: NSStoryboard = customStoryboard ?? storyboard!
		
		print("Swapping current View Controller with: \"\(storyboardID)\" from storyboard \"\(String(describing: cstoryboard))\"")
		
		let tempPos = self.view.window?.frame.origin
		
		NSViewController.tmpViewController.append(cstoryboard.instantiateController(withIdentifier: storyboardID) as? NSViewController)
		
		if !NSViewController.tmpViewController.isEmpty{
			if NSViewController.tmpViewController.last! == nil{
				// :-(
			
				let msg = "ViewController \"\(storyboardID)\" not found in the storyboard: \n    \(String(describing: cstoryboard))"
				print(msg)
				fatalError(msg)
			}
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
            canFullScreen = newValue
			isZoomButtonEnabled = newValue
        }
        get{
            return canFullScreen && isZoomButtonEnabled
        }
    }
	
	public var canFullScreen: Bool{
		set{
			if newValue{
				self.styleMask.insert(.resizable)
			}else{
				self.styleMask.remove(.resizable)
			}
		}
		get{
			return self.styleMask.contains(.resizable)
		}
	}
	
	public var isZoomButtonEnabled: Bool{
		set{
			self.standardWindowButton(.zoomButton)?.isEnabled = newValue
		}
		get{
			return self.standardWindowButton(.zoomButton)?.isEnabled ?? false
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

public extension String {
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

public extension String{
    @inline(__always) func copy()-> String{
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
	
	var isAlphanumeric: Bool{
		
		if self.isEmpty{
			return false
		}
		
		//let ref = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
		for i in self{
			if (!i.isLetter && !i.isNumber){
				return false
			}
			
			/*
			if !ref.contains(i){
				return false
			}
			*/
		}
		
		return true
	}
	
	func parsed(usingKeys keys: [String: String]) -> String{
		/*
		var ret = ""
		for piece in self.split(separator: "$"){
			var s = String(piece)
			
			for key in keys{
				if s.starts(with: key.key){
					s.deletePrefix(key.key)
					s = key.value + s
					break
				}
			}
			
			ret += s
		}*/
		
		var ret = self
		
		for i in keys{
			ret = ret.replacingOccurrences(of: "$" + i.key, with: i.value)
		}
		
		return ret
	}
	
	mutating func parse(usingKeys keys: [String: String]){
		self = self.parsed(usingKeys: keys)
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
	
	func resized(to newSize: NSSize) -> NSImage? {
			if let bitmapRep = NSBitmapImageRep(
				bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
				bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
				colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
			) {
				bitmapRep.size = newSize
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
				draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
				NSGraphicsContext.restoreGraphicsState()

				let resizedImage = NSImage(size: newSize)
				resizedImage.addRepresentation(bitmapRep)
				return resizedImage
			}

			return nil
		}
}

extension Date {

	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}

}

extension NSImageView {
	func downloaded(from url: URL, scaling: NSImageScaling = .scaleProportionallyUpOrDown) {
		
		if Recovery.status{
			return
		}
		
		if !Reachability.status{
			return
		}
		
		self.imageScaling = scaling
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = NSImage(data: data)
				else { return }
			DispatchQueue.main.async() { [weak self] in
				self?.image = image
			}
		}.resume()
	}
	
	func downloaded(from link: String, scaling: NSImageScaling = .scaleProportionallyUpOrDown) {
		guard let url = URL(string: link) else { return }
		downloaded(from: url, scaling: scaling)
	}
}

