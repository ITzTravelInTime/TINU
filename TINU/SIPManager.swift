//
//  SIPManager.swift
//  TINU
//
//  Created by Pietro Caruso on 20/06/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Cocoa

final class SIPManager: ViewID{
	
	let id: String = "SIPManager"
	
	private static let ref = SIPManager()
	
	//launch this check from a background thread
	class func checkStatus() -> Bool{
		
		if #available(OSX 10.11, *){
			if simulateSIPStatus != nil{
				return simulateSIPStatus
			}
			if let arch = CpuArchitecture.actualCurrent(){
				if arch != .intel64{
					return true
				}
			}
			return (CommandsManager.getOut(cmd: "csrutil status").contains("enabled"))
		}else{
			return false
		}
		
	}

	class func checkStatusAndLetTheUserKnow(){
		if let arch = CpuArchitecture.actualCurrent(){
			if arch != .intel64{
				return
			}
		}
		DispatchQueue.global(qos: .background).async {
			if checkStatus(){
				//msgBoxWithCustomIcon("TINU: Please disable SIP", "SIP (system integrity protection) is enabled and will not allow TINU to complete successfully the installer creation process, please disable it or use the diagnostics mode with administrator privileges", .warning , IconsManager.shared.stopIcon)
				DispatchQueue.main.async {
					msgboxWithManager(ref, name: "disable", parseList: nil, style: NSAlert.Style.critical, icon: nil)
				}
			}
		}
	}

}

