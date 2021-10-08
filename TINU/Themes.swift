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
