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

//functions used in in different parts of the app

func sharedSetSelectedCreationUI( appName: inout NSTextField, appImage: inout NSImageView, driveName: inout NSTextField, driveImage: inout NSImageView, manager: cvm, useDriveName: Bool){
	
	if manager.disk.current == nil || manager.app.current == nil{
		return
	}
	
	driveImage.image = manager.disk.current.genericIcon
	
	if #available(macOS 11.0, *), look.usesSFSymbols(){
		driveImage.contentTintColor = .systemGray
		//driveImage.image = driveImage.image?.withSymbolWeight(.thin)
	}
	
	if useDriveName{
		driveName.stringValue = manager.disk.current.driveName
	}else{
		driveName.stringValue = manager.disk.current.displayName
	}
	
	appImage.image = manager.app.current.icon
	
	if #available(macOS 11.0, *), look.usesSFSymbols(){
		appImage.contentTintColor = .systemGray
		//appImage.image = appImage.image?.withSymbolWeight(.thin)
	}
	
	appName.stringValue = manager.app.current.displayName
	
}

