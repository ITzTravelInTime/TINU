//
//  ScriptsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 20/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

//this function stars a process and then returs the objects needed to track it
public func startCommand(cmd : String, args : [String]) -> (process: Process, errorPipe: Pipe, outputPipe: Pipe) {
    let task = Process()
    let outpipe = Pipe()
    let errpipe = Pipe()
    
    //stars a process object and then return the outputs
    task.launchPath = cmd
    task.arguments = args
    task.standardOutput = outpipe
    task.standardError = errpipe
    task.launch()
    
    return (task, errpipe, outpipe)
}

//runs a process until it ends and then returs the outputs and the erros
public func runCommand(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32) {
    var output : [String] = []
    var error : [String] = []
    var status = Int32()
    //runs a process object and then return the outputs
    
    let p = startCommand(cmd: cmd, args: args)
    
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
}

//executes a process until it ends end then returns only the output/error
fileprivate func getOutSimply(cmd: String, isErr: Bool) -> String{
    //ths function runs a command on the sh shell and it does return the output or the error produced

    var ret = [String]()
    
    if isErr{
        ret = runCommand(cmd: "/bin/sh", args: ["-c", cmd]).error
    }else{
        ret = runCommand(cmd: "/bin/sh", args: ["-c", cmd]).output
    }
    
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
public func getErr(cmd: String) -> String{
    //ths function runs a command on the sh shell and it does return the error output
    return getOutSimply(cmd: cmd, isErr: true)
}

public func getOut(cmd: String) -> String{
    //ths function runs a command on the sh shell and it does return the output
    return getOutSimply(cmd: cmd, isErr: false)
}
