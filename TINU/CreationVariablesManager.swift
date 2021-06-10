//
//  CreationVariablesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation



public class CreationVariablesManager{
	
	class CreateinstallmediaSmallManager{
		
		enum Status: UInt8, CaseIterable, Codable, Equatable{
			case configuration = 0
			case preCreation
			case creation
			case postCreation
			case doneSuccess
			case doneFailure
			
			func isBusy() -> Bool{
				return (self == .creation || self == .preCreation || self == .postCreation)
			}
		}
		
		public var status: Status = .configuration
		
		//variables used to manage the creation process
		public var process = Process()
		public var errorPipe = Pipe()
		public var outputPipe = Pipe()
		
		
		
		public var startTime = Date()
	}
	
	static let shared = CreationVariablesManager()
	
	init(){
		process = CreateinstallmediaSmallManager()
		options = OtherOptionsManager(self)
		app = InstallerAppManager(self)
	}
	
	var process: CreateinstallmediaSmallManager! = nil
	var options: OtherOptionsManager! = nil
	var app    : InstallerAppManager! = nil
	
	//this variable tells to the app if the selected drive needs to be formatted using GUID partition method
	public var sharedVolumeNeedsPartitionMethodChange: Bool!
	
	//thi is used to determinate if there is the need for the time machine warn
	public var sharedDoTimeMachineWarn = false

	//this tells to the app is the install media uses custom settings
	public var sharedMediaIsCustomized = false
	
	public var currentPart: Part!
	
	//this variable is the drive or partition that the user has selected
	public var sharedVolume: String!{
		get{
			return currentPart.mountPoint
		}
		set{
			currentPart.mountPoint = newValue
		}
	}
	
	//this variable is the bsd name of the drive or partition currently selected by the user
	public var sharedBSDDrive: String!{
		get{
			return currentPart.bsdName
		}
		set{
			currentPart.bsdName = newValue
		}
	}
	
	//this variable is used to store apfs disk bsd id
	public var sharedBSDDriveAPFS: String!{
		get {
			return currentPart.apfsBDSName
		}
		set{
			currentPart.apfsBDSName = newValue
		}
	}
	
	//used to detect if a volume relly uses apfs or it's just an internal apple volume
	public var sharedSVReallyIsAPFS = false
	
	//this is the path of the mac os installer application that the user has selected
	public var sharedApp: String!{
		didSet{
			
			if sharedApp != nil{
				cvm.shared.app.resetCachedAppInfo()
			}
			
			cvm.shared.options.checkOtherOptions()
		}
	}
	
	func compareSize(to number: UInt64) -> Bool{
		//print(currentPart.size)
		//print(number)
		return (currentPart != nil) ? (currentPart.size > number + UInt64(5 * pow(10.0, 8.0))) : false
	}
	
	func compareSize(to string: String!) -> Bool{
		if let s = UInt64(string){
			return compareSize(to: s)
		}
		return false
	}
	
	
}

typealias cvm = CreationVariablesManager
