//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation
import TINUNotifications

public struct ViewString: Codable, Equatable{
	public let strings: TextManagementStructs.ViewStrings<String>
	public let notifications: TextManagementStructs.ViewStrings<TINUNotifications.Notification>?
	public let alerts: TextManagementStructs.ViewStrings<TINUNotifications.Alert>?
}

public struct TINUTextsManagerStruct: TextManagerGet, CodableDefaults, Codable, Equatable{
	
	private var readme: TextManagementStructs.InstallerInstallation<TextManagementStructs.MessangeFormatSpecificsMachine<String>>
	private var helpfoulMessange: TextManagementStructs.InstallerInstallation<String>
	private var optionsDescs: TextManagementStructs.InstallerInstallation<CreationProcess.OptionsManager.DescriptionList>
	
	private let viewStrings: TextManagementStructs.ViewStringsAlbum<String>
	//private let views: TextManagementStructs.Album<ViewString>
	
	private var remAsset = getLanguageFile(fileName: TINUTextsManagerStruct.defaultResourceFileName, fextension: TINUTextsManagerStruct.defaultResourceFileExtension)
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		
		let asset = remAsset ?? TINUTextsManagerStruct.defaultResourceFileName + "En." + TINUTextsManagerStruct.defaultResourceFileExtension
		
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
	
	public var optionsDescpriptions: CreationProcess.OptionsManager.DescriptionList! {
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
