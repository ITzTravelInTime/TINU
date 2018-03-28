//
//  File.swift
//  TINU
//
//  Created by Pietro Caruso on 20/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

fileprivate final class SudoManager{
    //this is a singleton bitch
    static let shared = SudoManager()
    
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
            let replaced = String(describing: pass.characters.map {
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
    }
    
    fileprivate func getOutWithSudo(cmd: String) -> String!{
        if let p = getSudoPrefix(){
            //ths function runs a command on the sh shell and it does return the output
            return getOut(cmd: p + cmd)
        }else{
            return nil
        }
    }
    
    fileprivate func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
        if sharedIsReallyOnRecovery{
            return runCommand(cmd: cmd, args: args)
        }
        
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
            
            return runCommand(cmd: cmd, args: arg)
        }else{
            return nil
        }
        
    }
    
    fileprivate func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
        if sharedIsReallyOnRecovery{
            return startCommand(cmd: cmd, args: args)
        }
        
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
            return startCommand(cmd: cmd, args: arg)
        }else{
            return nil
        }
        
    }
	
	fileprivate func startCommandWithAScriptSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
		if sharedIsReallyOnRecovery{
			return startCommand(cmd: cmd, args: args)
		}
		
		
		var script = ""
		
		for cc in cmd.characters{
			let c = "\(cc)"
			if c == " " || c == "\""{
				script += "\\"
			}
			script += c
		}
		
		script += " "
		
		for ccc in args{
			for cc in ccc.characters{
				let c = "\(cc)"
				if c == " " || c == "\""{
					script += "\\"
				}
				script += c
			}
			script += " "
		}
		
		
		
		let cmdBase = "echo \"$(osascript -e 'do shell script \"\(script)\" with administrator privileges')\""
		
		print(cmdBase)
		
		return nil //startCommand(cmd: "/bin/sh",args:["-c", cmdBase])
	}
}

fileprivate var sm = SudoManager.shared
//shared functions for sensible tasks
public func erasePassword(){
    sm.erasePassword()
}


public func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
    return sm.startCommandWithSudo(cmd: cmd, args: args)
}

public func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
    return sm.runCommandWithSudo(cmd: cmd, args: args)
}

public func getOutWithSudo(cmd: String) -> String!{
    return sm.getOutWithSudo(cmd: cmd)
}

public func getErrWithSudo(cmd: String) -> String!{
    return sm.getErrWithSudo(cmd: cmd)
}

public func startCommandWithAScriptSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)!{
	return sm.startCommandWithAScriptSudo(cmd : cmd, args : args)
}
