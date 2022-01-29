//
//  UpdatesSubmenu.swift
//  TINU
//
//  Created by ITzTravelInTime on 28/01/22.
//  Copyright © 2022 Pietro Caruso. All rights reserved.
//

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
