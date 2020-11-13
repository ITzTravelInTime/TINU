//
//  DarkModeDetection.swift
//  TINU
//
//  Created by ITzTravelInTime on 21/10/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Cocoa

enum UIStyle : String {
	case Dark, Light
	
	init() {
		let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
		self = UIStyle(rawValue: type)!
	}
}

extension NSView {
	var isDarkMode: Bool {
		get{
			
			if #available(OSX 10.14, *) {
				return self.effectiveAppearance.name.rawValue == NSAppearance.Name.darkAqua.rawValue
			}
			
			return false
			
		}
	}
}
