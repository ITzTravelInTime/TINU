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

import Foundation
import TINURecovery
import TINUSerialization

fileprivate protocol CodableLink: Codable, Equatable{
	var link: String { get  }
}

public final class UpdateManager{
	
	private class func getVersionInfoLink() -> String?{
		
		struct UpdateLink: CodableLink{
			let link: String
		}
		
		guard let file = Bundle.main.path(forResource: "LatestVersionDownload", ofType: "json") else{
			return nil
		}
		
		guard let link = UpdateLink(fromFileAtPath: file)?.link else{
			return nil
		}
		
		return link
	}
	
	public class func checkForUpdates(){
		
		struct UpdateInfo: CodableLink{
			let build: String
			let link: String
		}
		
		struct UpdateStruct: Codable, Equatable{
			let pre_release: UpdateInfo?
			let stable: UpdateInfo
		}
		
		if Recovery.status{
			log("[Update] We are in a recovery environment, let's skip update checks ...")
			return
		}
		
		if !Reachability.status{
			log("[Update] The computer seems to not be connected to a network, updates will not be checked.")
			return
		}
		
		guard let urlContents = getVersionInfoLink() else {
			log("[Update] Can't get the link for the update information.")
			return
		}
		
		guard let info = UpdateStruct.init(fromRemoteFileAtUrl: urlContents)else{
			log("[Update] Can't get remote structure for update information.")
			return
		}
		
		log("[Update] Obtained update info: \(info.stable)")
		
		if let beta = info.pre_release{
			log("[Update] Obtained pre-release update info: \(beta)")
		}

	}
}
