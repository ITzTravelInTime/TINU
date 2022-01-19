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
	var viewStrings: TextManagementStructs.ViewStringsAlbum<String> {get}
	static var remAsset: String? {get}
}

public extension TextManagerProtocol{
	func getViewString(context: ViewID, stringID: String) -> String!{
		
		let asset = Self.remAsset ?? Self.defaultResourceFileName + "En." + Self.defaultResourceFileExtension
		
		guard let view = viewStrings[context.id] else{
			
			print("The assets file \"\(asset)\" file doesn't contain the text for the view \"\(context.id)\"")
			
			return nil
		}
		
		guard let ret = view.getString(stringID) else{
			
			print("The assets file \"\(asset)\" doesn't contain the text for the View entity \"\(stringID)\"")
			
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
	
	public struct ViewStrings<T: Codable & Equatable>: Codable & Equatable{
		let mutable: [String: InstallerInstallation<T>]!
		let unmutable: [String: T]
		
		func getString(_ id: String) -> T!{
			if let s = mutable?[id]{
				return s.appropriateValue
			}
			
			return unmutable[id]
		}
	}
	
	public typealias Album<T: Codable & Equatable> = [String: T]
	public typealias ViewStringsAlbum<T: Codable & Equatable> = Album<ViewStrings<T>>
	
}
