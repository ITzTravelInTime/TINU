//
//  AllertFunctionsWithTextManager.swift
//  TINU
//
//  Created by Pietro Caruso on 17/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Cocoa
import TINUNotifications

public func msgboxWithManagerGeneric(_ manager: TextManagerGet, _ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = IconsManager.shared.warningIcon.normalImage()){
	var title = manager.getViewString(context: handle, stringID: name + "Title")
	var content = manager.getViewString(context: handle, stringID: name)
	
	if title == nil || content == nil{
		//msgBoxWarning("Msbgox text not found!", "The textAseets file for your current language, lacks the at least part of the text for the msgbox: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.")
		Alert(message: "Msbgox text not found!", description: "The textAseets file for your current language, lacks the at least part of the text for the msgbox: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.").criticalWithIcon().justSend()
		fatalError("Message content not found in the text assets")
	}
	
	if let list = parseList{
		title = parse(messange: title!, keys: list)
		content = parse(messange: content!, keys: list)
	}
	
	//msgBoxWithCustomIcon(title!, content!, style, icon)
	Alert(message: title!, description: content!, style: .init(from: style), icon: icon).displayingOnWindow().justSend()
}

public func dialogWithManagerGeneric(_ manager: TextManagerGet, _ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = IconsManager.shared.warningIcon.normalImage()) -> Bool{
	
	var title = manager.getViewString(context: handle, stringID: name + "Title")
	var content = manager.getViewString(context: handle, stringID: name)
	
	let yes = manager.getViewString(context: handle, stringID: name + "Yes")
	let no = manager.getViewString(context: handle, stringID: name + "No")
	
	if title == nil || content == nil || yes == nil || no == nil{
		//msgBoxWarning("Dialog text not found!", "The textAseets file for your current language, lacks the at least part of the text for the dialog: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.")
		Alert(message: "Dialog text not found!", description: "The textAseets file for your current language, lacks the at least part of the text for the dialog: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.").criticalWithIcon().justSend()
		fatalError("Message content not found in the text assets")
	}
	
	if let list = parseList{
		title = parse(messange: title!, keys: list)
		content = parse(messange: content!, keys: list)
	}
	
	//return dialogCustomWithCustomIcon(question: title!, text: content!, style: style, mainButtonText: yes!, secondButtonText: no!, icon: icon)
	return Alert(message: title!, description: content!, style: .init(from: style), icon: icon).addingButton(title: yes!).addingButton(title: no!).displayingOnWindow().send().ok()
}

public func dialogGenericWithManagerGeneric(_ manager: TextManagerGet, _ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = nil) -> NSAlert{
	
	var title = manager.getViewString(context: handle, stringID: name + "Title")
	var content = manager.getViewString(context: handle, stringID: name)
	
	var buttons: [Alert.Button] = []
	var last: Alert.Button!
	var num: UInt8 = 1
	
	repeat{
		
		if last != nil{
			buttons.append(last)
		}
		let bid = name + String(num)
		print("looking for button: \(bid)")
		
		if let text = manager.getViewString(context: handle, stringID: bid){
			let key = manager.getViewString(context: handle, stringID: bid + "Key")
			last = Alert.Button(text: text, keyEquivalent: key)
			num += 1
		}else{
			last = nil
		}
		
	}while (last != nil)
	
	if title == nil || content == nil || buttons.isEmpty{
		print(buttons)
		print(title == nil)
		print(content == nil)
		//msgBoxWarning("Dialog text not found!", "The textAseets file for your current language, lacks the at least part of the text for the dialog: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.")
		Alert(message: "Dialog text not found!", description: "The textAseets file for your current language, lacks the at least part of the text for the dialog: \(name) in the viewId: \(handle.id)\n\nMake sure that the viewID is implemented properly into the textAssets.").criticalWithIcon().justSend()
		let msg = ("Message content not found in the text assets: \(handle.id) : \(name)")
		log(msg)
		fatalError(msg)
	}
	
	if let list = parseList{
		title = parse(messange: title!, keys: list)
		content = parse(messange: content!, keys: list)
	}
	
	//return genericDialogCreate(message: title!, informative: content!, style: style, icon: icon, buttons: buttons, accessoryView: nil)
	
	return Alert(message: title!, description: content!, style: .init(from: style), icon: icon, buttons: buttons).displayingOnWindow().create()
}

@inline(__always) public func dialogGenericWithManagerBoolGeneric(_ manager: TextManagerGet, _ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = IconsManager.shared.warningIcon.normalImage()) -> Bool{
	return dialogGenericWithManager(handle, name: name, parseList: parseList, style: style, icon: icon).runModal().ok()
}

#if TINU

@inline(__always) public func msgboxWithManager(_ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = nil){
	msgboxWithManagerGeneric(TextManager, handle, name: name, parseList: parseList, style: style, icon: icon)
}

@inline(__always) public func dialogWithManager(_ handle: ViewID, name: String, parseList: [String: String]! = nil, defaultAlternate: Bool = false, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = nil) -> Bool{
	return dialogWithManagerGeneric(TextManager, handle, name: name, parseList: parseList, style: style, icon: icon)
}

@inline(__always) public func dialogGenericWithManager(_ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = nil) -> NSAlert{
	return dialogGenericWithManagerGeneric(TextManager, handle, name: name, parseList: parseList, style: style, icon: icon)
}

@inline(__always) public func dialogGenericWithManagerBool(_ handle: ViewID, name: String, parseList: [String: String]! = nil, style: NSAlert.Style = NSAlert.Style.warning, icon: NSImage? = nil) -> Bool{
	return dialogGenericWithManagerGeneric(TextManager, handle, name: name, parseList: parseList, style: style, icon: icon).runModal().ok()
}

#endif
