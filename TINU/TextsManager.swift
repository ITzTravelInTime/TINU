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
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		return viewStrings[context.id]?.getString(stringID)
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
