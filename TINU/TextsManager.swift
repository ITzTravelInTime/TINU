//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

public final class TextManager{

//this is the verbose mode script, a copy here is leaved here just in case it's missing from the application folder
	/*
public static let verboseScript = "#!/bin/sh\n#  DebugScript.sh\n#  TINU\n#\n#  Created by Pietro Caruso on 20/09/17.\n#  Copyright © 2017-2020 Pietro Caruso. All rights reserved.\necho \"Staring running TINU in log mode\"\n\"$(dirname \"$(dirname \"$0\")\")/MacOS/TINU\""
	
public static let verboseScriptSudo = "#!/bin/sh\n#  DebugScriptSudo.sh\n#  TINU\n#\n#  Created by Pietro Caruso on 20/06/20.\n#  Copyright © 2017-2020 Pietro Caruso. All rights reserved.\necho \"Staring running TINU in log mode\"\nsudo \"$(dirname \"$(dirname \"$0\")\")/MacOS/TINU\""*/

//this is the text of the readme file that is written on the macOS install media at the end of the createinstallmedia process
public static var readmeText: String {
	get{
		#if macOnlyMode
		return "Thank you for using TINU\n\nRemember that this installer will work just with supported macs and not with unsupported machines"
		#else
		
		if sharedInstallMac{
			return "Thank you for using TINU\n\nIf you want to use this macOS system on an hackintosh, please download and install either the Clover or the OpenCore bootloader, you can find Clover here:\n https://github.com/CloverHackyColor/CloverBootloader/releases\n\nor OpenCore here:\n https://github.com/acidanthera/OpenCorePkg/releases \n\n(note that the bootloaders mentioned needs to be installed and configured properly depending on the hw configuration of the system you want to install on, for help about that go to: www.insanelymac.com or r/Hackintosh)\n\nIf you want to use this macOS system on a standard mac, you don`t have to do any extra steps, it`s ready to be used."
		}else{
			return "Thank you for using TINU\n\nIf you want to use this bootable macOS installer on an hackintosh, please download and install either the Clover or the OpenCore bootloader, you can find Clover here:\n https://github.com/CloverHackyColor/CloverBootloader/releases\n\nor OpenCore here:\n https://github.com/acidanthera/OpenCorePkg/releases \n\n(note that the bootloaders mentioned needs to be installed and configured properly depending on the hw configuration of the system you want to install on, for help about that go to: www.insanelymac.com or r/Hackintosh)\n\nIf you want to use this bootable macOS installer on a standard mac, you don`t have to do any extra steps, it`s ready to be used."
		}
		#endif
	}
}
	
	public static let helpfoulMessage = """
	
	******************************************
	
	Note that:
	
	-This process may take a lot of time (usually between 5 and 50 minutes) especially with slow storage devices (like Hard drives, SD/micro SD cards and virtual disks) and slow machines (like most virtual machines), so be patient and wait for it to finish
	
	-If you feel nothing is happening or the program is stuck remeber that TINU is just waiting for the program, \(sharedExecutableName), to take care of the foundamental steps of this process, without knowing when it will finish his opearation. So TINU it's not stuck, it's just waiting.
	
	-The progress shown in the progress bar is just to give to the user the impression of busyness and that something is happening, so that's only cosmethic, but it's not actual progress since there is not a consistent way of obtaining accurate progress values during this step. TINU is just making the bar going forward by using a timer which increments it each few seconds for 50 minutes.
	
	-For more help or questions go to |Menu bar| -> |TINU| -> |Related to TINU| -> |Contact us| there you will find all the links and the contacts related to this project (NOTE: this doesn't work when TINU is running in a macOS recovery environment).
	
	******************************************
	
	"""
	
}
