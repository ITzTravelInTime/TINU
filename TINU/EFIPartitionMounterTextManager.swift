/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

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

public struct EFIPMTextManagerStruct: TextManagerGet, CodableDefaults, Codable, Equatable{
	let viewStrings: TextManagementStructs.ViewStringsAlbum<String>
	
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
