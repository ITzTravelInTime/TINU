//
//  CodablesGeneric.swift
//  TINU
//
//  Created by Pietro Caruso on 12/08/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

public protocol CodableDefaults{
	static var defaultResourceFileExtension: String { get }
	static var defaultResourceFileName: String { get }
}

public struct CodableCreation<T: CodableDefaults & Codable & Equatable>{
	
	public static func createFrom(fileURL: URL) -> T!{
		
		if fileURL.pathExtension != T.defaultResourceFileExtension{
			return nil
		}
		
		if !FileManager.default.fileExists(atPath: fileURL.path){
			return nil
		}
		
		do{
			let data = try String.init(contentsOf: fileURL).data(using: .utf8)!
			let new = try JSONDecoder().decode(T.self, from: data)
					
			//print(new)
					
			return new
			
		}catch let err{
			print(err)
		}
		
		return nil
	}
	
	//assumes the file string is a file path for a .json file
	public static func createFrom(file: String) -> T!{
		return createFrom(fileURL: URL(fileURLWithPath: file, isDirectory: false))
	}
	
	public static func createFromDefaultFile(_ useLanguage: Bool = true) -> T!{
		
		var path: String!
		
		if useLanguage{
			path = getLanguageFile(fileName: T.defaultResourceFileName, fextension: T.defaultResourceFileExtension)
		}else{
			path = Bundle.main.path(forResource: T.defaultResourceFileName, ofType: T.defaultResourceFileExtension)
		}
		
		if path == nil{
			return nil
		}
		
		return createFrom(file: path!)
	}
	
	public static func getEncoded(_ source: T) -> String!{
		do{
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			let data = (try encoder.encode(source))
			return String(data: data, encoding: .utf8)
		}catch let err{
			print(err)
		}
		
		return nil
	}
}
