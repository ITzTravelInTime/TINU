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
import SwiftLoggedPrint

fileprivate protocol CodableLink: Codable, Equatable{
	var link: String { get  }
}

public final class UpdateManager{
	
	private class func getVersionInfoLink() -> String?{
		
		struct UpdateLink: CodableLink{
			let link: String
		}
		
		guard let folder = Bundle.main.path(forResource: "LatestVersionDownload", ofType: "json") else{
			return nil
		}
		
		do{
			guard let tempData = try String(data: Data(contentsOf: URL(fileURLWithPath: folder ) ), encoding: .utf8) else{
				return nil
			}
			
			guard let link = UpdateLink(fromJSONSerialisedString: tempData)?.link else{
				return nil
			}
			
			return link
			
		}catch{
			return nil
		}
		
	}
	
	public class func checkForUpdates(){
		
		struct UpdateInfo: CodableLink{
			let build: UInt64
			let link: String
		}
		
		struct UpdateStruct: Codable, Equatable{
			let stable: UpdateInfo
			let pre_release: UpdateInfo
		}
		
		if Recovery.status{
			log("[Update] We are in a recovery environment, let's skip update chacks ...")
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
		
		guard let url = URL(string: urlContents) else{
			log("[Update] Can't generate a valid url for requesting update info")
			return
		}

		let task = URLSession.shared.dataTask(with:url) { (data, response, error) in
			if let e = error {
				log("[Update] Error while getting the update information from the stored update link: \(e.localizedDescription)")
				return
			}
			   
			guard let textFile = String(data: data!, encoding: .utf8) else{
				log("[Update] Can't convert the data got remotely into a valid string.")
				return
			}
			
			guard let latestInfo = UpdateStruct(fromJSONSerialisedString: textFile) else{
				log("[Update] Can't interpretate the remote data.")
				return
			}
			
			log("[Update] Latest release version info: \n  link: \(latestInfo.stable.link) \n  build number: \(latestInfo.stable.build)")
			log("[Update] Latest pre-release version info: \n  link: \(latestInfo.pre_release.link) \n  build number: \(latestInfo.pre_release.build)")
			
		}
		
		task.resume()
		
	}
}
