//
//  DarkModeDetection.swift
//  TINU
//
//  Created by ITzTravelInTime on 21/10/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Cocoa

enum InterfaceStyle : String {
	case Dark, Light
	
	init() {
		let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
		self = InterfaceStyle(rawValue: type)!
	}
}

extension NSView {
	var isDarkMode: Bool {
		get{
			
			if #available(OSX 10.14, *) {
				return self.effectiveAppearance.name == NSAppearanceNameDarkAqua
			}else{
				return false
			}
			
		}
	}
}
