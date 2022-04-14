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

public struct SFSymbol: Hashable, Codable, Copying, Equatable{
	
	private let name: String
	public var description: String? = nil
	
	@available(macOS 11.0, *) public static var defaultWeight: NSFont.Weight = .light
	
	public init(name: String, description: String? = nil){
		self.name = name
		self.description = description
	}
	
	public init(symbol: SFSymbol){
		self.name = symbol.name
		self.description = symbol.description
	}
	
	public func copy() -> SFSymbol {
		return SFSymbol(symbol: self)
	}
	
	public func adding(attribute: String) -> SFSymbol?{
		
		if #available(macOS 11.0, *){
		
		if name.contains(".\(attribute)"){
			return copy()
		}
		
			let segmented = self.name.split(separator: ".")
			
			for i in (0...segmented.count).reversed(){
				var str = ""
				
				for k in 0..<i{
					str += ".\(segmented[k])"
				}
				
				if !str.isEmpty{
					str.removeFirst()
				}
				
				str += ".\(attribute)"
				
				if i <= segmented.count{
					for k in i..<segmented.count{
						str += ".\(segmented[k])"
					}
				}
				
				//Really unefficient way of checking if a symbol exists
				if NSImage(systemSymbolName: str, accessibilityDescription: nil) != nil{
					return SFSymbol(name: str, description: description)
				}
			}
			
		}
		
		return nil
	}
	
	public func fill() -> SFSymbol?{
		return adding(attribute: "fill")
	}
	
	public func circular() -> SFSymbol?{
		return adding(attribute: "circle")
	}
	
	public func triangular() -> SFSymbol?{
		return adding(attribute: "triangle")
	}
	
	public func octagonal() -> SFSymbol?{
		return adding(attribute: "octagon")
	}
	
	public func duplicated() -> SFSymbol?{
		return adding(attribute: "2")
	}
	
	public func image(accessibilityDescription: String? = nil) -> NSImage?{
		if #available(macOS 11.0, *) {
			return NSImage(systemSymbolName: self.name, accessibilityDescription: accessibilityDescription)?.withSymbolWeight(Self.defaultWeight)
		} else {
			return nil
		}
	}
	
	public func imageWithSystemDefaultWeight(accessibilityDescription: String? = nil) -> NSImage?{
		if #available(macOS 11.0, *) {
			return NSImage(systemSymbolName: self.name, accessibilityDescription: accessibilityDescription)
		} else {
			return nil
		}
	}
	
}

public struct Icon: Hashable, Codable, Equatable{
	public init(path: String? = nil, symbol: SFSymbol? = nil, imageName: String? = nil, alternativeImage: Data? = nil) {
		assert(imageName != nil || path != nil || alternativeImage != nil || symbol != nil, "This is not a valid configuration for an icon")
		self.path = path
		self.symbol = symbol
		self.imageName = imageName
		self.alternativeImage = alternativeImage
	}
	
	public init(path: String?, symbol: SFSymbol?, imageName: String?, alternative: NSImage?) {
		assert(imageName != nil || path != nil || alternative != nil || symbol != nil, "This is not a valid configuration for an icon")
		self.path = path
		self.symbol = symbol
		self.imageName = imageName
		self.alternativeImage = alternative?.tiffRepresentation
	}
	
	public init(symbol: SFSymbol) {
		self.symbol = symbol
	}
	
	public init(symbolName: String) {
		self.symbol = SFSymbol(name: symbolName)
	}
	
	public init(imageName: String) {
		self.imageName = imageName
	}
	
	public init(alternativeImage: Data?) {
		self.alternativeImage = alternativeImage
	}
	
	private var path: String? = nil
	private var symbol: SFSymbol? = nil
	private var imageName: String? = nil
	private var alternativeImage: Data? = nil
	
	private var alternative: NSImage?{
		get{
			guard let alt = alternativeImage else { return nil }
			return NSImage(data: alt)
		}
		set{
			alternativeImage = newValue?.tiffRepresentation
		}
	}
	
	public var sfSymbol: SFSymbol?{
		return symbol
	}
	
