//
//  CommandsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 20/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

public final class Command{
	
	struct Handle {
		let process: Process
		let outputPipe: Pipe
		let errorPipe: Pipe
	}
	
	struct Result {
		let exitCode: Int32
		let output: [String]
		let error: [String]
	}
	
	//this function stars a process and then returs the objects needed to track it
	class func start(cmd : String, args : [String]) -> Handle {
		let task = Process()
		let outpipe = Pipe()
		let errpipe = Pipe()
		
		//stars a process object and then return the outputs
		task.launchPath = cmd
		task.arguments = args
		task.standardOutput = outpipe
		task.standardError = errpipe
		task.launch()
		
		return Handle(process: task, outputPipe: outpipe, errorPipe: errpipe)
	}
	
	//extracts the poutput form a process handle
	class func result(from handle: Handle) -> Result{
		var output : [String] = []
		var error : [String] = []
		var status = Int32()
		//runs a process object and then return the outputs
		
		let p = handle
		
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
		
		return Result(exitCode: status, output: output, error: error)//(output, error, status)
	}
	
	//runs a process until it ends and then returs the outputs and the erros
	class func run(cmd : String, args : [String]) -> Result {
		return result(from: start(cmd: cmd, args: args))
	}
	
	//executes a process until it ends end then returns only the output/error
	private class func getOutSimply(cmd: String, isErr: Bool) -> String{
		//ths function runs a command on the sh shell and it does return the output or the error produced
		
		let res = run(cmd: "/bin/sh", args: ["-c", cmd])
		
		let ret = isErr ? res.error : res.output
		
		var rett = ""
		
		for r in ret{
			rett += r + "\n"
		}
		
		if !rett.isEmpty{
			rett.removeLast()
		}
		
		return rett
	}
	
	//specialized versions of the previous version:
	class func getErr(cmd: String) -> String{
		//ths function runs a command on the sh shell and it does return the error output
		return getOutSimply(cmd: cmd, isErr: true)
	}
	
	class func getOut(cmd: String) -> String{
		//ths function runs a command on the sh shell and it does return the output
		return getOutSimply(cmd: cmd, isErr: false)
	}
	
}
