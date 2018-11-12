//
//  PlistXMLManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class PlistXMLManager{
	
	//dedicated to plist serialization and deserialization
	@inline(__always) public class func decodeXMLArray(xml: String) throws -> NSArray{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSArray
	}
	
	@inline(__always) public class func codeXMLFromArray(decoded: NSArray) throws -> String{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
	}
	
	@inline(__always) public class func decodeXMLDictionary(xml: String) throws -> NSDictionary{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as! NSDictionary
	}
	
	@inline(__always) public class func decodeXMLDictionaryOpt(xml: String) throws -> NSDictionary?{
		return try PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, options: [], format: nil) as? NSDictionary
	}
	
	@inline(__always) public class func codeXMLFromDictionary(decoded: NSDictionary) throws -> String{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)!
	}
	
	@inline(__always) public class func codeXMLFromDictionaryOpt(decoded: NSDictionary) throws -> String?{
		//let d = try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0)
		return String.init(data: try PropertyListSerialization.data(fromPropertyList: decoded, format: .xml, options: 0), encoding: .utf8)
	}
	
	@inline(__always) public class func decodeJSONDictionary(json: String) throws -> NSDictionary?{
		return try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as? NSDictionary
	}
}
