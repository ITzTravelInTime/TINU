//
//  NotificationsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 23/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Cocoa

public final class NotificationsManager: ViewID{
	public let id: String = "NotificationsManager"
	
	private static let ref = NotificationsManager()
	
	private var counter: UInt64 = 0
	private let cache: String = Bundle.main.bundleIdentifier! + "."
	
	class func sendWith(id: String, image: NSImage? = NSImage(named: "AppIcon")!) -> NSUserNotification!{
		if sharedIsOnRecovery{
			return nil
		}
		
		let notification = NSUserNotification()
		notification.identifier = ref.cache + id + String(ref.counter)
		
		ref.counter += 1
		
		notification.title = TextManager.getViewString(context: ref, stringID: id + "Title")!
		notification.informativeText = TextManager.getViewString(context: ref, stringID: id)!
		
		notification.soundName = NSUserNotificationDefaultSoundName
		
		notification.contentImage = image
		
		NSUserNotificationCenter.default.deliver(notification)
		
		return notification
	}
}

/*
extension AppDelegate: NSUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		return true
	}
}
*/
