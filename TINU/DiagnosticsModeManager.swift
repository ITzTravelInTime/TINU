//
//  DiagnosticsModeManager.swift
//  TINU
//
//  Created by Pietro Caruso on 24/06/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import AppKit

fileprivate func getDiagnosticsModecontent(sudo: Bool = true) -> String{
	var str = "echo \"Opening \(Bundle.main.name!) in log mode"
	
	if sudo{
		str += " with administrator privileges"
	}
		
	str += "\"\n"
	
	if sudo{
		str += "sudo "
	}
	
	str += "\"" + Bundle.main.executablePath! + "\""
	
	return str
}

fileprivate	func getDiagnosticsModeFileLocation(sudo: Bool) -> String!{
	let resourceName = "/" + (sudo ? "DebugScriptSudo" : "DebugScript") + ".command"
	
	return getAppSupportDirectory(create: true, subFolderName: "DiagnosticsMode") + resourceName
}

public func getAppSupportDirectory(create: Bool = true, subFolderName: String! = nil) -> String!{
	let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
	if paths.count > 0{
		if let start = paths.first?.path{
			if let folderName = Bundle.main.bundleIdentifier{
				let directory = start + "/" + folderName + ((subFolderName != nil) ? ("/" + subFolderName!) : "")
				if !FileManager.default.fileExists(atPath: directory){
					do {
					try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: [:])
						
					}catch let err{
						print(err.localizedDescription)
						return nil
					}
				}
				
				return directory
			}
		}
	}
	return nil
}

public func openDiagnosticsMode(withSudo sudo: Bool){
	
	if !(CreateinstallmediaSmallManager.shared.sharedIsBusy || sharedIsOnRecovery){
		
		print("trying to use diagnostics mode")
		
		//let resourceName = sudo ? "DebugScriptSudo" : "DebugScript"
		
		//if let scriptPath = Bundle.main.url(forResource: resourceName, withExtension: "sh")?.path {
		
		if let scriptPath = getDiagnosticsModeFileLocation(sudo: sudo){
			
			let expectedContent = getDiagnosticsModecontent(sudo: sudo)
			
			if !FileManager.default.fileExists(atPath: scriptPath){
				do{
					let content = expectedContent
					try content.write(toFile: scriptPath, atomically: true, encoding: .utf8)
				}catch let err{
					msgBoxWarning("Impossible to use diagnostics mode", "Impossible to create the script file needed to run TINU in diagnostics mode, make sure the app has read access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)")
					return
				}
			}else{
				do{
					let content = try String.init(contentsOfFile: scriptPath)
					
					if content != expectedContent{
						try FileManager.default.removeItem(atPath: scriptPath)
						
						return openDiagnosticsMode(withSudo: sudo)
					}
					
				}catch let err{
					msgBoxWarning("Impossible to use diagnostics mode", "Impossible to read or modify the content of the script file needed to run TINU in diagnostics mode, make sure the app has read and write access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)")
					return
				}
			}
			
			var val: Int16 = 0x7fff;
			
			do{
				
				if let perm = (try FileManager.default.attributesOfItem(atPath: scriptPath)[FileAttributeKey.posixPermissions] as? NSNumber)?.int16Value{
					val = perm
				}
				
			}catch let err{
				print("impossible to determinate file permitions for diagnosticd mode script")
				print(err)
				return
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
							msgBoxWarning("Impossible to use diagnostics mode", "Something went wrong when preparing the script file for diagnostics mode.\n\n[error code: 0]\n\nScript output: \(result)")
							return
						}
					}
				}else{
					print("impossible to execute the apple script to prepare the app")
					
					msgBoxWarning("Impossible to use diagnostics mode", "Impossible to prepare the script file for diagnostics mode, make sure tha app has write access to the ~/Library/Application Support folder.\n\n[error code: 1, apple script execution failed]")
					return
				}
				
			}else{
				val = 0
			}
			
			if val == 0{
				NSWorkspace.shared().openFile(scriptPath, withApplication: "Terminal")
				NSApplication.shared().terminate(NSApp!)
			}
		}else{
			print("Disgnostics mode script not found!")
			
			msgBoxWarning("Impossible to use diagnostics mode", "Needed files can't be created, so the diagnostics mode can't be used. Make sure the app has write access to the ~/Library/Application Support folder")
			return
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