	public func normalImage() -> NSImage?{
		assert(imageName != nil || path != nil || alternativeImage != nil)
		
		var image: NSImage?
		
		if imageName != nil{
			assert(imageName != "", "The image name must be a valid image name")
			image = NSImage(named: imageName!)
		}
		
		if image == nil && path != nil{
			assert(path != "", "The path must be a valid path")
			//Commented this to allow for testing if an image exists and then if not use the alternate image
			//assert(FileManager.default.fileExists(atPath: path!), "The specified path must be the one of a file that exists")
			image = NSImage(contentsOfFile: path!)
		}
		
		if image == nil && alternativeImage != nil{
			image = alternative
		}
		
		return image
	}
	
	public func sFSymbolImage() -> NSImage?{
		return symbol?.image()
	}
	
	public func themedImage() -> NSImage?{
		if #available(macOS 11.0, *),symbol != nil && look.usesSFSymbols(){
			if look.usesFilledSFSymbols(){
				return symbol?.fill()?.image() ?? normalImage()
			}
			return sFSymbolImage() ?? normalImage()
		}
		return normalImage()
	}
}

public final class IconsManager{
	
	public static let shared = IconsManager()
	
	//warning icon used by the app
	public var warningIcon: Icon{
		//return getIconFor(path: "", symbol: "exclamationmark.triangle", name: NSImage.cautionName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "exclamationmark.triangle"), imageName: NSImage.cautionName)
		}
		
