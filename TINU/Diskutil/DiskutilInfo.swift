//
//  DrivesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation
import Command

public extension Diskutil{
final class Info{
	
	private static var _id: BSDID! = nil
	private static var _out: String! = nil
	
	class func getPlist( for path: Path ) -> String?{
		return Diskutil.performCommand(withArgs: ["info", "-plist", path])?.outputString()
	}
	
	class func getProperty(for id: BSDID, named: String) -> Any?{
		do{
			/*
			if id.rawValue.isEmpty{
				return nil
			}
			*/
			
			//probably another check is needed to avoid having different devices plugged one after the other and all having the same id being used with the info from one
			if _id != id || _out == nil{
				_id = id
				//_out = Command.getOut(cmd: "diskutil info -plist \"" + id + "\"") ?? ""
				
				guard let out = getPlist(for: id.rawValue) else { return nil }
				_out = out
				
				if _out.isEmpty{
					_out = nil
					return nil
				}
				
			}
			
			if let dict = try Decode.plistToDictionary(from: _out) as? [String: Any]{
				return dict[named]
			}
			
		}catch let err{
			print("Getting diskutil info property decoding error: \(err.localizedDescription)")
		}
		
		return nil
	}
	
	class func resetCache(){
		_out = nil
		_id = nil
	}
	
}
}

typealias dm = Diskutil.Info
