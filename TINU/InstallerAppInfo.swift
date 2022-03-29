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

import Cocoa

public struct InstallerAppInfo: UIRepresentable{
	var app: InstallerAppInfo?{
		return self
	}
	
	var part: Part?{
		return nil
	}
	
	var path: String?{
		return url?.path
	}
	
	public enum Status: UInt8, Equatable{
		case usable = 0
		case notInstaller
		case broken
		case tooBig
		case tooLittle
		case badAlias
		case legacy
		case error
		case unsupported = 255
	}
	
	var status: Status
	var size: UInt64
	var url: URL?
	
	var displayName: String{
		return FileManager.default.displayName(atPath: url?.path ?? "")
	}
	
	var icon: NSImage?{
		if url == nil { return nil }
		return IconsManager.shared.getInstallerAppIconFrom(path: url!.path)
	}
	
	var genericIcon: NSImage?{
		if look.usesSFSymbols(){
			return IconsManager.shared.genericInstallerAppIcon.themedImage()
		}else{
			return icon
		}
	}
}
