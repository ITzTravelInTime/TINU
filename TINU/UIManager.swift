//
//  UIManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import AppKit

public final class UIManager{
	
	static let shared = UIManager()
	
	//the shared variable of the main windows, it used as safe reference
	public var window: NSWindow!
	//the shared contacts window
	public var contactsWC: ContactsWindowController!
	//the shared credits window
	public var creditsWC: CreditsWindowController!
	
	public var detectionInfoWC: DriveDetectInfoWindowController!
	public var downloadAppWC:   DownloadAppWindowController!
	
	#if !macOnlyMode
	public var EFIPartitionMonuterTool: EFIPartitionMounterWindowController!
	#endif
	
	//public log window varivble
	public var logWC: LogWindowController!
	//this variable is a storyboard that is used to instanciate some windows
	public var storyboard: NSStoryboard!
	//sets if the license window has to be show
	public var showLicense = false
	
	//this gives the prefix for the window title
	public var windowTitlePrefix: String{
		get{
			if AppManager.shared.sharedTestingMode{
				return "TINU (testing version)"
			}
			
			return "TINU"
		}
	}
	
}
