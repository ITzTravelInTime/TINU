//
//  File.swift
//  TINU
//
//  Created by Pietro Caruso on 20/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

#if TINU

import Cocoa

#endif

extension Command{
	
	class Sudo{
		
		private static let extra = " with administrator privileges"
		
		private static var notification: NSUserNotification!
		
		private class func sendAuthNotification(){
			#if TINU
			if (cvm.shared.process.status.isBusy()){
				/*
				notification = NSUserNotification()
				
				notification.title = "TINU: Please log in"
				notification.informativeText = "To complete the creation process of your bootable macOS installer TINU needs that you do the login"
				notification.contentImage = NSImage(named: "AppIcon")
				
				/*
				notification.hasActionButton = true
				notification.actionButtonTitle = "Close"
				*/
				
				notification.soundName = NSUserNotificationDefaultSoundName
				NSUserNotificationCenter.default.deliver(notification)
				*/
				
				retireAuthNotification()
				Command.Sudo.notification = nil
				Command.Sudo.notification = NotificationsManager.sendWith(id: "login", image: nil)
			}
			#endif
		}
		
		private class func retireAuthNotification(){
			#if TINU
			if let noti = Command.Sudo.notification{
				NSUserNotificationCenter.default.removeDeliveredNotification(noti)
			}
			#endif
		}
		
		class func getOut(cmd: String) -> String!{
			
			if User.isRoot{
				return Command.getOut(cmd: cmd)
			}
			
			//TODO: Maybe unify the 2 codes
			#if EFIPM
			
			let theScript = "do shell script \"echo $(\(cmd))\"" + extra
			let appleScript = NSAppleScript(source: theScript)
			
			if let eventResult = appleScript?.executeAndReturnError(nil){
				return eventResult.stringValue
			}else{
				return nil
			}
			
			#else
			
			sendAuthNotification()
			
			//if simulateUseScriptAuth{
			var ncmd = ""
			
			for c in cmd{
				if String(c) == "\""{
					ncmd.append("\'")
				}else{
					ncmd.append(c)
				}
			}
			
			let theScript = "do shell script \"echo $(\(ncmd))\"" + Sudo.extra
			
			print(theScript)
			
			let appleScript = NSAppleScript(source: theScript)
			
			let result = appleScript?.executeAndReturnError(nil)
			
			retireAuthNotification()
			
			if let eventResult = result{
				return eventResult.stringValue
			}else{
				return nil
			}
			#endif
		}
		
		class func run(cmd : String, args : [String]) -> Result! {
			guard let handle = start(cmd: cmd, args: args) else { return nil }
			return result(from: handle)
		}
		
		class func start(cmd : String, args: [String]) -> Handle!{
			if User.isRoot {
				return Command.start(cmd: cmd, args: args)
			}
			
			sendAuthNotification()
			
			var pcmd = "sudo "
			
			for i in args[1]{
				if i == "\""{
					pcmd += "\'\"\'\"\'"
				}else{
					pcmd += String(i)
				}
			}
			
			pcmd += ""
			
			let baseCMD = "osascript -e \'do shell script \"\(pcmd)\"\(Sudo.extra)\'"
			
			print(baseCMD)
			
			let start = Command.start(cmd: cmd, args: [args[0], baseCMD])
			
			retireAuthNotification()
			
			return start
		}
	}
	
}
