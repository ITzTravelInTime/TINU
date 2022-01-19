/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

public func getLanguageFile(fileName: String, fextension: String) -> String!{
	
	print("Getting asset file for current language")
	
	let referenceStart = (Bundle.main.resourceURL!.path + "/" + fileName)
	let referenceEnd = ("." + fextension)
	
	var language = NSLocale.current.languageCode!.lowercased()
	let f = String(language.uppercased().first!)
	language = f + language.dropFirst()
	
	print("Current language: \(language)")
	
	var langs = [language]
	
	langs.append("En")
	
	for p in langs{
		let fullPath = referenceStart + p + referenceEnd
		
		if FileManager.default.fileExists(atPath: fullPath){
			if p == langs.last!{
				print("Found default \(p) file, using that since the language-specific one is not present")
			}else{
				print("Found file for current language")
			}
			
			print("    Found file path: \(fullPath)")
			
			return fullPath
		}
		
	}
	
	print("Default file not found!")
	
	return nil

}
