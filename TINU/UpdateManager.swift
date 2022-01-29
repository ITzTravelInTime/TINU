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
import AppKit

public final class UpdateManager{
	
	static var shoudDisplayUpdateNotification: Bool = true
	
	struct UpdateInfo: ViewID, Codable, Equatable{
		let build: String
		let link: String
		let pageLink: String
		let version: String
		let description: String
		
		public var id: String{
			return  "UpdateNamanger"
		}
		
		func openWebPageOrDirectDownload(){
			var toBeOpened: URL!
			
			if let url = URL(string: pageLink){
				toBeOpened = url
			}else if let url = URL(string: link){
				toBeOpened = url
			}
				
			if let open = toBeOpened{
				NSWorkspace.shared.open(open)
			}
		}
		
		func openDirectDownloadOrWebpage(){
			
			var toBeOpened: URL!
			
			if let url = URL(string: link){
				toBeOpened = url
			}else if let url = URL(string: pageLink){
				toBeOpened = url
			}
				
			if let open = toBeOpened{
				NSWorkspace.shared.open(open)
			}
		}
		
		func shouldUpdateToThisBuild() -> Bool{
			
			guard let build = Bundle.main.build?.lowercased().uInt64Value else {
				log("[Update] Can't get app bundle build number information.")
				return false
			}
			
			guard let updateBuildNumber = self.build.lowercased().uInt64Value else{
				log("[Update] the update info is invalid!")
				return false
			}
			
			if let simulated = simulateUpdateStatus{
				if !simulated{
					log("[Update] simulating no update available")
					return false
				}
			}else if build >= updateBuildNumber{
				log("[Update] the current copy of the app is up to date.")
				return false
			}
			
			log("[Update] new update found!")
			
			return true
		}
		
		func checkAndSendUpdateNotification(shouldSendUpToDateNotification: Bool = false, shouldSendUpdateNotificationAnyway: Bool = false){
			
			if !shouldUpdateToThisBuild(){
				
				if !shouldSendUpToDateNotification{
					return
				}
				
				guard let notification = TextManager.getNotification(context: self, id: "alreadyUpToDateNotification") else{
					
					log("[Update] Error while loading the update notification froim file.")
					return
					
				}
				
				notification.userTag = ["shouldOpenUpdateLinks": "false"]
				notification.allowsSpam = true
				notification.justSend()
				
				return
			}else if !shoudDisplayUpdateNotification && !shouldSendUpdateNotificationAnyway{
				log("[Update] Avoiding showing the update notification.")
				return
			}
			
			guard let notification = TextManager.getNotification(context: self, id: "updateNotification") else{
				
				log("[Update] Error while loading the update notification froim file.")
				return
				
			}
			
			
			notification.message = parse(messange: notification.message, keys: ["{version}": "\(version) (\(build))"])
			notification.description = parse(messange: notification.description, keys: ["{description}": description])
			notification.allowsSpam = true
			notification.userTag = ["shouldOpenUpdateLinks": "true"]
			notification.justSend()
			
			log("[Update] update notification should have been sent.")
		}
	}
	
	struct UpdateStruct: Codable, Equatable{
		let pre_release: UpdateInfo?
		let stable: UpdateInfo
		
		var update: UpdateInfo{
			if let pre = pre_release, App.isPreRelase{
				return pre
			}
			
			return stable
		}
	}
	
	class func getUpdateData(forceRefetch force: Bool = false) -> UpdateStruct!{
		
		struct MEM{
			static var updateData: UpdateStruct! = nil
		}
		
		if Recovery.status{
			log("[Update] We are in a recovery environment, let's skip update checks ...")
			return nil
		}
		
		if !Reachability.status{
			log("[Update] The computer seems to not be connected to a network, updates will not be checked.")
			return nil
		}
		
		if MEM.updateData != nil && !force{
			return MEM.updateData
		}
		
		guard let urlContents = getVersionInfoLink() else {
			log("[Update] Can't get the link for the update information.")
			return nil
		}
		
		guard let info = UpdateStruct.init(fromRemoteFileAtUrl: urlContents) else{
			log("[Update] Can't get remote structure for update information.")
			return nil
		}
		
		MEM.updateData = info
		
		return info
	}
	
	private class func getVersionInfoLink() -> String?{
		return RemoteResourcesURLsManager.list["updates"]
	}
}
