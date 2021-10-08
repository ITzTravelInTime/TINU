/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

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

import AppKit

final class DiagnosticsModeManager{
	
	static let shared = DiagnosticsModeManager()
	private var appName: String{
		return "\(Bundle.main.name ?? "the program")"
	}
	
	private func getFolder() -> String!{
		return App.getApplicationSupportDirectory(create: true, subFolderName: "DiagnosticsMode")
	}
	
	private	func getFileLocation(sudo: Bool) -> String!{
		let resourceName = "/DebugScript" + (sudo ? "Sudo" : "") + ".command"
		
		return getFolder() + resourceName
	}
	
	private func getScriptContent(sudo: Bool = true) -> String{
		var str = "echo \"Opening \(appName) in log mode"
		
		if sudo{
			str += " with administrator privileges\"\necho \"Please enter your admin/user passowrd: "
		}
		
		str += "\"\n"
		
		if sudo{
			str += "sudo "
		}
		
		str += "\"" + Bundle.main.executablePath! + "\" -disgnostics-mode > \"" + getFolder() + "/DebugLog.txt\""
		
		return str
	}
	
	public func open(withSudo sudo: Bool){
		
		#if TINU
		//the diagnostics mode button should be blocked at this point if the app is in a recovery or the app is performing a creation process
		//TODO: Maybe localize this
		if cvm.shared.process.status.isBusy(){
			Alert(message: "You can't switch mode now", description: "The bootable macOS installer creation process is currenly running. Please cancel the operation or wait for the operation to end before switching the mode.").warningWithIcon().justSend()
			//msgBoxWarning("You can't switch mode now", "The bootable macOS installer creation process is currenly running. Please cancel the operation or wait for the operation to end before switching the mode.")
		}else if Recovery.status{
			//msgBoxWarning("You can't switch the mode right now", "Switching the mode in which \(appName) is running is not possible while running \(appName) from this recovery/installer system.")
			Alert(message: "You can't switch the mode right now", description: "Switching the mode in which \(appName) is running is not possible while running \(appName) from this recovery/installer system.").warningWithIcon().justSend()
		}
		
		if (cvm.shared.process.status.isBusy() || Recovery.status){
			return
		}
		#endif
		
		print("trying to use diagnostics mode")
		
		//let resourceName = sudo ? "DebugScriptSudo" : "DebugScript"
		
		//if let scriptPath = Bundle.main.url(forResource: resourceName, withExtension: "sh")?.path {
		
		guard let scriptPath = getFileLocation(sudo: sudo) else {
			print("Disgnostics mode script not found!")
			
			//msgBoxWarning("Impossible to use diagnostics mode", "Needed files can't be created, so the diagnostics mode can't be used. Make sure the app has write access to the ~/Library/Application Support folder")
			
			Alert(message: "Impossible to use diagnostics mode", description: "Needed files can't be created, so the diagnostics mode can't be used. Make sure the app has write access to the ~/Library/Application Support folder").warningWithIcon().justSend()
			return
		}
		
		let expectedContent = getScriptContent(sudo: sudo)
		
		if !FileManager.default.fileExists(atPath: scriptPath){
			do{
				let content = expectedContent
				try content.write(toFile: scriptPath, atomically: true, encoding: .utf8)
			}catch let err{
				//msgBoxWarning("Impossible to use diagnostics mode", "Impossible to create the script file needed to run TINU in diagnostics mode, make sure the app has read access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)")
				Alert(message: "Impossible to use diagnostics mode", description: "Impossible to create the script file needed to run \(appName) in diagnostics mode, make sure the app has read access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)").warningWithIcon().justSend()
				return
			}
		}else{
			do{
				let content = try String.init(contentsOfFile: scriptPath)
				
				if content != expectedContent{
					try FileManager.default.removeItem(atPath: scriptPath)
					
					return open(withSudo: sudo)
				}
				
			}catch let err{
				//msgBoxWarning("Impossible to use diagnostics mode", "Impossible to read or modify the content of the script file needed to run \(appName) in diagnostics mode, make sure the app has read and write access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)")
				Alert(message: "Impossible to use diagnostics mode", description: "Impossible to read or modify the content of the script file needed to run \(appName) in diagnostics mode, make sure the app has read and write access to the ~/Library/Application Support folder\n\n\nError info \(err.localizedDescription)").criticalWithIcon().justSend()
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
						//msgBoxWarning("Impossible to use diagnostics mode", "Something went wrong when preparing the script file for diagnostics mode.\n\n[error code: 0]\n\nScript output: \(result)")
						Alert(message: "Impossible to use diagnostics mode", description: "Something went wrong when preparing the script file for diagnostics mode.\n\n[error code: 0]\n\nScript output: \(result)").criticalWithIcon().justSend()
						return
					}
				}
			}else{
				print("impossible to execute the apple script to prepare the app")
				
				//msgBoxWarning("Impossible to use diagnostics mode", "Impossible to prepare the script file for diagnostics mode, make sure tha app has write access to the ~/Library/Application Support folder.\n\n[error code: 1, apple script execution failed]")
				Alert(message: "Impossible to use diagnostics mode", description: "Impossible to prepare the script file for diagnostics mode, make sure tha app has write access to the ~/Library/Application Support folder.\n\n[error code: 1, apple script execution failed]").criticalWithIcon().justSend()
				return
			}
			
		}else{
			val = 0
		}
		
		if val == 0{
			NSWorkspace.shared.openFile(scriptPath, withApplication: "Terminal")
			NSApplication.shared.terminate(NSApp!)
		}
		
	}
	
	
	
}
