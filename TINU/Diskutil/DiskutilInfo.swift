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
