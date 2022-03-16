/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

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

//TODO: Put this code into TINUIORegistry library eventually

import Foundation
import IOKit
import IOKit.pwr_mgt

public typealias SPM = SleepPreventionManager

public final class SleepPreventionManager: ViewID{
	public let id: String = "InstallingViewController" //TODO: change this with it's own id both here and in the files
	
	public static let shared: SleepPreventionManager = .init()
	
	private var sleep_assertionID: IOPMAssertionID = 0
	private var sleep_success: IOReturn = kIOReturnSuccess
	
	func activateSleepPrevention() -> Bool{
		let sleep_reason: NSString = (TextManager.getViewString(context: self, stringID: "sleepPreventionReason") ?? "TINU needs the system to not sleep") as NSString
		
		sleep_success = IOPMAssertionCreateWithName( kIOPMAssertionTypeNoDisplaySleep as CFString,
													 IOPMAssertionLevel(kIOPMAssertionLevelOn),
													 sleep_reason,
													 &sleep_assertionID )
		
		return sleep_success == kIOReturnSuccess
	}
	
	func cancelSleepPrevention(){
		if sleep_success == kIOReturnSuccess || sleep_assertionID != 0{
			sleep_success = IOPMAssertionRelease(sleep_assertionID);
			sleep_assertionID = 0
		}
	}
	
}
