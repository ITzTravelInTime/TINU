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

public protocol ViewID{
	//static var manager: TextManagerGet { get }
	var id: String { get }
}

/*
public extension ViewID{
	func getAssest(stringNamed id: String) -> String?{
		return Self.manager.getViewString(context: self, stringID: id)
	}
}*/

public protocol AlternateValueSupport{
	associatedtype T: Codable & Equatable
	var appropriateValue: T { get }
}

public protocol TextManagerProtocol: CodableDefaults{
	var viewStrings: TextManagementStructs.ViewStringsAlbum {get}
	static var remAsset: String? {get}
}

public extension TextManagerProtocol{
	func getViewString(context: ViewID, stringID id: String) -> String!{
		
		guard let view = viewStrings[context.id] else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" file doesn't contain the assets for the view \"\(context.id)\"")
			
			return nil
		}
		
		guard let ret = view.getString(id) else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" doesn't contain the string entry \"\(id)\" for the View entity \"\(context.id)\"")
			
			return nil
		}
		
		return ret
	}
	
	internal func getAlert(context: ViewID, id: String) -> Alert!{
		
		guard let view = viewStrings[context.id] else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" file doesn't contain the assets for the view \"\(context.id)\"")
			
			return nil
		}
		
		guard let ret = view.getAlert(id) else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" doesn't contain the alert entry \"\(id)\" for the View entity \"\(context.id)\"")
			
			return nil
		}
		
		return ret
	}
	
	internal func getNotification(context: ViewID, id: String) -> UINotification!{
		
		guard let view = viewStrings[context.id] else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" file doesn't contain the assets for the view \"\(context.id)\"")
			
			return nil
		}
		
		guard let ret = view.getNotification(id) else{
			
			let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
			
			print("The assets file \"\(asset)\" doesn't contain the notification entry \"\(id)\" for the View entity \"\(context.id)\"")
			
			return nil
		}
		
		return ret
	}
	
}

public final class TextManagementStructs{
	
	public struct InstallerInstallation<T: Codable & Equatable>: AlternateValueSupport & Codable & Equatable{
		let installation: T
		let installer: T
		
		public var appropriateValue: T{
			return cvm.shared.installMac ? installation : installer
		}
	}
	
	public struct MessangeFormatSpecificsMachine<T: Codable & Equatable>: AlternateValueSupport & Codable, Equatable{
		let mac: T
		let hackintosh: T
		
		public var appropriateValue: T{
			#if macOnlyMode
			
			return mac
			
			#else
			
			return hackintosh
			
			#endif
		}
	}
	
	public struct ViewStrings: Codable & Equatable{
		private let mutable: [String: InstallerInstallation<String>]!
		private let unmutable: [String: String]
		private let notifications: [String: UINotification]!
		private let mutableAlerts: [String: InstallerInstallation<Alert>]!
		private let alerts: [String: Alert ]!
		
		func getString(_ id: String) -> String!{
			if let s = mutable?[id]{
				return s.appropriateValue
			}
			
			return unmutable[id]
		}
		
		func getAlert(_ id: String) -> Alert!{
			if let s = mutableAlerts?[id]{
				return s.appropriateValue
			}
			
			return alerts?[id]
		}
		
		func getNotification(_ id: String) -> UINotification!{
			return self.notifications?[id]
		}
	}
	
	public typealias ViewStringsAlbum = [String: ViewStrings]
	
}
