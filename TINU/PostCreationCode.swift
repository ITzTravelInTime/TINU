//
//  PostCreationCode.swift
//  TINU
//
//  Created by ITzTravelInTime on 09/11/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//file replacement options
fileprivate func replaceMultipleItems(paths: [String], newItem: Data, nameWithExtension: String) -> Bool{
    let manager = FileManager.default
    
    if sharedVolume == nil{
        return false
    }
    
    log("   Trying to replace item \"" + nameWithExtension + "\"")
    
    var returnValue = true
    for p in paths{
        let path = URL.init(fileURLWithPath: sharedVolume + p + "/" + nameWithExtension, isDirectory: false)
        do{
            log("       Trying to replace in path \"" + p + "\"")
            
            var isDir : ObjCBool = false
            if !manager.fileExists(atPath: sharedVolume + p, isDirectory:&isDir) {
                log("       Item's directory do not exists, trying to create it")
                try manager.createDirectory(atPath: sharedVolume + p, withIntermediateDirectories: true, attributes: [:])
                log("       Item's directory created successfully")
            }
            
            
            if manager.fileExists(atPath: path.path){
                log("       Trying to remove the old item")
                try manager.removeItem(at: path)
                log("       Old item removed successfully")
            }
            
            try newItem.write(to: path, options: .atomic)
            
            log("       Replace in path \"" + p + "\" ended with sucess")
            
        }catch let error{
            log("       Item replace failed in path: \(p) \n            error details: \n               \(error)")
            returnValue = false
        }
    }
    
    return returnValue
}

public class ReplaceFileObject{
    var filename: String
    var paths: [String]
    var data: Data!
    
    var visible = true
    
    init() {
        filename = ""
        paths = []
        data = nil
    }
    
    init(name: String, possiblePaths: [String], contentData: Data!) {
        filename = name
        paths = possiblePaths
        data = contentData
    }
    
    init(name: String, possiblePaths: [String], contentData: Data!, isVisible: Bool) {
        filename = name
        paths = possiblePaths
        data = contentData

        visible = isVisible
    }
    
    init(name: String, possiblePaths: [String], isVisible: Bool){
        filename = name
        paths = possiblePaths
        
        data = nil
        
        visible = isVisible
    }
    
    public func replace() -> Bool{
        if data != nil && sharedVolume != nil{
            return replaceMultipleItems(paths: paths, newItem: data!, nameWithExtension: filename)
        }
        return true
    }
}

public func eraseReplacementFilesData(){
    //dealloc data we no longer need
    print("Erasing boot files replacement data")
    for f in filesToReplace{
        f.data = nil
    }
    print("Boot files replacement data erased")
}

//other options
public class OtherOptionsObject{
    var id: String
    var displayMessage: String
    var isActivated = false
    var isVisible = true
    
    var isUsable = true
	
	var description: String! = ""
    
    func canBeUsed(_ referenceID: String) -> Bool{
        return (id == referenceID) && isActivated && isVisible
    }
    
    func canBeUsed() -> Bool{
        return isActivated && isVisible
    }
    
    func copy() -> OtherOptionsObject{
		return OtherOptionsObject.init(objectID: id, objectMessage: displayMessage, objectDescription: description, objectIsActivated: isActivated, objectIsVisible: isVisible)
    }
    
    init(){
        id             = ""
        displayMessage = "This is an option"
		description    = "This is the description of this option"
    }
    
	init(objectID: String, objectMessage: String, objectDescription: String!) {
        id = objectID
        displayMessage = objectMessage
		description = objectDescription
    }
    
	init(objectID: String, objectMessage: String, objectDescription: String! ,objectIsActivated: Bool, objectIsVisible: Bool) {
        id = objectID
        displayMessage = objectMessage
        isActivated = objectIsActivated
        isVisible = objectIsVisible
		description = objectDescription
    }
}


