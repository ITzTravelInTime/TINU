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
import TINURecovery
import Cocoa

fileprivate func hIDPIPrint( _ text: Any ){
	if sharedEnableDebugPrints {
		print("HIDPI: \(text)")
	}
}

public final class HIDPIDetectionManager{
	public final class PointSizeDetector: SimulatableDetectable{
		
		public static var simulatedStatus: CGFloat?{
			return simulateHIDPIStatus
		}
		
		public static var actualStatus: CGFloat{
			struct Mem{
				private static var expiration: Date = Date(timeIntervalSinceReferenceDate: 0)
				private static var storedStatus: CGFloat? = nil
				static var status: CGFloat?{
					get{
						if storedStatus == nil{
							hIDPIPrint("Currently stored status is invalid, recalculating ...")
							return nil
						}
						
						let min = Calendar.current.component(.minute, from: Date(timeIntervalSinceReferenceDate: Date() - expiration))
						
						hIDPIPrint("Time since last status check: \(min) minute/s")
						
						if min < 1 {
							return storedStatus
						}else{
							hIDPIPrint("Currently stored status is expired, recalculating ...")
							return nil
						}
						
					}
					set{
						storedStatus = newValue
						expiration = Date()
					}
				}
			}
			
			if Mem.status == nil{
				hIDPIPrint("Calculating new status")
				var pixelMax: CGFloat = 0
				
				for i in NSScreen.screens{
					if i.backingScaleFactor > pixelMax{
						pixelMax = i.backingScaleFactor
					}
				}
				
				Mem.status = pixelMax
				
			}else{
				hIDPIPrint("Using stored status")
			}
			
			hIDPIPrint("Status is \(Mem.status ?? 1)")
			
			return Mem.status ?? 1
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
