//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

fileprivate protocol AlternateValueSupport{
	associatedtype T: Codable & Equatable
	var appropriateValue: T { get }
}

public protocol ViewID{
	var id: String { get }
}

public struct TextsManagerStruct: Codable, Equatable{
	
	fileprivate struct InstallerInstallation<T: Codable & Equatable>: AlternateValueSupport & Codable & Equatable{
		let installation: T
		let installer: T
		
		var appropriateValue: T{
			return sharedInstallMac ? installation : installer
		}
	}
	
	fileprivate struct MessangeFormatSpecificsMachine<T: Codable & Equatable>: AlternateValueSupport & Codable, Equatable{
		let mac: T
		let hackintosh: T
		
		var appropriateValue: T{
			#if macOnlyMode
			
			return mac
			
			#else
			
			return hackintosh
			
			#endif
		}
	}
	
	fileprivate struct ViewStrings: Codable & Equatable{
		let mutable: [String: InstallerInstallation<String>]
		let unmutable: [String: String]
		
		func getString(_ id: String) -> String!{
			if let s = mutable[id]{
				return s.appropriateValue
			}
			
			return unmutable[id]
		}
	}
	
	fileprivate typealias ViewStringsCollection = [String: ViewStrings]
	
	fileprivate var readme: InstallerInstallation<MessangeFormatSpecificsMachine<String>>
	fileprivate var helpfoulMessange: InstallerInstallation<String>
	fileprivate var optionsDescs: InstallerInstallation<OtherOptionsManager.OtherOptionsStringList>
	fileprivate var viewStrings: ViewStringsCollection
	
	public var optionsDescpriptions: OtherOptionsManager.OtherOptionsStringList! {
		return optionsDescs.appropriateValue
	}
	
	public var readmeText: String! {
		return readme.appropriateValue.appropriateValue
	}
	
	public var helpfoulMessage: String! {
		return helpfoulMessange.appropriateValue
	}
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		return viewStrings[context.id]?.getString(stringID)
	}
	
	// TextManagerAssets
	
	//assumes the urls refers to a .json file
	
	static func createFrom(fileURL: URL) -> TextsManagerStruct!{
		do{
			if FileManager.default.fileExists(atPath: fileURL.path){
				if fileURL.pathExtension == defaultResourceFileExtension{
					let data = try String.init(contentsOf: fileURL).data(using: .utf8)!
					let new = try JSONDecoder().decode(TextsManagerStruct.self, from: data)
					
					print(new)
					
					return new
				}
			}
			
		}catch let err{
			print(err)
		}
		
		return nil
	}
	
	//assumes the file string is a file path for a .json file
	static func createFrom(file: String) -> TextsManagerStruct!{
		return createFrom(fileURL: URL(fileURLWithPath: file, isDirectory: false))
	}
	
	internal static let defaultResourceFileName = "TextAssets"
	internal static let defaultResourceFileExtension = "json"
	
	internal static var defaultFilePath: String {
		return getLanguageFile(fileName: TextsManagerStruct.defaultResourceFileName, fextension: TextsManagerStruct.defaultResourceFileExtension)
	}
	
	internal static var defaultFileURL: URL { return URL(fileURLWithPath: defaultFilePath, isDirectory: false)}
	
	static func createFromDefaultFile() -> TextsManagerStruct!{
		return createFrom(fileURL: defaultFileURL)
	}

	func getEncoded() -> String!{
		do{
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			let data = (try encoder.encode(self))
			return String(data: data, encoding: .utf8)
		}catch let err{
			print(err)
		}
		
		return nil
	}
	
}

public let TextManager: TextsManagerStruct! = TextsManagerStruct.createFromDefaultFile()

//dummy test initialization just to have a test print of how the .json file should look like, this struct is not made for this kind of initialization it's just made for the usage of the .json file with a few lines of code
//public let TextManager: TextsManagerStruct! = TextsManagerStruct(readme: TextsManagerStruct.InstallerInstallation<TextsManagerStruct.MessangeFormatSpecificsMachine>.init(installation: TextsManagerStruct.MessangeFormatSpecificsMachine.init(mac: "a1", hackintosh: "a2"), installer: TextsManagerStruct.MessangeFormatSpecificsMachine.init(mac: "a3", hackintosh: "a4")), helpfoulMessange: TextsManagerStruct.InstallerInstallation<String>.init(installation: "b1", installer: "b2"), optionsDescs: TextsManagerStruct.InstallerInstallation<[OtherOptionsManager.OtherOptionID: OtherOptionsManager.OtherOptionString]>.init(installation: [OtherOptionsManager.OtherOptionID.otherOptionTinuCopyID: OtherOptionsManager.OtherOptionString.init(title: "c1", desc: "c2"), OtherOptionsManager.OtherOptionID.otherOptionCreateIconID: OtherOptionsManager.OtherOptionString.init(title: "c3", desc: "c4")], installer: [OtherOptionsManager.OtherOptionID.otherOptionTinuCopyID: OtherOptionsManager.OtherOptionString.init(title: "d1", desc: "d2"), OtherOptionsManager.OtherOptionID.otherOptionCreateIconID: OtherOptionsManager.OtherOptionString.init(title: "d3", desc: "d4")]), viewStrings: ["DriveDetectionInfo": TextsManagerStruct.ViewStrings.init(mutable: ["content": TextsManagerStruct.InstallerInstallation<String>.init(installation: "e1", installer: "e2")], unmutable: ["content": "e3"]) ])

//TextsManagerStruct.createFromDefaultFile()

