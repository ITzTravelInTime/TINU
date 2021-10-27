//
//  HIDPIDetectionManager.swift
//  TINU
//
//  Created by ITzTravelInTime on 27/10/2021.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation
import TINURecovery
import Cocoa

fileprivate func hIDPIPrint( _ text: Any ){
	if sharedEnableDebugPrints {
		print("HIDPI: \(text)")
	}
}

public final class HIDPIDetectionManager: SimulatableDetectable{
	
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
	
	static var isHIDPIEnabledOnAllScreens: Bool{
		return status > 1
	}
	
	static var numberOfScreens: UInt{
		return UInt(NSScreen.screens.count)
	}
	
	public init(){ }
	
}
