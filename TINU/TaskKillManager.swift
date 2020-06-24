//
//  TaskKillManager.swift
//  TINU
//
//  Created by Pietro Caruso on 16/04/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Cocoa

public final class TaskKillManager{
	
	private class func checkPid(pid: inout String?, name: String) -> Bool!{
		
		log("""
			Checking PID for process \"\(name)\":
				Provveded PID: \((pid != nil ? pid! : "Nil"))
			""")
		
		var recalculate = true
		
		var cpid = pid
		
		var maxCicles = 10
		
		while recalculate {
			switch cpid{
			case nil:
				log("Provvided PID for \"\(name)\" is nil")
			case "":
				log("Provvided PID for \"\(name)\" is empty")
			default:
				break
			}
			
			if let num = cpid?.unsignedNumber{
				switch num{
				case ..<10:
					log("Provvided PID for \"\(name)\" is form a system process, so it can't be stopped, exiting ...")
					return nil
				default:
					recalculate = false
				}
			}else{
				log("Provvided PID for \"\(name)\" is not a valid integer")
			}
			
			
			if recalculate {
				
				log("Provvided PID for \"\(name)\" is not usable")
				
				if maxCicles > 0{
					maxCicles -= 1
				}else{
					log("Can't get a valid PID for process \"" + name + "\"")
					return true
				}
				
				log("Recalculating provvided PID for \"\(name)\" ...")
				if let npid = getPid(name: name){
					cpid = npid
					log("Provvided PID for \"\(name)\" recalculated and changed to \"\(cpid!)\"")
				}else{
					log("Process \"" + name + "\" is not in execution")
					return nil
				}
				
			}else{
				log("Provvided PID for \"\(name)\" is correct")
				pid = cpid
			}
		}
		
		return recalculate
	}
	
	/**Terminates a process using it's name and pid.
	
	Returns:
	-True  - if the process has been killed successfully or if it is not in execution
	-False - if the process has not been killed successfully
	-nil   - if the authentication to kill the process has not been gives*/
	class func terminateProcessPidCheck(pid: String!, name: String) -> Bool!{
		
		var npid = pid
		
		var recalculate = true
		
		if let checkResult = checkPid(pid: &npid, name: name){
			recalculate = checkResult
		}else{
			return true
		}
		
		if !recalculate{
			return terminateProcess(PID: Int32(npid!)!)
		}
		
		log("The Pid has not been determinated with success")
		return false
		
	}
	
	class func terminateProcess(PID pid: Int32) -> Bool!{
		
		
			if let res = runCommandWithSudo(cmd: "/bin/sh", args: ["-c", "kill \(pid)"]){
				
				if res.exitCode != 0{
					log("Failed to close \"\(pid)\" because the closing process has exited with a code that is not 0: \n     exit code: \(res.exitCode)\n    output: \(res.output)\n     error/s produced: \(res.error)")
					return false
				}
				
				if let f = res.output.first{
					if (f.isEmpty || f == "Password:" || f == "\n"){
						log("Process \"\(pid)\" stopped with success")
						return true
					}else{
						log("Failed to close \"\(pid)\": \n     exit code: \(res.exitCode)\n    output: \(res.output)\n     error/s produced: \(res.error)")
						return false
					}
				}else{
					log("Failed to close \"\(pid)\" because is not possible to get the output of the termination process")
					return false
				}
			}else{
				log("Failed to close \"\(pid)\" because of an authentication failure")
				return nil
			}
		
	}
	
	private class func getPid(name: String) -> String!{
		let pid = getOut(cmd:"ps -Ac -o pid,comm | awk '/^ *[0-9]+ " + name + "$/ {print $1}'")
		
		if pid.isEmpty{
			return nil
		}else{
			return pid
		}
	}
	
	@inline(__always) class func terminateProcess(name: String) -> Bool!{
		
		return terminateProcessPidCheck(pid: nil, name: name)
		
	}
	
	class func terminateProcessWithAsk(name: String) -> Bool!{
		
		if let pid = self.getPid(name: name){
			
			var answer = false
			
			DispatchQueue.main.sync {
				
				#if TINU
				if name == "createinstallmedia"{
					answer = !dialogYesNoWarning(question: "Quit the other isntaller creation?", text: "TINU needs to close the installer creation which is currently running in order to continue, do you want to close it?\n\nIf yes, you will need to enter your credentials")
				}else{
					answer = !dialogYesNoWarning(question: "Close \"\(name)\"?", text: "TINU needs to close \"\(name)\" in order to continue, do you want to close it?\n\nIf yes, you will need to enter your credentials")
				}
				#else
					answer = !dialogYesNoWarning(question: "Close \"\(name)\"?", text: Bundle.main.name! + " needs to close \"\(name)\" in order to continue, do you want to close it?\n\nIf yes, you will need to enter your credentials")
				#endif
			}
			
			return answer ? terminateProcessPidCheck(pid: pid, name: name) : nil
			
		}
		
		return true
		
	}
	
	class func terminateAppWithAsk(byFileName name: String) -> Bool!{
		var err: String?
		let res = terminateAppsWithAsk(byCommonParameter: [name], parameterKind: .executableName , mustBeEqual: true, firstFailedToCloseName: &err)
		log("Failed to close program: \(err!)\n      (preset: single, executableName, equal)")
		return res
	}
	
	class func terminateAppWithAsk(byAppPath path: String) -> Bool!{
		var err: String?
		let res = terminateAppsWithAsk(byCommonParameter: [path], parameterKind: .executablePath , mustBeEqual: true, firstFailedToCloseName: &err)
		log("Failed to close program: \(err!)\n      (preset: single, executablePath, equal)")
		return res
	}
	
	public enum ParameterKind{
		case bundleIdentifier
		case executablePath
		case executableName
		case pidString
		case localizedName
	}
	
	class func terminateAppsWithAsk(byCommonParameter ids: [String], parameterKind pk: ParameterKind, mustBeEqual eq: Bool, firstFailedToCloseName ff: inout String?) -> Bool!{
		for info in NSWorkspace.shared().runningApplications{
			var par: String!
			
			switch pk{
			case .bundleIdentifier:
				par = info.bundleIdentifier
			case .executablePath:
				par = info.executableURL?.absoluteString
			case .executableName:
				par = info.executableURL?.lastPathComponent
			case .pidString:
				par = "\(info.processIdentifier)"
			case .localizedName:
				par = info.localizedName!
			}
			
			if let bid = par{
				for id in ids{
					if eq ? bid == id : bid.contains(id) {
						var answer = false
						
						var name = ""
						
						if let ln = info.localizedName{
							name = ln
						}else if let en = info.executableURL?.lastPathComponent{
							name = en
						}else{
							name = "\(info.processIdentifier)"
						}
						
						DispatchQueue.main.sync {
							answer = !dialogYesNoWarning(question: "Do you want to close \"\(name)\"?", text: Bundle.main.name! + " needs to close \"\(name)\" in order to continue, do you want to close it?")
						}
						
						ff = name
						
						if answer{
							
							if !info.forceTerminate(){
								return false
							}
							
						}else{
							return nil
						}
					}
				}
			}
		}
		
		ff = nil
		return true
	}
	
}
