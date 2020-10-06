//
//  LanguageSelection.swift
//  TINU
//
//  Created by Pietro Caruso on 19/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

public func getLanguageFile(fileName: String, fextension: String) -> String{
	let referenceStart = (Bundle.main.resourceURL!.path + "/" + fileName)
	let referenceEnd = ("." + fextension)
	
	var language = NSLocale.current.languageCode!.lowercased()
	let f = String(language.uppercased().first!)
	language = f + language.dropFirst()
	
	print("Current language: \(language)")
	
	let filePath = referenceStart + language + referenceEnd
	
	if FileManager.default.fileExists(atPath: filePath){
		print("Found file for current language")
		return filePath
	}
	
	return referenceStart + "En" + referenceEnd
}
