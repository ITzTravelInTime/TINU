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
	var id: String
	var displayMessage: String
	var isActivated = false
	var isVisible = true
	
	var isUsable = true
	
	var description: String! = ""
	
	func canBeUsed(_ referenceID: String) -> Bool{
		return (id == referenceID) && isActivated && isVisible
	}
	
	func canBeUsed() -> Bool{
		return isActivated && isVisible
	}
	
	func copy() -> OtherOptionsObject{
		return OtherOptionsObject.init(objectID: id, objectMessage: displayMessage, objectDescription: description, objectIsActivated: isActivated, objectIsVisible: isVisible)
	}
	
	init(){
		id             = ""
		displayMessage = "This is an option"
		description    = "This is the description of this option"
	}
	
	init(objectID: String, objectMessage: String, objectDescription: String!) {
		id = objectID
		displayMessage = objectMessage
		description = objectDescription
	}
	
	init(objectID: String, objectMessage: String, objectDescription: String? ,objectIsActivated: Bool, objectIsVisible: Bool) {
		id = objectID
		displayMessage = objectMessage
		isActivated = objectIsActivated
		isVisible = objectIsVisible
		description = objectDescription
	}
}
