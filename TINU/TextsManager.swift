//
//  TextsManager.swift
//  TINU
//
//  Created by Pietro Caruso on 10/06/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation

//this is the verbose mode script, a copy here is leaved here just in case it's missing from the application folder
public let verboseScript = "#!/bin/sh\n#  DebugScript.sh\n#  TINU\n#\n#  Created by Pietro Caruso on 20/09/17.\n#  Copyright © 2017-2018 Pietro Caruso. All rights reserved.\necho \"Staring running TINU in log mode\"\n\"$(dirname \"$(dirname \"$0\")\")/MacOS/TINU\""

//this is the text of the readme file that is written on the macOS install media at the end of the createinstallmedia process
public var readmeText: String {
	get{
		#if macOnlyMode
		return "Thank you for using TINU"
		#else
		
		if sharedInstallMac{
			return "Thank you for using TINU\n\nIf you want to use this macOS system on an hackintosh, please download and install the clover bootloader, you can find it here:\n https://sourceforge.net/projects/cloverefiboot/files/latest/download?source=files\n\n(note that the clover bootloader needs to be installed and configured properly depending on the hw configuration of the system you want to install on, for help about that go to: www.insanelymac.com)\n\nIf you want to use this macOS system on a standard mac, you don`t have to do any extra steps, it`s ready to be used"
		}else{
			return "Thank you for using TINU\n\nIf you want to use this bootable macOS installer on an hackintosh, please download and install the clover bootloader, you can find it here:\n https://sourceforge.net/projects/cloverefiboot/files/latest/download?source=files\n\n(note that the clover bootloader needs to be installed and configured properly depending on the hw configuration of the system you want to install on, for help about that go to: www.insanelymac.com)\n\nIf you want to use this bootable macOS installer on a standard mac, you don`t have to do any extra steps, it`s ready to be used"
		}
		#endif
	}
}
