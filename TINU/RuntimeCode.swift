//
//  RuntimeCode.swift
//  TINU
//
//  Created by ITzTravelInTime on 17/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

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

