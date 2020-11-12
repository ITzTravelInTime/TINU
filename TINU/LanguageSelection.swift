//
//  LanguageSelection.swift
//  TINU
//
//  Created by Pietro Caruso on 19/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

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
