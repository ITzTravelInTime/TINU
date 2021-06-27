//
//  OptionsExecution.swift
//  TINU
//
//  Created by Pietro Caruso on 25/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation

extension CreationProcess.OptionsManager{
	public struct Execution: CreationProcessSection{
		
		let ref: CreationProcess
		
		init(reference: CreationProcess) {
			ref = reference
		}
		
		var canFormat: Bool{
			if simulateFormatSkip{
				return false
			}
				
			if ref.disk.shouldErase || (ref.disk?.current?.isDrive ?? false){
				return true
			}
					
			guard let o = ref.options.list[.forceToFormat]?.canBeUsed() else { return false }
				
			if o {
				log("   Forced drive erase enabled")
			}
			
			return o
		}
		
		var canUseApfs: Bool{
			if !ref.installMac{
				return true
			}
			
			guard let o = ref.options.list[.notUseApfs]?.canBeUsed() else { return true }
			
			if o {
				log("   Forced APFS automatic upgrade enabled")
			}
			
			return !o
		}
		
	}
}
