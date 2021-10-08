/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
			if App.isTesting{
				return "TINU (testing version)"
			}
			
			return "TINU"
		}
	}
	
}

#if !isTool
public final class CustomizationWindowManager{
	static let shared = CustomizationWindowManager()
	
	var referenceWindow: NSWindow!
}
#endif
