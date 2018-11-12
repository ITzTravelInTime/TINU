//
//  FileAliasManager.swift
//  TINU
//
//  Created by Pietro Caruso on 25/10/2018.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class FileAliasManager{
	
	class func resolveFinderAlias(at url: URL) -> String? {
		do {
			let resourceValues = try url.resourceValues(forKeys: [.isAliasFileKey])
			if resourceValues.isAliasFile! {
				let original = try URL(resolvingAliasFileAt: url)
				
				if let res = resolveFinderAlias(at: original){
					return res
				}else{
					return original.path
				}
			}
		} catch  {
			print(error)
		}
		
		return nil
	}
	
	@inline(__always) class func resolveFinderAlias(at path: String) -> String? {
		return resolveFinderAlias(at: URL(fileURLWithPath: path))
	}
	
	class func isAlias(_ url: URL) -> Bool!{
		do {
			let resourceValues = try url.resourceValues(forKeys: [.isAliasFileKey])
			if resourceValues.isAliasFile! {
				return true
			}
		} catch  {
			print(error)
			return nil
		}
		
		return false
	}
	
	@inline(__always) class func isAlias(_ path: String) -> Bool?{
		return isAlias(URL(fileURLWithPath: path))
	}
	
}
