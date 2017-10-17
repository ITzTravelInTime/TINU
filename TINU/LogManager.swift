//
//  LogManager.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation

fileprivate var logs = [String]()
fileprivate var hasBeenUpdated = false

public func log(_ log: String){
    print(log)
    logs.append(log)
    
    hasBeenUpdated = true
}

public func readLog() -> String!{
    if !hasBeenUpdated{
        return nil
    }else{
        var ret = ""
        for i in logs{
            ret += i + "\n"
        }
        hasBeenUpdated = false
        return ret
    }
}

public func readLatestLog() -> String!{
    if !logs.isEmpty{
        return logs.last
    }
    return nil
}

public func clearLog(){
    logs = []
    hasBeenUpdated = false
    if let lw = logWindow{
        if (lw.window?.isVisible)!{
            hasBeenUpdated = true
        }
    }
}

var logWindow: LogWindowController!
