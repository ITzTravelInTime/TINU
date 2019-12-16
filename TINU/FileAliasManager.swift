//
//  FileAliasManager.swift
//  TINU
//
//  Created by Pietro Caruso on 25/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class FileAliasManager{
	
	@inline(__always) class func resolveFinderAlias(at url: URL) -> String? {
		var origin: URL!
		if finderAlias(url, resolvedURL: &origin) != nil{
			return origin?.path
		}
		return nil
	}
	
	@inline(__always) class func resolveFinderAlias(at path: String) -> String? {
		return resolveFinderAlias(at: URL(fileURLWithPath: path, isDirectory: true))
	}
	
	@inline(__always) class func isAlias(_ url: URL) -> Bool?{
		var origin: URL!
		return finderAlias(url, resolvedURL: &origin)
	}
	
	@inline(__always) class func isAlias(_ path: String) -> Bool?{
		return isAlias(URL(fileURLWithPath: path))
	}
	
	@inline(__always) class func finderAlias(_ path: String, resolvedPath: inout String?) -> Bool?{
		var tmp: URL?
		let res = finderAlias(URL(fileURLWithPath: path, isDirectory: true), resolvedURL: &tmp)
		resolvedPath = tmp?.path
		return res
	}
	
	class func finderAlias(_ url: URL, resolvedURL: inout URL?) -> Bool?{
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
				
			if finderAlias(original ,resolvedURL: &resolvedURL) == nil{
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
