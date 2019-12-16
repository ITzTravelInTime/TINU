//
//  PlistXMLManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class DecodeManager{
	
	//dedicated to deserialization
	
	//PLIST Serialization
	
	//Array
	@inline(__always) public class func decodePlistArray(xml: String) throws -> NSArray{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSArray
	}
	
	@inline(__always) public class func decodePlistArrayOpt(xml: String) throws -> NSArray?{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as? NSArray
	}
	
	//Dictionary
	@inline(__always) public class func decodePlistDictionary(xml: String) throws -> NSDictionary{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSDictionary
	}
	
	@inline(__always) public class func decodePlistDictionaryOpt(xml: String) throws -> NSDictionary?{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as? NSDictionary
	}
	
	
	//JSON serialization
	
	//Array
	@inline(__always) public class func decodeJSONArray(json: String) throws -> NSArray{
		return try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! NSArray
	}
	
	@inline(__always) public class func decodeJSONArray(json: String) throws -> NSArray?{
		return try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as? NSArray
	}
	
	//Dictionary
	@inline(__always) public class func decodeJSONDictionary(json: String) throws -> NSDictionary{
		return try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! NSDictionary
	}
	
	@inline(__always) public class func decodeJSONDictionaryOpt(json: String) throws -> NSDictionary?{
		return try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as? NSDictionary
	}
}

public final class EncodeManager{
	
	//dedicated to serialization
	
	//PLIST Serialization
	@inline(__always) public class func EncodeXMLFromArray(decoded: NSArray) throws -> String{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
	}
	
	@inline(__always) public class func EncodeXMLFromDictionary(decoded: NSDictionary) throws -> String{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
	}
	
	@inline(__always) public class func EncodeXMLFromDictionaryOpt(decoded: NSDictionary) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)
	}
	
}