		return Mem.icon!
	}
	
	public var roundWarningIcon: Icon{
		//return getIconFor(path: "", symbol: "exclamationmark.circle", name: NSImage.cautionName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "exclamationmark").circular(), imageName: NSImage.cautionName)
		}
		
		return Mem.icon!
	}
	
	//stop icon used by the app
	public var stopIcon: Icon{
		//return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: "xmark.octagon", name: "uncheck")
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: SFSymbol(name: "xmark").octagonal(), imageName: "uncheck")
		}
		
		return Mem.icon!
	}
	
	public var roundStopIcon: Icon{
		//return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: "xmark.circle", name: "uncheck")
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: SFSymbol(name: "xmark").circular(), imageName: "uncheck")
		}
		
		return Mem.icon!
	}
	
	public var checkIcon: Icon{
		//return getIconFor(path: "", symbol: "checkmark.circle", name: "checkVector")
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "checkmark").circular(), imageName: "checkVector")
		}
		
		return Mem.icon!
	}
	
	public var copyIcon: Icon{
		//return getIconFor(path: "", symbol: "doc.on.doc", name: NSImage.multipleDocumentsName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "doc.on.doc"), imageName: NSImage.multipleDocumentsName)
		}
		
		return Mem.icon!
	}
	
	public var saveIcon: Icon{
		//return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns", symbol: "tray.and.arrow.down", name: NSImage.multipleDocumentsName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns", symbol: SFSymbol(name: "tray.and.arrow.down"), imageName: NSImage.multipleDocumentsName)
		}
		
		return Mem.icon!
	}
	
	public var removableDiskIcon: Icon{
		//return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Removable.icns", symbol: "externaldrive", name: "Removable")
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Removable.icns", symbol: SFSymbol(name: "externaldrive"), imageName: "Removable")
		}
		
		return Mem.icon!
	}
	
	public var externalDiskIcon: Icon{
		//return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/External.icns", symbol: "externaldrive", alternate: removableDiskIcon)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/External.icns", symbol: SFSymbol(name: "externaldrive"), imageName: nil, alternative: removableDiskIcon.normalImage())
		}
		
		return Mem.icon!
	}
	
	public var internalDiskIcon: Icon{
		//return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Internal.icns", symbol: "internaldrive", alternate: removableDiskIcon)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Internal.icns", symbol: SFSymbol(name: "internaldrive"), imageName: "internaldrive", alternative: removableDiskIcon.normalImage())
		}
		
		return Mem.icon!
	}
	
	public var timeMachineDiskIcon: Icon{
		//return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericTimeMachineDiskIcon.icns", symbol: "externaldrive.badge.timemachine", alternate: removableDiskIcon)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericTimeMachineDiskIcon.icns", symbol: SFSymbol(name: "externaldrive.badge.timemachine"), imageName: nil, alternative: removableDiskIcon.normalImage())
		}
		
		return Mem.icon!
	}
	
	public var genericInstallerAppIcon: Icon{
		//return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns", symbol: "square.and.arrow.down", name: "InstallApp", alternateFirst: true)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns", symbol: SFSymbol(name: "square.and.arrow.down"), imageName: "InstallApp")
		}
		
		return Mem.icon!
	}
	
	public var optionsIcon: Icon{
		//return getIconFor(path: "", symbol: "gearshape", name: NSImage.preferencesGeneralName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "gearshape"), imageName: NSImage.preferencesGeneralName)
		}
		
		return Mem.icon!
	}
	
	public var advancedOptionsIcon: Icon{
		//return getIconFor(path: "", symbol: "gearshape.2", name: NSImage.advancedName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "gearshape").duplicated(), imageName: NSImage.advancedName)
		}
		
		return Mem.icon!
	}
	
	public var folderIcon: Icon{
		//return getIconFor(path: "", symbol: "folder", name: NSImage.folderName)
		
		struct Mem{
			static var icon: Icon? = nil
		}
		
		if Mem.icon == nil{
			Mem.icon = Icon(path: nil, symbol: SFSymbol(name: "folder"), imageName: NSImage.folderName)
		}
		
		return Mem.icon!
	}
	
	//return the icon of thespecified installer app
	
	func getInstallerAppIconFrom(path app: String) ->NSImage{
		let iconp = app + "/Contents/Resources/InstallAssistant.icns"
		if FileManager.default.fileExists(atPath: iconp){
			if let i = NSImage(contentsOfFile: iconp){
				return i
			}
		}
		
		return NSWorkspace.shared.icon(forFile: app)
	}
	
	/*
	//gets an icon from a file, if the file do not exists, it uses an icon from the assets
	public func getIconFor(path: String, symbol: String, name: String, alternateFirst: Bool = false) -> NSImage!{
		return getIconFor(path: path, symbol: symbol, alternate: NSImage(named: name), alternateFirst: alternateFirst)
	}
	
	//TODO: caching for icons from the file system
	public func getIconFor(path: String, symbol: String, alternate: NSImage! = nil, alternateFirst: Bool = false) -> NSImage!{
		if #available(macOS 11.0, *), look.usesSFSymbols() && !symbol.isEmpty{
			
			var ret = NSImage(systemSymbolName: symbol + (look.usesFilledSFSymbols() && !symbol.contains(".fill") ? ".fill" : ""), accessibilityDescription: nil)
			
			if ret == nil{
				ret = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
			}
			
			ret?.isTemplate = true
			return ret
		}
		if path.isEmpty{
			return alternate
		}
		if FileManager.default.fileExists(atPath: path) && !(alternate != nil && alternateFirst){
			return NSImage(contentsOfFile: path)
		}else{
			return alternate
		}
	}
	*/
	
	
	public func getCorrectDiskIcon(_ id: BSDID) -> NSImage{
		if id.isVolume{
			if let mount = id.mountPoint(){
				if !(mount.isEmpty){
					if FileManager.default.directoryExistsAtPath(mount + "/Backups.backupdb"){
						return timeMachineDiskIcon.themedImage()!
					}else{
						if FileManager.default.fileExists(atPath: mount + "/.VolumeIcon.icns"){
							return NSWorkspace.shared.icon(forFile: mount)
						}
					}
				}
			}
		}
		
		var image = IconsManager.shared.removableDiskIcon
		
		if let i = id.isRemovable(){
			if !i{
				image = IconsManager.shared.internalDiskIcon
			}else if let i = id.isExternalHardDrive(){
				if !i{
					image = IconsManager.shared.externalDiskIcon
				}
			}
		}
		
		return image.themedImage()!
	}
	
}

