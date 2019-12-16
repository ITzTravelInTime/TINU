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
	
	
	private var notification: NSUserNotification!
	
	@inline(__always) private func sendAuthNotification(){
		#if TINU
		if (CreateinstallmediaSmallManager.shared.sharedIsPreCreationInProgress || CreateinstallmediaSmallManager.shared.sharedIsCreationInProgress) && !sharedIsOnRecovery{
			
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
	
    //this is a singleton bitch
    static let shared = SudoManager()
	
	/*
    //this variable stores the password during the install media creation process, it's not the safest way to store it but i am using lots of meausres to keep it safe, this needs to be stored into a way that we can use in a command string like this: echo "myfancypassword" | sudo -S myfancycommand --myfancyargument
    private var pass: String!
    //this is function the gets the password that needs to be used in the scripts, do not make accessible in the outside this file/class
    private var text = ""
    private func askForPassword() -> String!{
		let username = NSUserName()
		
		if text.isEmpty{
			text = "TINU needs that you do the login again\n\nDo the login with the account: \(username)\n(Make sure that the password used with this account is not empty)\n\nPassword:"
		}
		
        //if we are into the recovery we do not need the password
        if sharedIsReallyOnRecovery{
            return ""
        }
		
        log("Asking for password")
        //asks for the password using a dialog window created with the apple script
        let p = getOut(cmd: "echo \"$(osascript -e 'Tell application \"System Events\" to display dialog \"" + text + "\" default answer \"\" with hidden answer' -e 'text returned of result' 2>/dev/null)\"")
        //if the user does press the cancel button on the dialog window the output is an empty string so we come back to the previuous window
        if p == "" || p == "\n"{
            //aborted
            log("Get password aborted")
            return nil
        }
        
        //the user typed a password, so we check it using the checkPassword function
        if !checkPassword(p){
            log("passord not correct")
            text = "The passowsrd entered is not correct, try again\n\nDo the login with the account: \(username)\n(Make sure that the password used with this account is not empty)\n\nPassword:"
            //if the password is not correct the function recursively calls his self to ask it again
            return askForPassword()
        }
		
        text = ""
        
        //eveything is ok and the password is returned
        return p
    }
    
    //this function checks a given password passed by argument, do not make accessible in the outside this file/class
    private func checkPassword(_ password: String!) -> Bool{
        if password == nil{
            return false
        }
        
        if password.isEmpty{
            return false
        }
        //we check if it's correct by trying to call sudo with that password and reading the output
        return !(getErr(cmd: "echo \"" + password + "\" | sudo -S echo \"correct\"").contains("Password:Sorry, try again."))
    }
    
    //this function uses the checkPassword function to determinate if the stored password is correct, do not make accessible in the outside this file/class
    private func checkPasswordStored() -> Bool{
        return checkPassword(pass)
    }
    
    //this function return the prefix to use when performing commands that needs sudo, do not make accessible in the outside this file/class
    private func getSudoPrefix() -> String!{
        var prefix = ""
        //checks if we are not on recovery, if yes, the command must use sudo
        if !sharedIsReallyOnRecovery{
            //just checks the password, for the sudo
            if !checkPasswordStored(){
                pass = askForPassword()
                if pass == nil{
                    return nil
                }
            }
            //puts the prefix in the sudo command
            prefix = "echo \"" + pass + "\" | sudo -S "
        }
        
        return prefix
    }
    
    private init(){
        
    }
    
    //used to erase the password when it's no longer needed
    fileprivate func erasePassword(){
        //just to be sure, it's not needed, we replace the characters in memory with charactes that should not be used in a password, to protect the data from boing stole from programs that reads from memory
        //this is just a test to verify if the memory address is the same
        /*
        withUnsafePointer(to: &pass) {
            print(" str value \(pass) has address: \($0)")
        }*/
        if pass != nil{
            let replaced = String(describing: pass.map {
                $0 == "\n"
            })
            pass = replaced
        }
        
        //this is the needed part
        pass = ""
        pass = nil
        
        /*withUnsafePointer(to: &pass) {
            print(" str value \(pass) has address: \($0)")
        }*/
    }
    
    //this functions executes commands using sudo, if needed, they are there becuse the functions that will use the password are fileprivate, this because we need to protect the password
    fileprivate func getErrWithSudo(cmd: String) -> String!{
        if let p = getSudoPrefix(){
            //ths function runs a command on the sh shell and it does return the error output
            return getErr(cmd: p + cmd)
        }else{
            return nil
        }
    }*/
    
    fileprivate func getOutWithSudo(cmd: String) -> String!{
		
		if sharedIsReallyOnRecovery{
			return getOut(cmd: cmd)
		}
		
        #if EFIPM
        
        let extra = " with administrator privileges"
        
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
			
			let extra = " with administrator privileges"
			
			let theScript = "do shell script \"echo $(\(ncmd))\"" + extra
			
			print(theScript)
			
			let appleScript = NSAppleScript(source: theScript)
			
			if let eventResult = appleScript?.executeAndReturnError(nil){
				retireAuthNotification()
				return eventResult.stringValue
			}else{
				retireAuthNotification()
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
		
        if sharedIsReallyOnRecovery{
            return runCommand(cmd: cmd, args: args)
        }
		
		sendAuthNotification()
		
        /*if let p = getSudoPrefix(){
            log("Password got with success")
            var arg = [String]()
            var isc = false
            for i in 0...args.count - 1{
                let a = args[i]
                if i == 0{
                    if a == "-c"{
                        isc = true
                        arg.append(a)
                    }else{
                        arg.append(p + a)
                    }
                }else if i == 1 && isc{
                    arg.append(p + a)
                }else{
                    arg.append(a)
                }
            }
            
            /*if sharedIsPreCreationInProgress{
             if let w = sharedWindow.contentViewController as? InstallingViewController{
             w.cancelButton.isEnabled = true
             
             if let ww = sharedWindow{
             //w.isMiniaturizeEnaled = false
             ww.isClosingEnabled = true
             //ww.canHide = false
             }
             }
             }*/
            
            return runCommand(cmd: cmd, args: arg)
        }else{
            return nil
        }*/
		
		var output : [String] = []
		var error : [String] = []
		var status = Int32()
		//runs a process object and then return the outputs
		
		if let p = startCommandWithSudo(cmd: cmd, args: args){
		
		p.process.waitUntilExit()
			
		retireAuthNotification()
		
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
    
    fileprivate func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
        if sharedIsReallyOnRecovery{
            return startCommand(cmd: cmd, args: args)
        }
		
		sendAuthNotification()
		
		//if simulateUseScriptAuth{
			return startCommandWithSecurity(cmd: cmd,args: args)
		//}
		
		
		
		/*
        if let p = getSudoPrefix(){
            log("Password got with success")
            var arg = [String]()
            var isc = false
            for i in 0...args.count - 1{
                let a = args[i]
                if i == 0{
                    if a == "-c"{
                        isc = true
                        arg.append(a)
                    }else{
                        arg.append(p + a)
                    }
                }else if i == 1 && isc{
                    arg.append(p + a)
                }else{
                    arg.append(a)
                }
            }
            
            
            /*if sharedIsPreCreationInProgress{
             if let w = sharedWindow.contentViewController as? InstallingViewController{
             w.cancelButton.isEnabled = true
             
             if let ww = sharedWindow{
             //w.isMiniaturizeEnaled = false
             ww.isClosingEnabled = true
             //ww.canHide = false
             }
             }
             }*/
			
			retireAuthNotification()
			
            return startCommand(cmd: cmd, args: arg)
        }else{
			retireAuthNotification()
			
            return nil
        }*/
        
    }
	
    fileprivate func startCommandWithSecurity(cmd : String, args: [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
		if sharedIsReallyOnRecovery{
			return startCommand(cmd: cmd, args: args)
		}
		
		sendAuthNotification()
		
		/*
        
        var ags = ["execute-with-privileges", cmd]
        
        ags.append(contentsOf: args)
		
		return startCommand(cmd: "/usr/bin/security", args: ags)
		*/
		
		var pcmd = ""
		
		for i in args[1]{
			if i == "\""{
				pcmd += "\'\"\'\"\'"
			}else{
				pcmd += String(i)
			}
		}
		
		pcmd += ""
		
		let baseCMD = "osascript -e \'do shell script \"\(pcmd)\" with administrator privileges\'"
		
		print(baseCMD)
		
		let start = startCommand(cmd: cmd, args: [args[0], baseCMD])
		
		retireAuthNotification()
		
		return start
	}
}

fileprivate var sm = SudoManager.shared

/*
//shared functions for sensible tasks
public func erasePassword(){
    sm.erasePassword()
}

public func getErrWithSudo(cmd: String) -> String!{
	return sm.getErrWithSudo(cmd: cmd)
}
*/

public func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
	return sm.startCommandWithSudo(cmd: cmd, args: args)
}

public func startCommandWithSecurity(cmd : String, args: [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
    return sm.startCommandWithSecurity(cmd : cmd, args: args)
}

public func getOutWithSudo(cmd: String) -> String!{
	return sm.getOutWithSudo(cmd: cmd)
}

public func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
	return sm.runCommandWithSudo(cmd: cmd, args: args)
}
