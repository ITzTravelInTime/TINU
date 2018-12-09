//
//  CreationVariablesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class CreationVariablesManager{
	
	static let shared = CreationVariablesManager()
	
	public var currentPart: Part!
	
	//this variable is the drive or partition that the user has selected
	public var sharedVolume: String!{
		get{
			return currentPart.path
		}
		set{
			currentPart.path = newValue
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
				InstallerAppManager.shared.resetCachedAppInfo()
			}
			
			checkOtherOptions()
			
		}
	}
	//this variable tells to the app which is the bundle name of the selcted installer app
	public var sharedBundleName = ""
	
	//this is used for the app version
	public var sharedBundleVersion = ""
	
	//this varable tells to the app if the selected volume or drive needs to be reformatted using hfs+ (deprecated)
	//public var sharedVolumeNeedsFormat: Bool!
	//this variable tells to the app if the selected drive needs to be formatted using GUID partition method
	public var sharedVolumeNeedsPartitionMethodChange: Bool!
	
	//thi is used to determinate if there is the need for the time machine warn
	public var sharedDoTimeMachineWarn = false

	//this tells to the app is the install media uses custom settings
	public var sharedMediaIsCustomized = false
}

typealias cvm = CreationVariablesManager
