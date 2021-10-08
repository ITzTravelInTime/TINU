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

import Cocoa

//here there are all the variables that are accessible in all the app to determinate the status of the app and what it is doing
let toggleRecoveryModeShadows = false

public var look: UIManager.AppLook{
	
	struct MEM{
		static var result: UIManager.AppLook! = nil
	}
	
	if let r = MEM.result{
		return r
	}
	
	var ret: UIManager.AppLook! = nil
	
	if let lk = simulateLook, ret == nil{
		print("Forcing a simulated Theme \(lk.rawValue)")
		ret = lk
	}
	
	if (Recovery.status && !toggleRecoveryModeShadows && (ret == nil)){
		print("Recovery theme will be used")
		ret = .recovery
	}
	
	if #available(macOS 11.0, *), ret == nil {
		print("Shadows SF Symbols theme will be used")
		ret = .shadowsSFSymbolsFill
	}else{
		print("Shadows Old Icons theme will be used")
	}
	
	MEM.result = ret ?? .shadowsOldIcons
	return MEM.result!
}

