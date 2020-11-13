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
	
	private static var prevIDs: [String: (Date, String)] = [:]
	
	private static var timer: Timer!
	
	class func sendWith(id: String, image: NSImage? = NSImage(named: "AppIcon")!) -> NSUserNotification!{
		
		if sharedIsOnRecovery{
			Swift.print("Recovery mode is active, returning nil for notification send")
			return nil
		}
		
		let notification = NSUserNotification()
		
		
		
		if prevIDs.keys.contains(id){
			notification.identifier = ref.cache + id + String(ref.counter)
			
			prevIDs[id] = (Date(), notification.identifier!)
			
			ref.counter += 1
			
			if timer == nil{
				timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NotificationsManager.timer(_:)), userInfo: nil, repeats: true)
			}
		}else{
			notification.identifier = prevIDs[id]?.1
		}
		
		notification.title = TextManager.getViewString(context: ref, stringID: id + "Title")!
		notification.informativeText = TextManager.getViewString(context: ref, stringID: id)!
		
		notification.soundName = NSUserNotificationDefaultSoundName
		
		notification.contentImage = image
		
		NSUserNotificationCenter.default.deliver(notification)
		
		return notification
	}
	
	@objc func timer(_ sender: Any){
		Swift.print("Notifications timer schedules")
		for i in NotificationsManager.prevIDs{
			let minutes = (Int(i.value.0.timeIntervalSinceNow) / 60) % 60
			if minutes >= 2{
				NotificationsManager.prevIDs[i.key] = nil
			}
		}
	}
}

/*
extension AppDelegate: NSUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		return true
	}
}
*/
