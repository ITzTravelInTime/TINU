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
			private static var expiration: Date? = nil
			private static var storedStatus: Bool? = nil
			static var status: Bool?{
				get{
					if storedStatus == nil || expiration == nil{
						return nil
					}
					
					if let exp = expiration{
						if exp.timeIntervalSinceNow < (60) {
							return storedStatus
						}else{
							expiration = nil
						}
					}
					
					return nil
				}
				set{
					storedStatus = newValue
					expiration = Date()
				}
			}
		}
		
		if Mem.status == nil{
			
			var allHIDPI = true
			
			for i in NSScreen.screens{
				if i.backingScaleFactor == 1{
					allHIDPI = false
					break
				}
			}
			
			Mem.status = allHIDPI
			
		}
		
		print("HIDPI status: \(Mem.status ?? false)")
		
		return Mem.status ?? false
	}
	
	public init(){ }
	
}
