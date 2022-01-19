/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

/*
import Cocoa

public protocol Copying{
	func copy() -> Self
}

public protocol Messange {
	associatedtype T
	associatedtype G
	var message: String { get }
	var description: String { get }
	func create() -> G
	func send() -> T
	func justSend()
}

public extension Messange{
	func justSend() {
		let _ = send()
	}
}

public extension NSApplication.ModalResponse{
	func isFirstButton() -> Bool{
		self == NSApplication.ModalResponse.alertFirstButtonReturn
	}
	
	func isAnotherButton() -> Bool{
		return !isFirstButton()
	}
	
	func ok() -> Bool{
		return isFirstButton()
	}
	
	func notOk() -> Bool{
		return !isFirstButton()
	}
	
}

public struct Dialog: Messange, Copying, Equatable{
	
	public struct DialogButton: Equatable {
		public var text: String
		public var keyEquivalent: String?
	}
	
	public var message: String
	public var description: String
	
	public var style: NSAlert.Style = .informational
	public var icon: NSImage? = nil
	public var buttons: [Dialog.DialogButton] = []
	public var accessoryView: NSView?
	
	public func create() -> NSAlert {
		let dialog = NSAlert()
		dialog.messageText = message
		dialog.informativeText = description
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
	
	public func send() -> NSApplication.ModalResponse? {
		return create().runModal()
	}
	
	public func justSend() {
		let _ = send()
	}
	
	public func warning() -> Dialog{
		var mycopy = copy()
		mycopy.style = .warning
		return mycopy
	}
	
	public func critical() -> Dialog{
		var mycopy = copy()
		mycopy.style = .critical
		return mycopy
	}
	
	public func warningWithIcon() -> Dialog{
		var mycopy = warning()
		mycopy.icon = IconsManager.shared.alertWarningIcon
		return mycopy
	}
	
	public func criticalWithIcon() -> Dialog{
		var mycopy = critical()
		mycopy.icon = IconsManager.shared.stopIcon
		return mycopy
	}
	
	public mutating func addButton(title: String, keyEquivalent: String? = nil){
		buttons.append(DialogButton(text: title, keyEquivalent: keyEquivalent))
	}
	
	public func addingButton(title: String, keyEquivalent: String? = nil) -> Dialog{
		var mycopy = copy()
		mycopy.addButton(title: title, keyEquivalent: keyEquivalent)
		return mycopy
	}
	
	public func yesNo() -> Dialog{
		return addingButton(title: "Yes", keyEquivalent: "\r").addingButton(title: "No")
	}
	
	public func okCancel() -> Dialog{
		return addingButton(title: "Ok", keyEquivalent: "\r").addingButton(title: "Cancel")
	}
	
	public func copy() -> Dialog {
		return Dialog(message: message, description: description, style: style, icon: icon, buttons: buttons, accessoryView: accessoryView)
	}
}*/

/*
public func genericDialogCreate(message: String, informative: String, style: NSAlert.Style, icon: NSImage? = nil, buttons: [Dialog.DialogButton], accessoryView: NSView?) -> NSAlert{
	
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

@inline(__always) public func genericDialogDisplay(message: String, informative: String, style: NSAlert.Style, icon: NSImage? = nil, buttons: [Dialog.DialogButton], accessoryView: NSView?) -> Bool{
	return genericDialogCreate(message: message, informative: informative, style: style, icon: icon, buttons: buttons, accessoryView: accessoryView).runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
}

//settable icon

@inline(__always) public func msgBoxWithCustomIcon(_ title: String,_ text: String,_ style: NSAlert.Style, _ icon: NSImage? = nil){
	genericDialogCreate(message: title, informative: text, style: style, icon: icon, buttons: [], accessoryView: nil).runModal()
}
/*public func dialogOKCancelWithCustomIcon(question: String, text: String, style: NSAlertStyle, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [DialogButton(text: "Ok", keyEquivalent: "\r"), DialogButton(text: "Cancel", keyEquivalent: "")], accessoryView: nil)
}*/

public func dialogYesNoWithCustomIcon(question: String, text: String, style: NSAlert.Style, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [Dialog.DialogButton(text: "Yes", keyEquivalent: "\r"), Dialog.DialogButton(text: "No", keyEquivalent: "")], accessoryView: nil)
}

public func dialogCustomWithCustomIcon(question: String, text: String, style: NSAlert.Style, mainButtonText: String, secondButtonText: String, icon: NSImage?) -> Bool {
	return genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [Dialog.DialogButton(text: mainButtonText, keyEquivalent: nil), Dialog.DialogButton(text: secondButtonText, keyEquivalent: nil)], accessoryView: nil)
}

public func dialogCriticalWithCustomIcon(question: String, text: String, style: NSAlert.Style, proceedButtonText: String, cancelButtonText: String, icon: NSImage?) -> Bool {
	return !genericDialogDisplay(message: question, informative: text, style: style, icon: icon, buttons: [Dialog.DialogButton(text: proceedButtonText, keyEquivalent: ""), Dialog.DialogButton(text: cancelButtonText, keyEquivalent: "\r")], accessoryView: nil)
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
	msgBoxWithCustomIcon(title, text, .warning, IconsManager.shared.alertWarningIcon)
}

/*
@inline(__always) public func dialogOKCancelWarning(question: String, text: String) -> Bool {
	return dialogOKCancelWithCustomIcon(question: question, text: text, style: .warning, icon: IconsManager.shared.warningIcon)
}
*/

@inline(__always) public func dialogYesNoWarning(question: String, text: String) -> Bool {
	return dialogYesNoWithCustomIcon(question: question, text: text, style: .warning, icon: IconsManager.shared.alertWarningIcon)
}

@inline(__always) public func dialogCustomWarning(question: String, text: String, mainButtonText: String, secondButtonText: String) -> Bool {
	return dialogCustomWithCustomIcon(question: question, text: text, style: .warning, mainButtonText: mainButtonText, secondButtonText: secondButtonText, icon: IconsManager.shared.alertWarningIcon)
}

@inline(__always) public func dialogCriticalWarning(question: String, text: String, proceedButtonText: String, cancelButtonText: String) -> Bool {
	return dialogCriticalWithCustomIcon(question: question, text: text, style: .warning, proceedButtonText: proceedButtonText, cancelButtonText: cancelButtonText, icon: IconsManager.shared.alertWarningIcon)
}
*/

