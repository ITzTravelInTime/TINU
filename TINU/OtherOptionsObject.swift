//
//  OtherOptionsItm.swift
//  TINU
//
//  Created by Pietro Caruso on 18/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

//other options
public class OtherOptionsObject{
	var id: OtherOptionsManager.OtherOptionID
	var title: String
	var isActivated = false
	var isVisible = true
	
	var isUsable = true
	
	var description: String! = ""
	
	func canBeUsed(_ referenceID: OtherOptionsManager.OtherOptionID) -> Bool{
		return (id == referenceID) && isActivated && isVisible
	}
	
	func canBeUsed() -> Bool{
		return isActivated && isVisible
	}
	
	func copy() -> OtherOptionsObject{
		return OtherOptionsObject.init(objectID: id, objectTitle: title, objectDescription: description, objectIsActivated: isActivated, objectIsVisible: isVisible)
	}
	
	init(){
		id             = OtherOptionsManager.OtherOptionID.unknown
		title = "This is an option"
		description    = "This is the description of this option"
	}
	
	init(objectID: OtherOptionsManager.OtherOptionID, objectTitle: String, objectDescription: String!) {
		id = objectID
		title = objectTitle
		description = objectDescription
	}
	
	init(objectID: OtherOptionsManager.OtherOptionID, objectTitle: String, objectDescription: String? ,objectIsActivated: Bool, objectIsVisible: Bool) {
		id = objectID
		title = objectTitle
		isActivated = objectIsActivated
		isVisible = objectIsVisible
		description = objectDescription
	}
}
