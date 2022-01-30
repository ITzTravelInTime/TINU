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

public final class UpdateManager{
	
	static var displayNotification: Bool = true
	static var updateCacheData: [String: Any] = [:]
	
	struct UpdateStruct: RemoteUpdateProtocol{
		
		struct UpdateInfo: RemoteUpdateVersionProtocol{
			let build: String
			let link: String
			let pageLink: String
			let version: String
			let description: String
			
			var name: String{
				return version + " (" + build + ")"
			}
			
			var body: String{
				return description
			}
			
			var html_url: URL?{
				return URL(string: pageLink)
			}
			
			var tag_name: String{
				return version + "_(" + build + ")"
			}
			
			func getDirectDownloadUrl() -> URL? {
				return URL(string: link)
			}
		}
		
		static var classID: String{
			return "UpdateOld"
		}
		
		static var fetchURL: URL?{
			if let str =  RemoteResourcesURLsManager.list["updates"]{
				return URL(string: str)
			}
			
			return nil
		}
		
		let pre_release: UpdateInfo?
		let stable: UpdateInfo
		
		func getLatestRelease() -> UpdateInfo {
			return stable
		}
		
		func getLatestPreRelease() -> UpdateInfo? {
			return pre_release
		}
		
	}
	
}
