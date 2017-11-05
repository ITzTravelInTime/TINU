//
//  LogManager.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

//this code manages the log system and the log window
fileprivate var logs = [String]()
fileprivate var hasBeenUpdated = false

//function you need to call if you want to log something
public func log(_ log: Any){
    print(log)
    logs.append("\(log)")
    
    hasBeenUpdated = true
}

//returs the whole log, if you do not have alreay read it, it's better to not use it
public func readLog() -> String!{
    if !hasBeenUpdated{
        return nil
    }else{
        return readAllLog()
    }
}

//returs the whole log, but it will always return the log
public func readAllLog() -> String{
        var ret = ""
        for i in logs{
            ret += i + "\n"
        }
        hasBeenUpdated = false
        return ret
}

//returns the latest log line
public func readAllLatestLog() -> String!{
    return logs.last
}


//returs the latest log line only if you don't have alreay read it, it's better to not use it because it's used by the log window thaty will not work without
public func readLatestLog() -> String!{
    if !logs.isEmpty{
        return readAllLatestLog()
    }
    return nil
}

//resets the initial state of the log control
public func clearLog(){
    logs = []
    hasBeenUpdated = false
    if let lw = logWindow{
        if (lw.window?.isVisible)!{
            hasBeenUpdated = true
        }
    }
}
