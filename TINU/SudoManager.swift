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

extension CommandsManager{
	
	final class SudoManager{
		
		private static let extra = " with administrator privileges"
		
		private var notification: NSUserNotification!
		
		//this is just a singleton, nothing of interesting to see
		static let shared = SudoManager()
		
		private func sendAuthNotification(){
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
				notification = nil
				notification = NotificationsManager.sendWith(id: "login", image: nil)
			}
			#endif
		}
		
		@inline(__always) private func retireAuthNotification(){
			#if TINU
			if let noti = notification{
				NSUserNotificationCenter.default.removeDeliveredNotification(noti)
			}
			#endif
		}
		
		func getOut(cmd: String) -> String!{
			
			if isRootUser{
				return CommandsManager.getOut(cmd: cmd)
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
			
			let theScript = "do shell script \"echo $(\(ncmd))\"" + SudoManager.extra
			
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
		
		func run(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
			
			var output : [String] = []
			var error : [String] = []
			var status = Int32()
			//runs a process object and then return the outputs
			
			if let p = start(cmd: cmd,args: args){
				
				p.process.waitUntilExit()
				
				let outdata = p.outputPipe.fileHandleForReading.readDataToEndOfFile()
				if var string = String(data: outdata, encoding: .utf8) {
					string = string.trimmingCharacters(in: .newlines)
					output = string.components(separatedBy: "\n")
				}
				
				let errdata = p.errorPipe.fileHandleForReading.readDataToEndOfFile()
				if var string = String(data: errdata, encoding: .utf8) {
					string = string.trimmingCharacters(in: .newlines)
					error = string.components(separatedBy: "\n")
				}
				
				status = p.process.terminationStatus
				
				return (output, error, status)
			}else{
				return nil
			}
			
		}
		
		func start(cmd : String, args: [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
			if isRootUser {
				return CommandsManager.start(cmd: cmd, args: args)
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
			
			let baseCMD = "osascript -e \'do shell script \"\(pcmd)\"\(SudoManager.extra)\'"
			
			print(baseCMD)
			
			let start = CommandsManager.start(cmd: cmd, args: [args[0], baseCMD])
			
			retireAuthNotification()
			
			return start
		}
	}
	
}
