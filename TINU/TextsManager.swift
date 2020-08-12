//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public let TextManager = TextsManagerStruct.createFromDefaultFile()

public struct TextsManagerStruct: Codable, Equatable{
	
	
	private struct MessangeFormat: Codable, Equatable{
		let installation: String
		let installer: String
	}
	
	private struct MessangeFormatSpecific: Codable, Equatable{
		let installation: MessangeFormatSpecifics
		let installer: MessangeFormatSpecifics
	}
	
	private struct MessangeFormatSpecifics: Codable, Equatable{
		let mac: String
		let hackintosh: String
	}
	
	private var readme: MessangeFormatSpecific
	private var helpfoulMessange: MessangeFormat
	
	public var readmeText: String! {
		#if macOnlyMode
		
		if sharedInstallMac{
			return readme.installation.mac
		}else{
			return readme.installer.mac
		}
		
		#else
		
		if sharedInstallMac{
			return readme.installation.hackintosh
		}else{
			return readme.installer.hackintosh
		}
		
		#endif
	}
	
	public var helpfoulMessage: String! {
		if sharedInstallMac{
			return helpfoulMessange.installation
		}else{
			return helpfoulMessange.installer
		}
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
	
	internal static let defaultResourceFileName = "TextManagerAssets"
	internal static let defaultResourceFileExtension = "json"
	internal static var defaultFilePath: String { return (Bundle.main.resourceURL!.path + "/" + TextsManagerStruct.defaultResourceFileName + "." + TextsManagerStruct.defaultResourceFileExtension)}
	internal static var defaultFileURL: URL { return URL(fileURLWithPath: defaultFilePath, isDirectory: false)}
	
	static func createFromDefaultFile() -> TextsManagerStruct!{
		return createFrom(fileURL: defaultFileURL)
	}
	
}
