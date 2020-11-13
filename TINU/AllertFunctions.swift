//
//  AllertFunctions.swift
//  TINU
//
//  Created by Pietro Caruso on 13/07/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

//main algorythm

public struct DialogButton: Equatable {
	let text: String
	let keyEquivalent: String!
}

public func genericDialogCreate(message: String, informative: String, style: NSAlert.Style, icon: NSImage?, buttons: [DialogButton], accessoryView: NSView?) -> NSAlert{
	let dialog = NSAlert()
	dialog.messageText = message
	dialog.informativeText = informative
	dialog.alertStyle = style
	dialog.icon = icon
	
	for i in 0..<buttons.count {
		dialog.addButton(withTitle: buttons[i].text)
		guard let eq = buttons[i].keyEquivalent else {continue}
		dialog.buttons[i].keyEquivalent = eq
	}
	
	dialog.accessoryView = accessoryView
	
	return dialog
}

@inline(__always) public func genericDialogDisplay(message: String, informative: String, style: NSAlert.Style, icon: NSImage?, buttons: [DialogButton], accessoryView: NSView?) -> Bool{
	return genericDialogCreate(message: message, informative: informative, style: style, icon: icon, buttons: buttons, accessoryView: accessoryView).runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
}

//settable icon

@inline(__always) public func msgBoxWithCustomIcon(_ title: String,_ text: String,_ style: NSAlert.Style, _ icon: NSImage?){
	genericDialogCreate(message: title, informative: text, style: style, icon: icon, buttons: [], accessoryView: nil).runModal()
}
/*public func dialogOKCancelWithCustomIcon(question: String, text: String, style: NSAlertStyle, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: "Ok", keyEquivalent: "\r"), DialogButton(text: "Cancel", keyEquivalent: "")], accessoryView: nil)
}*/

public func dialogYesNoWithCustomIcon(question: String, text: String, style: NSAlert.Style, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: "Yes", keyEquivalent: "\r"), DialogButton(text: "No", keyEquivalent: "")], accessoryView: nil)
}

public func dialogCustomWithCustomIcon(question: String, text: String, style: NSAlert.Style, mainButtonText: String, secondButtonText: String, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: mainButtonText, keyEquivalent: nil), DialogButton(text: secondButtonText, keyEquivalent: nil)], accessoryView: nil)
}

public func dialogCriticalWithCustomIcon(question: String, text: String, style: NSAlert.Style, proceedButtonText: String, cancelButtonText: String, icon: NSImage?) -> Bool {
	return !genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: proceedButtonText, keyEquivalent: ""), DialogButton(text: cancelButtonText, keyEquivalent: "\r")], accessoryView: nil)
}

//With app icon

@inline(__always) public func msgBox(_ title: String,_ text: String,_ style: NSAlert.Style){
	msgBoxWithCustomIcon(title, text, style, nil)
}

/*
public func dialogOKCancel(question: String, text: String, style: NSAlertStyle) -> Bool {
	return dialogOKCancelWithCustomIcon(question: question, text: text, style: style, icon: nil)
}
*/

public func dialogYesNo(question: String, text: String, style: NSAlert.Style) -> Bool {
	return dialogYesNoWithCustomIcon(question: question, text: text, style: style, icon: nil)
}

public func dialogCustom(question: String, text: String, style: NSAlert.Style, mainButtonText: String, secondButtonText: String) -> Bool {
	return dialogCustomWithCustomIcon(question: question, text: text, style: style, mainButtonText: mainButtonText, secondButtonText: secondButtonText, icon: nil)
}

public func dialogCritical(question: String, text: String, style: NSAlert.Style, proceedButtonText: String, cancelButtonText: String) -> Bool {
	return dialogCriticalWithCustomIcon(question: question, text: text, style: style, proceedButtonText: proceedButtonText, cancelButtonText: cancelButtonText, icon: nil)
}

//With Warning icon

@inline(__always) public func msgBoxWarning(_ title: String,_ text: String){
	msgBoxWithCustomIcon(title, text, .warning, IconsManager.shared.warningIcon)
}

/*
@inline(__always) public func dialogOKCancelWarning(question: String, text: String) -> Bool {
	return dialogOKCancelWithCustomIcon(question: question, text: text, style: .warning, icon: IconsManager.shared.warningIcon)
}
*/

@inline(__always) public func dialogYesNoWarning(question: String, text: String) -> Bool {
	return dialogYesNoWithCustomIcon(question: question, text: text, style: .warning, icon: IconsManager.shared.warningIcon)
}

@inline(__always) public func dialogCustomWarning(question: String, text: String, mainButtonText: String, secondButtonText: String) -> Bool {
	return dialogCustomWithCustomIcon(question: question, text: text, style: .warning, mainButtonText: mainButtonText, secondButtonText: secondButtonText, icon: IconsManager.shared.warningIcon)
}

@inline(__always) public func dialogCriticalWarning(question: String, text: String, proceedButtonText: String, cancelButtonText: String) -> Bool {
	return dialogCriticalWithCustomIcon(question: question, text: text, style: .warning, proceedButtonText: proceedButtonText, cancelButtonText: cancelButtonText, icon: IconsManager.shared.warningIcon)
}


