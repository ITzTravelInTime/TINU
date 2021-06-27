//
//  OtherOptionsItm.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

extension CreationProcess.OptionsManager{
	//other options
	public struct Object{
		let id: ID
		let description: Description
		
		/**Determinates if the option will be executed or not*/
		var isActivated = false
		/**Determinates if the option needs to be shown to the user*/
		var isVisible = true
		/**Determinates if the option needs to be modifiable by the user if it's shown*/
		var isUsable = true
		/**Determinates if the option needs to be disaplyed into the advanced options section*/
		var isAdvanced = false
		
		func canBeUsed(_ referenceID: ID) -> Bool{
			return (id == referenceID) && isActivated && isVisible
		}
		
		func canBeUsed() -> Bool{
			return isActivated && isVisible
		}
		
		func copy() -> Object{
			return Object(from: self)
		}
	}
	
}

extension CreationProcess.OptionsManager.Object{
	init(from other: CreationProcess.OptionsManager.Object) {
		self.init(id: other.id, description: other.description)
		
		self = other
		
		//self.init(id: other.id, title: other.title, isActivated: other.isActivated, isVisible: other.isVisible, isUsable: other.isUsable, isAdvanced: other.isActivated, description: other.description)
	}
}
