//
//  AppleSiliconDetect.swift
//  TINU
//
//  Created by Pietro Caruso on 21/05/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation

enum AppExecution: Int32, Codable, Equatable, CaseIterable{
	case unkown = -1
	case native = 0
	case emulated = 1
	
	static func current() -> AppExecution?{
		var ret: Int32 = 0
		var size = ret.bitWidth / 8
		
		let result = sysctlbyname("sysctl.proc_translated", &ret, &size, nil, 0)
		
		if result == -1 {
			if (errno == ENOENT){
				return AppExecution.native
			}
			return AppExecution.unkown
		}
		
		return AppExecution(rawValue: ret)
	}
}

extension ProcessInfo {
		var machineHardwareName: String? {
				var sysinfo = utsname()
				let result = uname(&sysinfo)
				guard result == EXIT_SUCCESS else { return nil }
				let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
				guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
				return identifier.trimmingCharacters(in: .controlCharacters)
		}
}

enum CpuArchitecture: String, Codable, Equatable, CaseIterable{
	case ppc     = "ppc"
	case ppcG1   = "ppc601"
	case ppcG2   = "ppc604"
	case ppcG3   = "ppc750"
	case ppcG4   = "ppc7400"
	case ppcG5   = "ppc970"
	case ppc64   = "ppc64"
	case intel32 = "i386"
	case intel64 = "x86_64"
	case arm     = "arm"
	case arm64   = "arm64"
	
	static func current() -> CpuArchitecture?{
		return CpuArchitecture(rawValue: ProcessInfo.processInfo.machineHardwareName ?? "")
	}
	
	static func actualCurrent() -> CpuArchitecture?{
		guard let arch = current() else { return nil }
		guard let mode = AppExecution.current() else { return nil }
		
		if arch == .intel64 && mode == .emulated{
			return arm64
		}
		
		if arch.isPPC() && mode == .emulated{
			return intel32
		}
		
		return arch
		
	}
	
	func isPPC() -> Bool{
		return self.rawValue.starts(with: "ppc")
	}
	
	func isPPC64() -> Bool{
		return self == .ppc64 || self == .ppcG5
	}
	
	func isPPC32() -> Bool{
		return isPPC() && !isPPC64()
	}
}
