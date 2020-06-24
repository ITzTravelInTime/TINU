//
//  OtherOptionsItm.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

//other options
public struct OtherOptionsObject{
	var id: OtherOptionsManager.OtherOptionID = .unknown
	var title: String = ""
	
	var isActivated = false
	var isVisible = true
	var isUsable = true
	
	var isAdvanced = false
	
	var description: String! = ""
	
	func canBeUsed(_ referenceID: OtherOptionsManager.OtherOptionID) -> Bool{
		return (id == referenceID) && isActivated && isVisible
	}
	
	func canBeUsed() -> Bool{
		return isActivated && isVisible
	}
	
	func copy() -> OtherOptionsObject{
		return OtherOptionsObject(from: self)
	}
}

extension OtherOptionsObject{
	init(from other: OtherOptionsObject) {
		self.init()
		
		self = other
		
		//self.init(id: other.id, title: other.title, isActivated: other.isActivated, isVisible: other.isVisible, isUsable: other.isUsable, isAdvanced: other.isActivated, description: other.description)
	}
}
