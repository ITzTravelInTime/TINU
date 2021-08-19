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
	public enum AppLook: String, Codable, Equatable, CaseIterable, RawRepresentable{
		case noShadowsOldIcons = ""
		case recovery = "recovery"
		case noShadowsSFSymbols = "symbols"
		case noShadowsSFSymbolsFill = "symbols.fill"
		case shadowsSFSymbols = "shadows.symbols"
		case shadowsSFSymbolsFill = "shadows.symbols.fill"
		case shadowsOldIcons    = "shadows"
		
		func isRecovery() -> Bool{
			return self.rawValue.contains("recovery")
		}
		
		func supportsShadows() -> Bool{
			return self.rawValue.contains("shadows")
		}
		
		func usesSFSymbols() -> Bool{
			if #available(macOS 11.0, *){
				return self.rawValue.contains("symbols")
			}
			return false
		}
		
		func usesFilledSFSymbols() -> Bool{
			return self.rawValue.contains("symbols.fill")
		}
	}
}
