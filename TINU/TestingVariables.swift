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

import Foundation

//those variables are used to simulate some scenarios to test the different screens and error messages

///this variable tells to the app to simulate a scenario when there were no drives found
public let simulateNoUsableDrives = false
///this variable tells to the application to simulate a situation when there wehere no mac os installer apps found
public let simulateNoUsableApps = false
///this variable tells to the appliation to simulate a situation when the confirm windows fails to get the drive and app data
public let simulateConfirmGetDataFail = false

//testing variables for the installer creation screen

///this varable tells to the app to simulate asituation in which the the install window fails to get the drive and app data
public let simulateInstallGetDataFail = false

///this tells to simulate a cancel into the first auth step
public let simulateFirstAuthCancel = false

///this tells to simulate a cancel into the second auth step
public let simulateSecondAuthCancel = false

///this variable tell to the app to not format the drive chosen if it needs to be formatted
public var simulateFormatSkip = false

///this tells to simulate a failure of the drive format code
public let simulateFormatFail = false

///tells to the app to not use the timer for the createinstallmedia process
public let simulateNoTimer = false

///this tells to simulate a createinstall media failure or success, if it is nil it will perform createinstallmedia as usual.
///
///Here is what happens for each of the possible values:
/// - `false`: simulate installer creation success
/// - `true`: simulate installer creation fail
/// - `nil:` (default) executes createinstallmedia as usual
///
public let simulateCreateinstallmediaFail: Bool! = nil

///this tells to the application to simule an abnormal opcode result after execution of the scripts
public let simulateAbnormalExitcode = false

///this variable tells to the app to ignore special operations after the end of the createinstallmedia process
///
///values:
/// - `true`:  the advanced option will be skipped with true as result
/// - `false`: the advanced options will be skipped with false as result
/// - `nil`:   (default) all normal
public let simulateNoSpecialOperations: Bool! = nil

///this variable is used to simulate a failure while doing advanced operations
public let simulateSpecialOperationsFail = false

///this is used when simulateCreateinstallmediaFail != nil and it uses a custom test print for the test command
public let simulateCreateinstallmediaFailCustomMessage: String = ""

///this is used to debug the app as it is into the recovery
public let simulateRecovery = false

///This is used to simulate a disabled/enabled sip
///
///Values:
/// - true/false simulate on/off state of sip
/// - nil use actual sip state
public let simulateSIPStatus: Bool! = nil

///Simulates the detected pixel size for the screens currently attached to the computer
///
///Values:
/// - [numeric value] simulates HIDPI pixel size
/// - nil use the actual detected HIDPI pixel size
public let simulateHIDPIStatus: CGFloat! = nil

///Simulates the detection or not of a network connection
///
///Values:
/// - [bool value] simulates the ntwork conenction status
/// - nil use the actual detected network conenction status
public let simulateReachabilityStatus: Bool! = nil

///Simulates the availability of updates
///
///Values:
/// - [bool value] simulates the update availability status
/// - nil use the actual update status
public let simulateUpdateStatus: Bool! = true

///Simulates the availability of updates
///
///Values:
/// - [bool value] simulates the relase [true] or pre release [false] status
/// - nil use the actual relase status
public let simulateReleaseStatus: Bool! = nil


///This variable forces a UI Style if not nil, see the AppLook enum for the oossible values
public let simulateLook: UIManager.AppLook! = nil//.shadowsSFSymbolsFill//.shadowsOldIcons//.recovery

//non ui testing conditions

///Enables some disabled debug prints
public let sharedEnableDebugPrints: Bool = true
