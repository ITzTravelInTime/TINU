//
//  Themes.swift
//  TINU
//
//  Created by Pietro Caruso on 09/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation
import AppKit

extension UIManager{
public enum AppLook: String, Codable, Equatable, CaseIterable{
	case shadowsOldIcons    = "shadowsOldIcons"
	case noShadowsSFSymbols = "noShadowsSFSymbols"
	case   shadowsSFSymbols = "shadowSFSymbols"
	case recovery = "recovery"
	
	func supportsShadows() -> Bool{
		return self == .shadowsOldIcons || self == .shadowsSFSymbols
	}
	
	func usesSFSymbols() -> Bool{
		if #available(macOS 11.0, *){
			return self == .noShadowsSFSymbols || self == .shadowsSFSymbols
		}
		return false
	}
}
}

#if !isTool
public final class CustomizationWindowManager{
	static let shared = CustomizationWindowManager()
	
	var referenceWindow: NSWindow!
}
#endif
