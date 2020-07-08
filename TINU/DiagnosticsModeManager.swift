//
//  DiagnosticsModeManager.swift
//  TINU
//
//  Created by Pietro Caruso on 24/06/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import AppKit

public func openDiagnosticsMode(withSudo sudo: Bool){
	if !(CreateinstallmediaSmallManager.shared.sharedIsBusy || sharedIsOnRecovery){
		
		print("trying to use diagnostics mode")
		
		let resourceName = sudo ? "DebugScriptSudo" : "DebugScript"
		
		if let scriptPath = Bundle.main.url(forResource: resourceName, withExtension: "sh")?.path {
			
			var val: Int16 = 0x7fff;
			
			do{
				
				if let perm = (try FileManager.default.attributesOfItem(atPath: scriptPath)[FileAttributeKey.posixPermissions] as? NSNumber)?.int16Value{
					val = perm
				}
				
			}catch let err{
				print("impossible to determinate file permitions for diagnosticd mode script")
				print(err)
			}
			
			if val != 0o771{
				
				let theScript = "do shell script \"chmod -R 771 \'" + scriptPath + "\'\" with administrator privileges"
				
				print(theScript)
				
				let appleScript = NSAppleScript(source: theScript)
				
				if let eventResult = appleScript?.executeAndReturnError(nil){
					if let result = eventResult.stringValue{
						if result.isEmpty || result == "\n" || result == "Password:"{
							val = 0;
						}else{
							print("error with the script output: " + result)
							msgBoxWarning("Impossible to use diagnostics mode", "Something went wrong when preparing TINU to be run in diagnostics mode.\n\n[error code: 0]\n\nScript output: \(result)")
						}
					}
				}else{
					print("impossible to execute the apple script to prepare the app")
					
					msgBoxWarning("Impossible to use diagnostics mode", "Impossible to prepare TINU to run in diagnostics mode, try to moove the app to a different directory e.g. the Desktop.\n\n[error code: 1, apple script execution failed]")
				}
				
			}else{
				val = 0
			}
			
			if val == 0{
				NSWorkspace.shared().openFile(scriptPath, withApplication: "Terminal")
				NSApplication.shared().terminate(NSApp!)
			}
		}else{
			print("Disgnostics mode script \"\(resourceName).sh\" not found!")
			
			msgBoxWarning("Impossible to use diagnostics mode", "Needed files inside TINU are missing, so the diagnostics mode can't be used. Download this app again and then try again.")
		}
		
	}else{
		//the diagnostics mode button should be blocked at this point if the app is in a recovery or the app is performing a creation process
		if CreateinstallmediaSmallManager.shared.sharedIsBusy{
			msgBox("You can't switch mode now", "The bootable macOS installer creation process is currenly running. Please cancel the operation or wait for the operation to end before switching the mode.", .warning)
		}else if sharedIsOnRecovery{
			msgBoxWarning("You can't switch the mode right now", "Switching the mode in which TINU is running is not possible while running TINU from this recovery/installer system.")
		}
	}
}
