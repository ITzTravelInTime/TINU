//
//  IconsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public final class IconsManager{
	
	public static let shared = IconsManager()
	
	//warning icon used by the app
	public var warningIcon: NSImage!{
		get{
			return getIconFor(path: "", symbol: "exclamationmark.triangle", name: NSImage.cautionName)
		}
	}
	
	public var alertWarningIcon: NSImage!{
		get{
			return NSImage(named: NSImage.cautionName)
		}
	}
	
	//stop icon used by the app
	public var stopIcon: NSImage!{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: "xmark.octagon", name: "uncheck")
		}
	}
	
	public var roundStopIcon: NSImage!{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns", symbol: "xmark.circle", name: "uncheck")
		}
	}
	
	public var checkIcon: NSImage!{
		get{
			return getIconFor(path: "", symbol: "checkmark.circle", name: "checkVector")
		}
	}
	
	//gets the overlay for usupported stuff
	public var unsupportedOverlay: NSImage!{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Unsupported.icns", symbol: "nosign", name: NSImage.cautionName)
		}
	}
	
	public var infoIcon: NSImage!{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns", symbol: "info.circle", name: NSImage.cautionName)
		}
	}
	
	public var copyIcon: NSImage!{
		get{
			return getIconFor(path: "", symbol: "doc.on.doc", name: NSImage.multipleDocumentsName)
		}
	}
	
	public var saveIcon: NSImage!{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns", symbol: "tray.and.arrow.down", name: NSImage.multipleDocumentsName)
		}
	}
	
	public var removableDiskIcon: NSImage{
		get{
			return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Removable.icns", symbol: "externaldrive", name: "Removable")
		}
	}
	
	public var externalDiskIcon: NSImage{
		get{
			return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/External.icns", symbol: "externaldrive", alternate: removableDiskIcon)
		}
	}
	
	public var internalDiskIcon: NSImage{
		get{
			return getIconFor(path: "/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Internal.icns", symbol: "internaldrive", alternate: removableDiskIcon)
		}
	}
	
	public var timeMachineDiskIcon: NSImage{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericTimeMachineDiskIcon.icns", symbol: "externaldrive.badge.timemachine", alternate: removableDiskIcon)
		}
	}
	
	
	public var genericInstallerAppIcon: NSImage{
		get{
			return getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns", symbol: "square.and.arrow.down", name: "InstallApp", alternateFirst: true)
		}
	}
	
	public var optionsIcon: NSImage{
		get{
			return getIconFor(path: "", symbol: "gearshape", name: NSImage.preferencesGeneralName)
		}
	}
	
	public var advancedOptionsIcon: NSImage{
		get{
			return getIconFor(path: "", symbol: "gearshape.2", name: NSImage.advancedName)
		}
	}
	
	public var folderIcon: NSImage{
		get{
			return getIconFor(path: "", symbol: "folder.fill", name: NSImage.folderName)
		}
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
	
	//gets an icon from a file, if the file do not exists, it uses an icon from the assets
	public func getIconFor(path: String, symbol: String, name: String, alternateFirst: Bool = false) -> NSImage!{
		return getIconFor(path: path, symbol: symbol, alternate: NSImage(named: name), alternateFirst: alternateFirst)
	}
	
	public func getIconFor(path: String, symbol: String, alternate: NSImage! = nil, alternateFirst: Bool = false) -> NSImage!{
		if #available(macOS 11.0, *), look.usesSFSymbols() && !symbol.isEmpty{
			let ret = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
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
	
	public func getCorrectDiskIcon(_ id: String) -> NSImage{
		
		if let mount = dm.getMountPointFromPartitionBSDID(id){
			if !(mount.isEmpty){
				if !FileManager.default.directoryExistsAtPath(mount + "/Backups.backupdb"){
					if FileManager.default.fileExists(atPath: mount + "/.VolumeIcon.icns"){
						return NSWorkspace.shared.icon(forFile: mount)
					}
				}else{
					return timeMachineDiskIcon
				}
			}
		}
		
		var image = IconsManager.shared.removableDiskIcon
		
		if let i = dm.getDriveIsRemovable(id){
			if !i{
				image = IconsManager.shared.internalDiskIcon
			}
		}
		
		return image
	}
	
}

