//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public struct TINUTextsManagerStruct: TextManagerGet, CodableDefaults, Codable, Equatable{
	
	private var readme: TextManagementStructs.InstallerInstallation<TextManagementStructs.MessangeFormatSpecificsMachine<String>>
	private var helpfoulMessange: TextManagementStructs.InstallerInstallation<String>
	private var optionsDescs: TextManagementStructs.InstallerInstallation<OtherOptionsManager.OtherOptionsStringList>
	
	private let viewStrings: TextManagementStructs.ViewStringsCollection
	
	private let remAsset = getLanguageFile(fileName: TINUTextsManagerStruct.defaultResourceFileName, fextension: TINUTextsManagerStruct.defaultResourceFileExtension)
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		
		let asset = remAsset ?? TINUTextsManagerStruct.defaultResourceFileName + "En" + TINUTextsManagerStruct.defaultResourceFileExtension
		
		guard let view = viewStrings[context.id] else{
			
			msgBox("View text not found \"\(context.id)\"", "The internal assets \"\(asset)\" file doesn't contain the text for the view \"\(context.id)\"", .critical)
			
			return nil
		}
		
		guard let ret = view.getString(stringID) else{
			
			msgBox("Entity text not found \"\(stringID)\"", "The assets file \"\(asset)\" doesn't contain the text for the View entity \"\(stringID)\"", .critical)
			
			return nil
		}
		
		return ret
	}
	
	public var optionsDescpriptions: OtherOptionsManager.OtherOptionsStringList! {
		return optionsDescs.appropriateValue
	}
	
	public var readmeText: String! {
		return readme.appropriateValue.appropriateValue
	}
	
	public var helpfoulMessage: String! {
		return helpfoulMessange.appropriateValue
	}
	
	public static var defaultResourceFileExtension: String { return "json" }
	public static var defaultResourceFileName: String { return "TextAssets" }
	
}

public let TextManager: TINUTextsManagerStruct! = CodableCreation<TINUTextsManagerStruct>.createFromDefaultFile()
