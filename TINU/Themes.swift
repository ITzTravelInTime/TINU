//
//  Themes.swift
//  TINU
//
//  Created by Pietro Caruso on 09/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation
import AppKit

fileprivate let toggleRecoveryModeShadows = !false

public enum AppLook: UInt8, Codable, Equatable, CaseIterable{
	case shadowsOldIcons    = 0
	case noShadowsSFSymbols = 1
	case   shadowsSFSymbols = 2
	case recovery = 255
	
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

public var look: AppLook{
	if let lk = simulateLook{
		return lk
	}
	
	if ((sharedIsOnRecovery && !toggleRecoveryModeShadows) || simulateDisableShadows){
		return .recovery
	}
	if #available(macOS 11.0, *) {
		return .shadowsSFSymbols
	}else{
		return .shadowsOldIcons
	}
}

#if !isTool
public final class CustomizationWindowManager{
	static let shared = CustomizationWindowManager()
	
	var referenceWindow: NSWindow!
}
#endif
