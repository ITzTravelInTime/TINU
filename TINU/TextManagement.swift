//
//  TextManagement.swift
//  TINU
//
//  Created by Pietro Caruso on 04/10/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

public protocol ViewID{
	var id: String { get }
}

public protocol AlternateValueSupport{
	associatedtype T: Codable & Equatable
	var appropriateValue: T { get }
}

public protocol TextManagerGet{
	//var viewStrings: TextManagementStructs.ViewStringsCollection { get }
	func getViewString(context: ViewID, stringID: String) -> String!
}

public final class TextManagementStructs{
	
	public struct InstallerInstallation<T: Codable & Equatable>: AlternateValueSupport & Codable & Equatable{
		let installation: T
		let installer: T
		
		public var appropriateValue: T{
			return sharedInstallMac ? installation : installer
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
		let mutable: [String: InstallerInstallation<String>]!
		let unmutable: [String: String]
		
		func getString(_ id: String) -> String!{
			if let s = mutable?[id]{
				return s.appropriateValue
			}
			
			return unmutable[id]
		}
	}
	
	public typealias ViewStringsCollection = [String: ViewStrings]
}
