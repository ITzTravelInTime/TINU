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
	
	public func getViewString(context: ViewID, stringID: String) -> String!{
		return viewStrings[context.id]?.getString(stringID)
	}
	
	public static var defaultResourceFileExtension: String { return "json" }
	public static var defaultResourceFileName: String { return "EFIPMTextAssets" }
}

let EFIPMTextManager = CodableCreation<EFIPMTextManagerStruct>.createFromDefaultFile()!
