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

protocol GitHubItemProtocol: Codable, Equatable{
	var id: UInt64 {get}
	var node_id: String {get}
	var html_url: URL? {get}
	var url: URL {get}
}

protocol GitHubNamedItemProtocol: GitHubItemProtocol{
	var name: String {get}
}

extension UpdateManager{
	struct GitHubApiUpdateStruct: RemoteUpdateProtocol, RawRepresentable{
		
		init?(rawValue: [Release]) {
			self.rawValue = rawValue
		}
		
		var rawValue: [Release]
		
		typealias RawValue = [Release]
		
		static var classID: String{
			return "GitHubUpdateStruct"
		}
		
		static var fetchURL: URL?{
			if let str =  RemoteResourcesURLsManager.list["GitHubApiUpdates"]{
				return URL(string: str)
			}
			
			return nil
		}
		
		private static var cachedRelease: Release? = nil
		private static var preReleaseAvailable: Bool? = nil
		private static var cachedPreRelease: Release? = nil
		
		func getLatestRelease() -> Release {
			if let cached = Self.cachedRelease {
				return cached
			}
			
			var latest: Release? = nil
			
			for i in rawValue{
				if i.prerelease{
					continue
				}
				
				guard let last = latest else {
					latest = i
					continue
				}
				
				if ((last.published_at ?? last.created_at).date()?.timeIntervalSinceReferenceDate ?? 0) > ((i.published_at ?? i.created_at).date()?.timeIntervalSinceReferenceDate ?? 0){
					continue
				}
				
				latest = i
			}
			
			Self.cachedRelease = latest ?? rawValue.first
			return latest ?? rawValue.first!
		}
		
		func getLatestPreRelease() -> Release? {
			if let cached = Self.cachedRelease {
				return cached
			}else if (Self.preReleaseAvailable ?? false){
				return nil
			}
			
			var latest: Release? = nil
			
			for i in rawValue{
				if !i.prerelease{
					continue
				}
				
				guard let last = latest else {
					latest = i
					continue
				}
				
				if ((last.published_at ?? last.created_at).date()?.timeIntervalSinceReferenceDate ?? 0) > ((i.published_at ?? i.created_at).date()?.timeIntervalSinceReferenceDate ?? 0){
					continue
				}
				
				latest = i
			}
			
			Self.cachedRelease = latest
			return latest
		}
		
		
		typealias T = Release
		
		struct Release: RemoteUpdateVersionProtocol, GitHubNamedItemProtocol{
			
			struct User: GitHubItemProtocol{
				let login: String
				let id: UInt64
				let node_id: String
				let url: URL
				let html_url: URL?
				let gravatar_id: String
				let followers_url: URL
				let following_url: URL
				let gists_url: URL
				let starred_url: URL
				let subscriptions_url: URL
				let organizations_url: URL
				let repos_url: URL
				let events_url: URL
				let received_events_url: URL
				let type: String
				let site_admin: Bool
			}
			
			struct Asset: GitHubNamedItemProtocol{
				let name: String
				let id: UInt64
				let node_id: String
				let html_url: URL?
				let url: URL
				let label: String?
				let uploader: User
				let content_type: String
				let state: String
				let size: UInt64
				let download_count: UInt64
				let created_at: ISODate
				let updated_at: ISODate
				let browser_download_url: URL
			}
			
			struct ISODate: RawRepresentable, Codable, Equatable{
				var rawValue: String
				
				typealias RawValue = String
				
				func date() -> Date?{
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
					return dateFormatter.date(from: rawValue)
				}
			}
			
			let url: URL
			let assets_url: URL
			let upload_url: URL
			let html_url: URL?
			let id: UInt64
			
			let author: User
			
			let node_id: String
			let tag_name: String
			let target_commitish: String
			let name: String
			let draft: Bool
			let prerelease: Bool
			let created_at: ISODate
			let published_at: ISODate?
			
			let assets: [Asset]
			
			let tarball_url: URL
			let zipball_url: URL
			
			let body: String
			
			let reactions: [String: UInt64]
			
			func getDirectDownloadUrl() -> URL? {
				return self.assets.first?.browser_download_url
			}
			
			
			
			
		}
		
		
	}
}
