//
//  PlistXMLManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class Decode{
	
	//dedicated to deserialization
	
	//PLIST Serialization
	
	//Array
	
	@inline(__always) public class func plistToArray(from: String) throws -> NSArray?{
		assert(!from.isEmpty)
		return try PropertyListSerialization.propertyList(from: from.data(using: .utf8)!, options: [], format: nil) as? NSArray
	}
	
	//Dictionary
	
	@inline(__always) public class func plistToDictionary(from: String) throws -> NSDictionary?{
		assert(!from.isEmpty)
		return try PropertyListSerialization.propertyList(from: from.data(using: .utf8)!, options: [], format: nil) as? NSDictionary
	}
	
	
	//JSON serialization
	
	//Array
	
	@inline(__always) public class func jsonToArray(from: String) throws -> NSArray?{
		assert(!from.isEmpty)
		return try JSONSerialization.jsonObject(with: from.data(using: .utf8)!, options: []) as? NSArray
	}
	
	//Dictionary
	
	@inline(__always) public class func jsonToDictionary(from: String) throws -> NSDictionary?{
		assert(!from.isEmpty)
		return try JSONSerialization.jsonObject(with: from.data(using: .utf8)!, options: []) as? NSDictionary
	}
}

public final class Encode{
	
	//dedicated to serialization
	
	//PLIST Serialization
	@inline(__always) public class func toPlistFrom(array: NSArray) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: array, format: .xml, options: 0), encoding: .utf8)
	}
	
	@inline(__always) public class func toPlistFrom(dictionary: NSDictionary) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0), encoding: .utf8)
	}
	
	//JSON
	
	@inline(__always) public class func toJSONFrom(array: NSArray) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try JSONSerialization.data(withJSONObject: array, options: []), encoding: .utf8)
	}
	
	@inline(__always) public class func toJSONFrom(dictionary: NSDictionary) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try JSONSerialization.data(withJSONObject: dictionary, options: []), encoding: .utf8)
	}
	
}
