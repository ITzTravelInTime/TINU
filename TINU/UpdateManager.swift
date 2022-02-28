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
	
	typealias Default = GithubStruct
	
	struct CacheItem{
		var info: Any
		var cachedPreRelease: RemoteUpdateVersionProtocol?
		var cachedRelease: RemoteUpdateVersionProtocol?
	}
	
	static var displayNotification: Bool = true
	static var updateCacheData: [String: CacheItem] = [:]
	
}
