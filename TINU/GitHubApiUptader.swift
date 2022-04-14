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

extension UpdateManager{
	struct GithubStruct: RemoteUpdateProtocol{
		
		let releases: [Release]
		
		static var classID: String{
			return "GitHubUpdateStructV2"
		}
		
		static var fetchURL: URL?{
			if let str =  RemoteResourcesURLsManager.list["GitHubApiUpdates"]{
				return URL(string: str)
			}
			
			return nil
		}
		
		func getLatestRelease() -> Release {
			assert(!releases.isEmpty)
			
			let sorted = releases.versionSorted()
			
			var ret = sorted.last!
			
			for i in sorted{
				if i.build > ret.build{
					ret = i
				}
			}
			
			return ret
		}
		
		func getLatestPreRelease() -> Release? {
			var ret: Release?
			
			for i in releases.versionSorted() where i.isPreRelease{
				
				if i.build > ret?.build ?? 0{
					ret = i
				}
			}
			
			return ret
		}
		
		init?(fromRemoteTextAt url: URL, descapeCharacters: Bool) {
			guard let list = [[String: Any]].init(fromRemoteFileAt: url, descapeCharacters: descapeCharacters) else{
				return nil
			}
			
			if list.isEmpty{
				return nil
			}
			
			var rel = [Release]()
			
			for i in list{
				guard let release = Release(fromDictionary: i) else{
					return nil
				}
				
				rel.append(release)
			}
			
			releases = rel
		}
		
		init?(fromRemoteTextAt url: URL) {
			self.init(fromRemoteTextAt: url, descapeCharacters: false)
		}
		
		
		struct Release: RemoteUpdateVersionProtocol{
			let name: String
			
			let body: String
			
			let html_url: String?
			let assetUrl: URL
			
			let tag_name: String
			
			let build: UInt
			let isPreRelease: Bool
			
			func getDirectDownloadUrl() -> URL? {
				return assetUrl
			}
			
			init?(fromDictionary dict: [String: Any]){
				if let url = dict["html_url"] as? String{
					self.html_url = url
				}else{
					self.html_url = nil
				}
				
				if let name = dict["name"] as? String{
					self.name = name
				}else{
					return nil
				}
				
				if let body = dict["body"] as? String{
					self.body = body
				}else{
					return nil
				}
				
				if let pre = dict["prerelease"] as? Bool{
					self.isPreRelease = pre
				}else{
					return nil
				}
				
				if let tag = dict["tag_name"] as? String{
					self.tag_name = tag
					
					if tag.contains("(") && tag.last! == ")"{
						guard let bbtag = tag.split(separator: "(").last else{
							return nil
						}
						
						var btag = "\(bbtag)"
						
						btag.removeLast()
						
						guard let bld = btag.uIntValue else{
							return nil
						}
						
						self.build = bld
					}else if tag == "10_PUBLIC"{
						
						self.build = 1
						
					}else{
						guard let bbtag = tag.split(separator: "_").last else{
							return nil
						}
							
						let btag = "\(bbtag.last!)"
						
						guard let bld = btag.uIntValue else{
							return nil
						}
						
						self.build = bld
					}
					
				}else{
					return nil
				}
				
				if let assets = dict["assets"] as? [[String: Any]] {
					
					if assets.isEmpty{
						return nil
					}
					
					var link: URL?
					
					for i in assets{
						guard let type = i["content_type"] as? String else{
							continue
						}
						
						if !type.lowercased().contains("application"){
							continue
						}
						
						guard let url = i["browser_download_url"] as? String else{
							continue
						}
						
						link = URL(string: url)
					}
					
					if let l = link{
						self.assetUrl = l
					}else{
						return nil
					}
					
				}else{
					return nil
				}
				
			}
		}
	}
}

extension Array where Element == UpdateManager.GithubStruct.Release{
	func versionSorted() -> Self{
		return self.sorted(by: { $0.build <= $1.build })
	}
	
	mutating func versionSort(){
		self = self.versionSorted()
	}
}

/*
extension UpdateManager{
	struct GitHubApiUpdateStruct: RemoteUpdateProtocol, RawRepresentable{
		init?(fromRemoteTextAt url: URL) {
			self.init(fromRemoteTextAt: url, descapeCharacters: false)
		}
		
		init?(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
		var rawValue: RawValue
		
		typealias RawValue = [Release]
		
		init?(fromRemoteTextAt url: URL, descapeCharacters: Bool){
			guard let value = RawValue.init(fromRemoteFileAt: url, descapeCharacters: descapeCharacters) else{
				return nil
			}
			
			self.init(rawValue: value)
		}
		
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
			
			//var latest: Release? = nil
			/*
			for i in rawValue{
				if i.prerelease{
					continue
				}
				
				guard let last = latest else {
					latest = i
					continue
				}
				
				/*
				if ((last.published_at ?? last.created_at).date()?.timeIntervalSinceReferenceDate ?? 0) > ((i.published_at ?? i.created_at).date()?.timeIntervalSinceReferenceDate ?? 0){
					continue
				}*/
				
				latest = i
			}
			
			Self.cachedRelease = latest ?? rawValue.first
			return latest ?? rawValue.first!
			 */
			
			return rawValue.first!
		}
		
		func getLatestPreRelease() -> Release? {
			if let cached = Self.cachedRelease {
				return cached
			}else if (Self.preReleaseAvailable ?? false){
				return nil
			}
			
			//var latest: Release? = nil
			
			/*
			for i in rawValue{
				if !i.prerelease{
					continue
				}
				
				guard let last = latest else {
					latest = i
					continue
				}
				
				/*
				if ((last.published_at ?? last.created_at).date()?.timeIntervalSinceReferenceDate ?? 0) > ((i.published_at ?? i.created_at).date()?.timeIntervalSinceReferenceDate ?? 0){
					continue
				}*/
				
				latest = i
			}
			
			Self.cachedRelease = latest
			return latest
			 */ return rawValue.first
		}
		
		
		struct Release: RemoteUpdateVersionProtocol, RawRepresentable{
			init?(rawValue: [String : Any]) {
				self.rawValue = rawValue
			}
			
			typealias RawValue = [String: Any]
			
			var name: String{
				return rawValue["name"]! as! String
			}
			
			var body: String{
				return rawValue["body"]! as! String
			}
			
			var html_url: String?{
				return rawValue["html_url"] as? String
			}
			
			var tag_name: String{
				return rawValue["tag_name"]! as! String
			}
			
			func getDirectDownloadUrl() -> URL? {
				return URL(string: self.url)
			}
			
			var id: UInt64{
				return rawValue["id"]! as! UInt64
			}
			
			var node_id: String{
				return rawValue["node_id"]! as! String
			}
			
			var url: String {
				return rawValue["url"]! as! String
			}
			
			var rawValue: RawValue
		}
		
		typealias T = Release
		
	}
}
*/
