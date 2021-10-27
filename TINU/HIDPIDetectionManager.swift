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

public final class HIDPIDetectionManager: SimulatableDetectable{
	
	public static var simulatedStatus: Bool? = nil
	
	public static var actualStatus: Bool{
		struct Mem{
			private static var expiration: Date = Date(timeIntervalSinceReferenceDate: 0)
			private static var storedStatus: Bool? = nil
			static var status: Bool?{
				get{
					if storedStatus == nil{
						print("HIDPI: currently stored status is invalid, recalculating ...")
						return nil
					}
					
					let min = Calendar.current.component(.minute, from: Date(timeIntervalSinceReferenceDate: Date() - expiration))
						
					print("HIDPI: time since last status check: \(min) minute/s")
						
					if min < 1 {
						return storedStatus
					}else{
						print("HIDPI: currently stored status is expired, recalculating ...")
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
			print("HIDPI: Calculating new status")
			var allHIDPI = true
			
			for i in NSScreen.screens{
				if i.backingScaleFactor <= 1{
					allHIDPI = false
					break
				}
			}
			
			Mem.status = allHIDPI
			
		}else{
			print("HIDPI: Using stored status")
		}
		
		print("HIDPI: status is \(Mem.status ?? false)")
		
		return Mem.status ?? false
	}
	
	public init(){ }
	
}
