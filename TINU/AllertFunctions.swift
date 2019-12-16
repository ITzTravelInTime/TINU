//
//  AllertFunctions.swift
//  TINU
//
//  Created by Pietro Caruso on 13/07/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

//main algorythm

public struct DialogButton {
	let text: String
	let keyEquivalent: String!
}

public func genericDialogCreate(message: String, informative: String, style: NSAlertStyle, icon: NSImage?, buttons: [DialogButton], accessoryView: NSView?) -> NSAlert{
	let dialog = NSAlert()
	dialog.messageText = message
	dialog.informativeText = informative
	dialog.alertStyle = style
	dialog.icon = icon
	
	for i in 0..<buttons.count {
		dialog.addButton(withTitle: buttons[i].text)
		if let eq = buttons[i].keyEquivalent{
			dialog.buttons[i].keyEquivalent = eq
		}
	}
	
	if let accessory = accessoryView{
		dialog.accessoryView = accessory
	}
	
	return dialog
}

@inline(__always) public func genericDialogDisplay(message: String, informative: String, style: NSAlertStyle, icon: NSImage?, buttons: [DialogButton], accessoryView: NSView?) -> Bool{
	let res = genericDialogCreate(message: message, informative: informative, style: style, icon: icon, buttons: buttons, accessoryView: accessoryView).runModal()
	if res == NSAlertFirstButtonReturn{
		return false
	}
	return true
}

//settable icon

@inline(__always) public func msgBoxWithCustomIcon(_ title: String,_ text: String,_ style: NSAlertStyle, _ icon: NSImage?){
	genericDialogCreate(message: title, informative: text, style: style, icon: icon, buttons: [], accessoryView: nil).runModal()
}

public func dialogOKCancelWithCustomIcon(question: String, text: String, style: NSAlertStyle, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: "Ok", keyEquivalent: nil), DialogButton(text: "Cancel", keyEquivalent: nil)], accessoryView: nil)
}

public func dialogYesNoWithCustomIcon(question: String, text: String, style: NSAlertStyle, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: "Yes", keyEquivalent: nil), DialogButton(text: "No", keyEquivalent: nil)], accessoryView: nil)
}

public func dialogCustomWithCustomIcon(question: String, text: String, style: NSAlertStyle, mainButtonText: String, secondButtonText: String, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: mainButtonText, keyEquivalent: nil), DialogButton(text: secondButtonText, keyEquivalent: nil)], accessoryView: nil)
}

public func dialogCriticalWithCustomIcon(question: String, text: String, style: NSAlertStyle, proceedButtonText: String, cancelButtonText: String, icon: NSImage?) -> Bool {
	return !genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: proceedButtonText, keyEquivalent: ""), DialogButton(text: cancelButtonText, keyEquivalent: "\r")], accessoryView: nil)
}

//With app icon

@inline(__always) public func msgBox(_ title: String,_ text: String,_ style: NSAlertStyle){
	msgBoxWithCustomIcon(title, text, style, nil)
}

public func dialogOKCancel(question: String, text: String, style: NSAlertStyle) -> Bool {
	return dialogOKCancelWithCustomIcon(question: question, text: text, style: style, icon: nil)
}

public func dialogYesNo(question: String, text: String, style: NSAlertStyle) -> Bool {
	return dialogYesNoWithCustomIcon(question: question, text: text, style: style, icon: nil)
}

public func dialogCustom(question: String, text: String, style: NSAlertStyle, mainButtonText: String, secondButtonText: String) -> Bool {
	return dialogCustomWithCustomIcon(question: question, text: text, style: style, mainButtonText: mainButtonText, secondButtonText: secondButtonText, icon: nil)
}

public func dialogCritical(question: String, text: String, style: NSAlertStyle, proceedButtonText: String, cancelButtonText: String) -> Bool {
	return dialogCriticalWithCustomIcon(question: question, text: text, style: style, proceedButtonText: proceedButtonText, cancelButtonText: cancelButtonText, icon: nil)
}

//With Warning icon

fileprivate let warningIcon = IconsManager.shared.warningIcon

public func msgBoxWarning(_ title: String,_ text: String){
	msgBoxWithCustomIcon(title, text, .warning, warningIcon)
}

public func dialogOKCancelWarning(question: String, text: String) -> Bool {
	return dialogOKCancelWithCustomIcon(question: question, text: text, style: .warning, icon: warningIcon)
}

public func dialogYesNoWarning(question: String, text: String) -> Bool {
	return dialogYesNoWithCustomIcon(question: question, text: text, style: .warning, icon: warningIcon)
}

public func dialogCustomWarning(question: String, text: String, mainButtonText: String, secondButtonText: String) -> Bool {
	return dialogCustomWithCustomIcon(question: question, text: text, style: .warning, mainButtonText: mainButtonText, secondButtonText: secondButtonText, icon: warningIcon)
}

public func dialogCriticalWarning(question: String, text: String, proceedButtonText: String, cancelButtonText: String) -> Bool {
	return dialogCriticalWithCustomIcon(question: question, text: text, style: .warning, proceedButtonText: proceedButtonText, cancelButtonText: cancelButtonText, icon: warningIcon)
}
