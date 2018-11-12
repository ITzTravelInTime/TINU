//
//  Reachability.swift
//  TINU
//
//  Created by Pietro Caruso on 27/07/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Reachability {
	
	class func isConnectedToNetwork() -> Bool {
		
		var zeroAddress = sockaddr()
		zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
		zeroAddress.sa_family = sa_family_t(AF_INET)
		
		guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
		}) else { return false }
		
		var flags = SCNetworkReachabilityFlags()
		guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else { return false }
		
		return flags.contains(.reachable) && !flags.contains(.connectionRequired)
	}
	
}
