//
//  EFIPartitionMounterTextManager.swift
//  TINU
//
//  Created by Pietro Caruso on 04/10/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

public struct EFIPMTextManagerStruct: TextManagerGet, CodableDefaults, Codable, Equatable{
	let viewStrings: TextManagementStructs.ViewStringsCollection
	
	private var remAsset = getLanguageFile(fileName: EFIPMTextManagerStruct.defaultResourceFileName, fextension: EFIPMTextManagerStruct.defaultResourceFileExtension)
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		
		let asset = remAsset ?? EFIPMTextManagerStruct.defaultResourceFileName + "En." + EFIPMTextManagerStruct.defaultResourceFileExtension
		
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
	
	public static var defaultResourceFileExtension: String { return "json" }
	public static var defaultResourceFileName: String { return "EFIPMTextAssets" }
}

let EFIPMTextManager = CodableCreation<EFIPMTextManagerStruct>.createFromDefaultFile()!
