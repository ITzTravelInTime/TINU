//
//  Part.swift
//  TINU
//
//  Created by Pietro Caruso on 05/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//this is just a simple class that represents a drive, used fot the drive scan algoritm
public class Part{
	
	public enum FileSystem{
		case blank
		case other
		case hFS
		case aPFS
		case aPFS_container
		case coreStorage_container
	}
	
	public enum PartScheme{
		case blank
		case gUID
		case mBR
		case aPPLE
	}
	
    var bsdName: String!
    var apfsBDSName: String!
    var name: String
    var path: String!
    var fileSystem: FileSystem
    var partScheme: PartScheme
    var hasEFI: Bool
	
	var tmDisk = false
	
	var size: UInt64 = 0
	
	var usable = false
	
    public init(){
        bsdName = "/dev/"
        name = ""
        path = ""
        fileSystem = .blank
        partScheme = .blank
        hasEFI = false
    }
    
    public init(partitionBSDName: String?, partitionName: String, partitionPath: String?, partitionFileSystem: FileSystem, partitionScheme: PartScheme, partitionHasEFI: Bool, partitionSize: UInt64){
        bsdName = partitionBSDName
        name = partitionName
        path = partitionPath
        fileSystem = partitionFileSystem
        partScheme = partitionScheme
        hasEFI = partitionHasEFI
        size = partitionSize
    }
    
    public func copy() -> Part{
		//let p = Part(partitionBSDName: bsdName, partitionName: name, partitionPath: path, partitionFileSystem: fileSystem, partitionScheme: partScheme, partitionHasEFI: hasEFI, partitionSize: totSize)
		let p = Part()
		
		p.bsdName = bsdName
		p.name = name
		p.path = path
		p.fileSystem = fileSystem
		p.partScheme = partScheme
		p.hasEFI = hasEFI
        p.apfsBDSName = apfsBDSName
		p.size = size
		
		p.tmDisk = tmDisk
		p.usable = usable
		
        return p
    }
    
    
    
}
