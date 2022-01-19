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

import Foundation
import TINURecovery
import Cocoa

fileprivate func hIDPIPrint( _ text: Any ){
	if sharedEnableDebugPrints {
		print("HIDPI: \(text)")
	}
}

public final class HIDPIDetectionManager{
	public final class PointSizeDetector: SimulatableDetectableTemporized{
		
		public static var expirationInterval: TimeInterval = 60
		public static var expiration: Date = Date()
		public static var storedStatus: T? = nil
		
		public static var simulatedStatus: CGFloat?{
			return simulateHIDPIStatus
		}
		
		public static func calculateStatus() -> CGFloat{
			hIDPIPrint("Calculating new status")
				
			var pixelMax: CGFloat = 0
				
			for i in NSScreen.screens{
				if i.backingScaleFactor > pixelMax{
					pixelMax = i.backingScaleFactor
				}
			}
			
			hIDPIPrint("Status is \(pixelMax)")
			
			return pixelMax
		}
		
		public init(){ }
		
	}
	
	static var isHIDPIEnabledOnAllScreens: Bool{
		return PointSizeDetector.status > 1
	}
	
	static var numberOfScreens: UInt{
		return UInt(NSScreen.screens.count)
	}
	
}
