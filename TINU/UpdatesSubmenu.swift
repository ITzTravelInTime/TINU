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
		
		sendUpdateNotificationSwitcher.state = UpdateManager.displayNotification ? .on : .off
		
		checkForUpdatesAndSetMenuItems()
	}
	
	private func checkForUpdatesAndSetMenuItems(){
		DispatchQueue.global(qos: .background).async {
			guard let update: UpdateManager.Default = UpdateManager.Default.getUpdateData() else{
				DispatchQueue.main.sync {
					self.openReleaseUpdatePage.isEnabled = false
					self.openPreReleaseUpdatePage.isEnabled = false
				}
				return
			}
			
			DispatchQueue.main.sync {
				
				self.openReleaseUpdatePage.isEnabled    = update.getLatestRelease().isNewerVersion() || App.isPreRelase
				
				self.openPreReleaseUpdatePage.isEnabled = update.getLatestPreRelease()?.isNewerVersion() ?? false
			}
			
			
		}
	}
	
	@IBAction func checkForUpdates(_ sender: Any) {
		UpdateManager.Default.getUpdateData(forceRefetch: true)?.update.checkAndSendUpdateNotification(sendNotificatinAlways: true)
		checkForUpdatesAndSetMenuItems()
	}
	
	@IBAction func openReleaseUpdatePage(_ sender: Any) {
		UpdateManager.Default.getUpdateData()?.getLatestRelease().openWebPageOrDirectDownload()
	}
	
	@IBAction func openPreReleaseUpdatePage(_ sender: Any) {
		UpdateManager.Default.getUpdateData()?.getLatestPreRelease()?.openWebPageOrDirectDownload()
	}
	
	@IBAction func switchUpdateNotificationStatus(_ sender: Any){
		
		UpdateManager.displayNotification.toggle()
		App.Settings.setBool(key: App.Settings.Keys.sendUpdateNotifications, variable: UpdateManager.displayNotification)
		
		sendUpdateNotificationSwitcher.state = UpdateManager.displayNotification ? .on : .off
	}
}
