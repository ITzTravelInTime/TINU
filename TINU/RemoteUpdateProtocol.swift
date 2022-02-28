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
import AppKit
import TINUSerialization

protocol RemoteUpdateVersionProtocol: /*Codable, Equatable,*/ ViewID{
	var name: String {get}
	var body: String {get}
	var html_url: String? {get}
	var tag_name: String {get}
	func getDirectDownloadUrl() -> URL?
}

protocol RemoteUpdateProtocol /*: Codable, Equatable*/{
	associatedtype T: RemoteUpdateVersionProtocol
	static var classID: String {get}
	static var fetchURL: URL? {get}
	//var update: T {get}
	
	func getLatestRelease() -> T
	func getLatestPreRelease() -> T?
	init?(fromRemoteTextAt url: URL, descapeCharacters: Bool)
	init?(fromRemoteTextAt url: URL)
	
	//func openWebPageOrDirectDownload()
	//func openDirectDownloadOrWebpage()
	//func isNewerVersion() -> Bool
	//func checkAndSendUpdateNotification(sendNotificatinAlways: Bool )
}

extension RemoteUpdateVersionProtocol{
	public var id: String{
		return  "UpdateProtocol"
	}
	
	func isNewerVersion() -> Bool{
		
		guard let build = Bundle.main.build?.lowercased().uInt64Value else {
			log("[Update] Can't get app bundle build number information.")
			return false
		}
		
		var num = tag_name.split(separator: "(").last!
		
		if num.last == ")"{
			num.removeLast()
		}
		
		guard let updateBuildNumber = num.lowercased().uInt64Value else{
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
	
	func openWebPageOrDirectDownload(){
		var toBeOpened: URL!
		
		if let url = self.html_url{
			toBeOpened = URL(string: url)
		}else if let url = self.getDirectDownloadUrl(){
			toBeOpened = url
		}
			
		if let open = toBeOpened{
			NSWorkspace.shared.open(open)
		}
	}
	
	func openDirectDownloadOrWebpage(){
		
		var toBeOpened: URL!
		
		if let url = self.getDirectDownloadUrl(){
			toBeOpened = url
		}else if let url = self.html_url{
			toBeOpened = URL(string: url)
		}
			
		if let open = toBeOpened{
			NSWorkspace.shared.open(open)
		}
	}
	
	func checkAndSendUpdateNotification(sendNotificatinAlways: Bool = false){
		
		if !isNewerVersion(){
			
			if !sendNotificatinAlways{
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
		}else if !UpdateManager.displayNotification && !sendNotificatinAlways{
			log("[Update] Avoiding showing the update notification.")
			return
		}
		
		guard let notification = TextManager.getNotification(context: self, id: "updateNotification") else{
			
			log("[Update] Error while loading the update notification froim file.")
			return
			
		}
		
		
		notification.message = notification.message.parsed(usingKeys: ["{version}": name])
		notification.description = notification.description.parsed(usingKeys: ["{description}": body])
		notification.allowsSpam = true
		notification.userTag = ["shouldOpenUpdateLinks": "true"]
		notification.justSend()
		
		log("[Update] update notification should have been sent.")
	}
}

extension RemoteUpdateProtocol{
	
	
	
	static func getUpdateData(forceRefetch force: Bool = false, descapeCharacters: Bool = false) -> Self!{
		
		if !Reachability.status{
			log("[Update] The computer seems to not be connected to a network, updates will not be checked.")
			return nil
		}
		
		if let data = UpdateManager.updateCacheData[Self.classID], let obj = data.info as? Self, !force{
			return obj
		}
		
		if Recovery.status{
			log("[Update] We are in a recovery environment, let's skip update checks ...")
			return nil
		}
		
		guard let urlContents = Self.fetchURL else {
			log("[Update] Can't get the link for the update information.")
			return nil
		}
		
		guard let info = Self.init(fromRemoteTextAt: urlContents, descapeCharacters: descapeCharacters) else{
			DispatchQueue.global(qos: .background).async {
				log("[Update] Can't get remote structure for update information.")
				log("[Update] Update serialized string:\n" + (String.init(fromRemoteFileAt: urlContents) ?? "[No serialized data available]"))
			}
			return nil
		}
		
		UpdateManager.updateCacheData[Self.classID] = .init(info: info, cachedPreRelease: nil, cachedRelease: nil)
		
		return info
	}
	
	var update: T{
		
		let rel = UpdateManager.updateCacheData[Self.classID]?.cachedRelease ?? getLatestRelease()
		let prerel = UpdateManager.updateCacheData[Self.classID]?.cachedPreRelease ?? getLatestPreRelease()
		
		if UpdateManager.updateCacheData[Self.classID] == nil{
			UpdateManager.updateCacheData[Self.classID] = .init(info: self, cachedPreRelease: prerel, cachedRelease: rel)
		}else{
			if UpdateManager.updateCacheData[Self.classID]!.cachedRelease == nil{
				UpdateManager.updateCacheData[Self.classID]!.cachedRelease = rel
			}
			
			if UpdateManager.updateCacheData[Self.classID]!.cachedPreRelease == nil{
				UpdateManager.updateCacheData[Self.classID]!.cachedPreRelease = prerel
			}
		}
		
		if let pre = prerel as? T, App.isPreRelase{
			return pre
		}
		
		return getLatestRelease()
	}
}
