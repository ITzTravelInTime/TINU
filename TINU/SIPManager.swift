//
//  SIPManager.swift
//  TINU
//
//  Created by Pietro Caruso on 20/06/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

final class SIPManager{
	//launch this check from a background thread
	@inline(__always) class func checkSIP() -> Bool{
		if #available(OSX 10.11, *){
			return (getOut(cmd: "csrutil status").contains("enabled"))
		}else{
			return false
		}
	}

	class func checkSIPAndLetTheUserKnow(){
		if checkSIP(){
			msgBoxWithCustomIcon("TINU: Please disable SIP", "SIP (system integrity protection) is enabled and will not allow TINU to complete successfully the installer creation process.", .warning , IconsManager.shared.stopIcon)
		}
	}

}

