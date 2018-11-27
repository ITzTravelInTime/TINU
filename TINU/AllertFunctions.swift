//
//  AllertFunctions.swift
//  TINU
//
//  Created by Pietro Caruso on 13/07/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

@inline(__always) public func msgBox(_ title: String,_ text: String,_ style: NSAlertStyle){
	let a = NSAlert()
	a.messageText = title
	a.informativeText = text
	a.alertStyle = style
	a.runModal()
}

public func msgBoxWarning(_ title: String,_ text: String){
	let a = NSAlert()
	a.messageText = title
	a.informativeText = text
	a.alertStyle = .warning
	a.icon = IconsManager.shared.warningIcon
	a.runModal()
}

@inline(__always) public func dialogOKCancel(question: String, text: String, style: NSAlertStyle) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.addButton(withTitle: "OK")
	myPopup.addButton(withTitle: "Cancel")
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return false
	}
	return true
}

@inline(__always) public func dialogYesNo(question: String, text: String, style: NSAlertStyle) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.addButton(withTitle: "Yes")
	myPopup.addButton(withTitle: "No")
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return false
	}
	return true
}

public func dialogOKCancelWarning(question: String, text: String, style: NSAlertStyle) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.addButton(withTitle: "OK")
	myPopup.addButton(withTitle: "Cancel")
	myPopup.icon = IconsManager.shared.warningIcon
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return false
	}
	return true
}

public func dialogYesNoWarning(question: String, text: String, style: NSAlertStyle) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.addButton(withTitle: "Yes")
	myPopup.addButton(withTitle: "No")
	myPopup.icon = IconsManager.shared.warningIcon
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return false
	}
	return true
}

public func dialogCustomWarning(question: String, text: String, style: NSAlertStyle, mainButtonText: String, secondButtonText: String) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.addButton(withTitle: mainButtonText)
	myPopup.addButton(withTitle: secondButtonText)
	myPopup.icon = IconsManager.shared.warningIcon
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return false
	}
	return true
}

public func dialogCriticalWarning(question: String, text: String, style: NSAlertStyle, proceedButtonText: String, cancelButtonText: String) -> Bool {
	let myPopup: NSAlert = NSAlert()
	myPopup.messageText = question
	myPopup.informativeText = text
	myPopup.alertStyle = style
	myPopup.icon = IconsManager.shared.warningIcon
	myPopup.addButton(withTitle: proceedButtonText)
	myPopup.addButton(withTitle: cancelButtonText)
	// Make the left button the Default button.
	myPopup.buttons[0].keyEquivalent = "";
	myPopup.buttons[1].keyEquivalent = "\r"	// Return key
	let res = myPopup.runModal()
	if res == NSAlertFirstButtonReturn {
		return true	// proceed
	}
	return false
}
