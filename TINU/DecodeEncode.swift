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
/*
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
*/
