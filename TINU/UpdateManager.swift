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
import TINURecovery
import TINUSerialization
import TINUNotifications

fileprivate protocol CodableLink: Codable, Equatable{
	var link: String { get  }
}

public final class UpdateManager{
	
	private class func getVersionInfoLink() -> String?{
		return RemoteResourcesURLsManager.list["updates"]
	}
	
	public class func checkForUpdates(){
		
		struct UpdateInfo: CodableLink{
			let build: String
			let link: String
			let pageLink: String?
			let version: String
			let description: String?
			
			func check(build: UInt64){
				guard let updateBuildNumber = self.build.lowercased().uInt64Value else{
					log("[Update] the update info is invalid!")
					return
				}
				
				if let simulated = simulateUpdateStatus{
					if simulated{
						log("[Update] simulating no opdate available")
						return
					}
				}else if build >= updateBuildNumber{
					log("[Update] the current copy of the app is up to date.")
					return
				}
				
				log("[Update] new update found!")
				
				let versionString = "\(version) (\(updateBuildNumber))"
				
				let notification = TINUNotifications.Notification(id: "TINU_update_notification_\(arc4random())", message: "Version \(versionString) is now available", description: "")
				
				notification.description = description != nil ? "New in version \(versionString):\n\n\(description ?? "")" : "For more info on the update click this messange to check it out."
				
				notification.allowsSpam = true
			
				/*
				//if #available(macOS 11.0, *) {} else {
					notification.actionButtonTitle = "More ..."
					notification.displayActionSelector = true
				//}
				*/
				 
				//notification.addAction(id: "MORE_INFO_ID", displayName: "More info")
				notification.addAction(id: "DIRECT_DOWNLOAD", displayName: "Download Now")
				
				notification.userTag = [:]
				notification.userTag!["BrowserLink"] = pageLink
				notification.userTag!["DirectDownloadLink"] = link
				
				notification.justSend()
				
				log("[Update] update notification should have been sent.")
			}
		}
		
		struct UpdateStruct: Codable, Equatable{
			let pre_release: UpdateInfo?
			let stable: UpdateInfo
		}
		
		guard let version = Bundle.main.version?.lowercased(), let build = Bundle.main.build?.lowercased().uInt64Value else {
			log("[Update] Can't get app bundle information.")
			return
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
		
		guard let info = UpdateStruct.init(fromRemoteFileAtUrl: urlContents) else{
			log("[Update] Can't get remote structure for update information.")
			return
		}
		
		log("[Update] Obtained update info: \(info.stable)")
		
		/*
		if let beta = info.pre_release{
			log("[Update] Obtained pre-release update info: \(beta)")
		}
		*/
		
		if let pre = info.pre_release, (version.contains("beta") || version.contains("alpha") || (version.contains("release") && version.contains("candidate"))){
			log("[Update] checking updates for pre-release builds")
			pre.check(build: build)
		}else{
			log("[Update] checking updates for release builds")
			info.stable.check(build: build)
		}
		
		

	}
}
