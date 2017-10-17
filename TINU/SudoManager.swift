//
//  File.swift
//  TINU
//
//  Created by Pietro Caruso on 20/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

fileprivate class SudoManager{
    //this variable stores the password, and yes, i agree with you, this is not a safe way to do that, but i can't ask the passowrd to the user a lot of times, if you have a better idea to store the passowrd contact me, i think that it vould be something like the keychain, just remember that the poassord has to be converted into a string format tha could be used with sudo in a command string
    fileprivate var pass: String!
    //this is function the gets the password that needs to be used in the scripts
    fileprivate var text = "TINU needs again the password (Your account must have a password that is not empty):"
    fileprivate func askForPassword() -> String!{
        //if we are into the recovery we do not need the password
        if sharedIsOnRecovery{
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
            text = "The password is not correct, enter it again (Your account must have a password that is not empty):"
            //if the password is not correct the function recursively calls his self to ask it again
            return askForPassword()
        }
        text = "TINU needs again the password (Your account must have a password that is not empty):"
        
        //eveything is ok and the password is returned
        return p
    }
    
    //this function checks a given password passed by argument
    fileprivate func checkPassword(_ password: String!) -> Bool{
        if password == nil{
            return false
        }
        
        if password.isEmpty{
            return false
        }
        //we check if it's correct by trying to call sudo with that password and reading the output
        return !(getErr(cmd: "echo \"" + password + "\" | sudo -S echo \"correct\"").contains("Password:Sorry, try again."))
    }
    
    //this function uses the checkPassword function to determinate if the stored password is correct
    fileprivate func checkPasswordStored() -> Bool{
        return checkPassword(pass)
    }
    
    //this function return the prefix to use when performing commands that needs sudo
    fileprivate func getSudoPrefix() -> String!{
        var prefix = ""
        //checks if we are not on recovery, if yes, the command must use sudo
        if !sharedIsOnRecovery{
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
    
    //used to erase the password when it's no longer needed
    fileprivate func erasePassword(){
        pass = nil
    }
}

fileprivate var sm = SudoManager()
//shared functions for sensible tasks
public func erasePassword(){
    sm.erasePassword()
    //not necessary, but it's done just to for safety
    sm = SudoManager()
}

//this functions executes commands using sudo, if needed, they are there becuse the functions that will use the password are fileprivate, this because we need to protect the password
public func getErrWithSudo(cmd: String) -> String!{
    if let p = sm.getSudoPrefix(){
        //ths function runs a command on the sh shell and it does return the error output
        return getErr(cmd: p + cmd)
    }else{
        return nil
    }
}

public func getOutWithSudo(cmd: String) -> String!{
    if let p = sm.getSudoPrefix(){
        //ths function runs a command on the sh shell and it does return the output
        return getOut(cmd: p + cmd)
    }else{
        return nil
    }
}

public func runCommandWithSudo(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32)! {
    if sharedIsOnRecovery{
        return runCommand(cmd: cmd, args: args)
    }
    
    if let p = sm.getSudoPrefix(){
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

public func startCommandWithSudo(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe)! {
    if sharedIsOnRecovery{
        return startCommand(cmd: cmd, args: args)
    }
    
    if let p = sm.getSudoPrefix(){
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
