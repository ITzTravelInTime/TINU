//
//  PackagesWrapper.swift
//  TINU
//
//  Created by Pietro Caruso on 12/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation
import AppKit
import TINUNotifications
import TINURecovery
import SwiftCPUDetect
import SwiftLoggedPrint

public class Recovery: TINURecovery.Recovery{
	public override class var simulatedStatus: Bool?{
		return TINU.simulateRecovery
	}
}

public final class SIPManager: SIP, ViewID {
	
	public let id: String = "SIPManager"
	
	private static let ref = SIPManager()
	
	public override class var simulatedStatus: SIP.SIPStatus?{
		//TODO: Fix this
		return TINU.simulateSIPStatus != nil ? ( TINU.simulateSIPStatus! ? 0 : 0x7f ) : nil
	}
	
	public class func checkStatusAndLetTheUserKnow(){
		DispatchQueue.global(qos: .background).async {
			if !status.isOkForTINU && !CommandLine.arguments.contains("-disgnostics-mode"){
				//msgBoxWithCustomIcon("TINU: Please disable SIP", "SIP (system integrity protection) is enabled and will not allow TINU to complete successfully the installer creation process, please disable it or use the diagnostics mode with administrator privileges", .warning , IconsManager.shared.stopIcon)
				DispatchQueue.main.async {
					msgboxWithManager(ref, name: "disable", parseList: nil, style: NSAlert.Style.critical, icon: nil)
				}
			}
		}
	}

}

public extension SIP.SIPIntegerFormat{
	var isOkForTINU: Bool{
		let mask = SIPManager.SIPBits.CSR_ALLOW_UNRESTRICTED_FS.rawValue
		return (self & mask) == mask
	}
}

internal class LogManager: SwiftLoggedPrint.LoggedPrinter{
	override class var printerID: String{
		super.showPrefixesIntoLoggedLines = true
		super.logsDebugLines = false
		return Bundle.main.bundleIdentifier ?? "TINU"
	}
	
	static func clearLog(){
		super.clearLog()
		
		log(AppBanner.banner)
	}
}

public func log( _ log: String){
	LogManager.print("\(log)")
}

public func print( _ str: Any){
	LogManager.debug("\(str)")
}


public final class Notifications: ViewID{
	public let id: String = "NotificationsManager"
	
	private static let ref = Notifications()
	
	public class func make(id: String, icon: NSImage? = NSImage(named: "AppIcon")!) -> TINUNotifications.Notification{
		let title = TextManager.getViewString(context: ref, stringID: id + "Title")!
		let description = TextManager.getViewString(context: ref, stringID: id)!
		return TINUNotifications.Notification(id: id, message: title, description: description, icon: icon)
	}
	
	public class func sendWith(id: String, icon: NSImage? = NSImage(named: "AppIcon")!) -> NSUserNotification?{
		return make(id: id, icon: icon).send()
	}
	
	public class func justSendWith(id: String, icon: NSImage? = NSImage(named: "AppIcon")!){
		Notifications.make(id: id, icon: icon).justSend()
	}
}

public typealias Alert = TINUNotifications.Alert

public extension Alert{
	func warningWithIcon() -> Alert{
		var mycopy = warning()
		mycopy.icon = IconsManager.shared.warningIcon.normalImage()
		return mycopy
	}
	
	func criticalWithIcon() -> Alert{
		var mycopy = critical()
		mycopy.icon = IconsManager.shared.stopIcon.normalImage()
		return mycopy
	}
}
