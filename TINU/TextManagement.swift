//
//  TextManagement.swift
//  TINU
//
//  Created by Pietro Caruso on 04/10/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

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

public protocol TextManagerGet{
	func getViewString(context: ViewID, stringID: String) -> String!
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
