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

public final class FileAliasManager{
	
	@inline(__always) class func resolve(at url: URL) -> String? {
		var origin: URL!
		if process(url, resolvedURL: &origin) != nil{
			return origin?.path
		}
		return nil
	}
	
	@inline(__always) class func resolve(at path: String) -> String? {
		return resolve(at: URL(fileURLWithPath: path, isDirectory: true))
	}
	
	@inline(__always) class func isAlias(_ url: URL) -> Bool?{
		var origin: URL!
		return process(url, resolvedURL: &origin)
	}
	
	@inline(__always) class func isAlias(_ path: String) -> Bool?{
		return isAlias(URL(fileURLWithPath: path))
	}
	
	@inline(__always) class func finderAlias(_ path: String, resolvedPath: inout String?) -> Bool?{
		var tmp: URL?
		let res = process(URL(fileURLWithPath: path, isDirectory: true), resolvedURL: &tmp)
		resolvedPath = tmp?.path
		return res
	}
	
	class func process(_ url: URL, resolvedURL: inout URL?) -> Bool?{
		do {
			if try !url.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile! {
				resolvedURL = url
				return false
			}
			
			let original = try URL(resolvingAliasFileAt: url)
				
			if !FileManager.default.fileExists(atPath: original.path){
				resolvedURL = nil
				return nil
			}
				
			if process(original ,resolvedURL: &resolvedURL) == nil{
				resolvedURL = nil
				return nil
			}
				
			resolvedURL = original
			return true
			
		} catch  {
			print(error)
			resolvedURL = nil
			return nil
		}
	}
	
}
