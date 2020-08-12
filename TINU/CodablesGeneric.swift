//
//  CodablesGeneric.swift
//  TINU
//
//  Created by Pietro Caruso on 12/08/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

protocol CodablesGenericBase {
	static func createFromDefaultFile<T: CodablesGenericBase>() -> T!
	
	static var defaultResourceFileName: String { get }
	static var defaultResourceFileExtension: String { get }
	static var defaultFilePath: String { get }
	static var defaultFileURL: URL { get}
}

protocol CodablesGeneric: CodablesGenericBase {
	
	static func createFrom<T: CodablesGenericBase>(fileURL: URL) -> T!
	static func createFrom<T: CodablesGenericBase>(file: String) -> T!
}

protocol CodablesGenericCreate: CodablesGenericBase {
	static func createFrom<T: CodablesGenericBase>(fileURL: URL, shouldWrite: Bool) -> T!
	static func createFrom<T: CodablesGenericBase>(file: String, shouldWrite: Bool) -> T!
}
