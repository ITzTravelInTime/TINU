//
//  InstallerAppInfo.swift
//  TINU
//
//  Created by Pietro Caruso on 20/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

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
			return IconsManager.shared.genericInstallerAppIcon
		}else{
			return icon
		}
	}
}
