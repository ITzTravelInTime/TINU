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

import Cocoa
import TINURecovery

class UpdatesSubmenu: NSMenu {
	
	@IBOutlet weak var checkForUpdatesMenuItem: NSMenuItem!
	@IBOutlet weak var openReleaseUpdatePage: NSMenuItem!
	@IBOutlet weak var openPreReleaseUpdatePage: NSMenuItem!
	@IBOutlet weak var sendUpdateNotificationSwitcher: NSMenuItem!
	
	override func update() {
		super.update()
		
		if Recovery.status{
			checkForUpdatesMenuItem.isEnabled = false
			openReleaseUpdatePage.isEnabled = false
			openPreReleaseUpdatePage.isEnabled = false
			sendUpdateNotificationSwitcher.isEnabled = false
			return
		}
		
		checkForUpdatesMenuItem.isEnabled = true
		openReleaseUpdatePage.isEnabled = false
		openPreReleaseUpdatePage.isEnabled = false
		sendUpdateNotificationSwitcher.isEnabled = true
		
		sendUpdateNotificationSwitcher.state = UpdateManager.shoudDisplayUpdateNotification ? .on : .off
		
		checkForUpdatesAndSetMenuItems()
	}
	
	private func checkForUpdatesAndSetMenuItems(){
		DispatchQueue.global(qos: .background).async {
			let update = UpdateManager.getUpdateData()
			
			DispatchQueue.main.sync {
				if let canRelease = update?.stable.shouldUpdateToThisBuild(){
					self.openReleaseUpdatePage.isEnabled = canRelease || App.isPreRelase
				}else{
					self.openReleaseUpdatePage.isEnabled = false
				}
				
				if let canPreRelease = update?.pre_release?.shouldUpdateToThisBuild(){
					self.openPreReleaseUpdatePage.isEnabled = canPreRelease
				}else{
					self.openPreReleaseUpdatePage.isEnabled = false
				}
			}
			
			
		}
	}
	
	@IBAction func checkForUpdates(_ sender: Any) {
		UpdateManager.getUpdateData(forceRefetch: true)?.update.checkAndSendUpdateNotification(shouldSendUpToDateNotification: true, shouldSendUpdateNotificationAnyway: true)
		checkForUpdatesAndSetMenuItems()
	}
	
	@IBAction func openReleaseUpdatePage(_ sender: Any) {
		UpdateManager.getUpdateData()?.stable.openWebPageOrDirectDownload()
	}
	
	@IBAction func openPreReleaseUpdatePage(_ sender: Any) {
		UpdateManager.getUpdateData()?.pre_release?.openWebPageOrDirectDownload()
	}
	
	@IBAction func switchUpdateNotificationStatus(_ sender: Any){
		
		UpdateManager.shoudDisplayUpdateNotification.toggle()
		App.Settings.setBool(key: App.Settings.Keys.sendUpdateNotifications, variable: UpdateManager.shoudDisplayUpdateNotification)
		
		sendUpdateNotificationSwitcher.state = UpdateManager.shoudDisplayUpdateNotification ? .on : .off
	}
}
