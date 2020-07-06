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

fileprivate final class SudoManager{
	
	fileprivate let extra = " with administrator privileges"
	
	private var notification: NSUserNotification!
	
	//this is just a singleton, nothing of interesting to see
	static let shared = SudoManager()
	
	private func sendAuthNotification(){
		#if TINU
		if (CreateinstallmediaSmallManager.shared.sharedIsBusy) && !sharedIsOnRecovery{
			
			notification = NSUserNotification()
			
			notification.title = "TINU: Please log in"
			notification.informativeText = "To complete the creation process of your bootable macOS installer TINU needs that you do the login"
			notification.contentImage = NSImage(named: "AppIcon")
			
			notification.hasActionButton = true
			
			notification.actionButtonTitle = "Close"
			
			notification.soundName = NSUserNotificationDefaultSoundName
			NSUserNotificationCenter.default.deliver(notification)
			
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
    
    fileprivate func getOutWithSudo(cmd: String) -> String!{
		
		if isRootUser{
			return getOut(cmd: cmd)
		}
		
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
			
			let theScript = "do shell script \"echo $(\(ncmd))\"" + extra
			
			print(theScript)
			
			let appleScript = NSAppleScript(source: theScript)
		
		
			let result = appleScript?.executeAndReturnError(nil)
		
			retireAuthNotification()
		
			if let eventResult = result{
				return eventResult.stringValue
			}else{
				return nil
			}
		/*}else{
		
        	if let p = getSudoPrefix(){
            	//ths function runs a command on the sh shell and it does return the output
				retireAuthNotification()
            	return getOut(cmd: p + cmd)
        	}else{
				retireAuthNotification()
            	return nil
        	}
		
		}*/
		
		
        
        #endif
    }
    
    fileprivate func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
		
		var output : [String] = []
		var error : [String] = []
		var status = Int32()
		//runs a process object and then return the outputs
		
		if let p = startCommandWithSecurity(cmd: cmd,args: args){
		
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
	
    fileprivate func startCommandWithSecurity(cmd : String, args: [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
		if isRootUser {
			return startCommand(cmd: cmd, args: args)
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
		
		let baseCMD = "osascript -e \'do shell script \"\(pcmd)\"\(extra)\'"
		
		print(baseCMD)
		
		let start = startCommand(cmd: cmd, args: [args[0], baseCMD])
		
		retireAuthNotification()
		
		return start
	}
}

fileprivate var sm = SudoManager.shared

public func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
	return sm.startCommandWithSecurity(cmd: cmd,args: args)
}

public func getOutWithSudo(cmd: String) -> String!{
	return sm.getOutWithSudo(cmd: cmd)
}

public func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
	return sm.runCommandWithSudo(cmd: cmd, args: args)
}
