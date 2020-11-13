//
//  AppDownloadViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 17/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate struct AppDownloadManager: CodableDefaults, Codable, Equatable{
	fileprivate struct AppDownload: Codable, Equatable{
		var name: String
		var version: String
		var DownloadLink: String
		var DownloadLinkAlternate: String!
		var image: String!
	}
	
	let downloads: [AppDownload]
	
	static let defaultResourceFileName = "AppDownloads"
	static let defaultResourceFileExtension = "json"
}


public class DownloadAppViewController: ShadowViewController, ViewID {
	
	public let id: String = "DownloadAppViewController"

	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
    @IBOutlet weak var spinner: NSProgressIndicator!
	
	private var plain: NSView!
    
	override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
        spinner.startAnimation(self)
        
		self.setTitleLabel(text: TextManager.getViewString(context: self, stringID: "title"))
		
		self.showTitleLabel()
		
		self.setShadowViewsTopBottomOnly(respectTo: scroller, topBottomViewsShadowRadius: 5)
		
		setOtherViews(respectTo: scroller)
		
		self.scroller.hasHorizontalScroller = false
		
		/*
		
		let apps: [AppDownloadManager.AppDownload] = [
			AppDownloadManager.AppDownload(name: "macOS Catalina", version: "10.15.x", DownloadLink: "macappstores://itunes.apple.com/app/macos-catalina/id1466841314", DownloadLinkAlternate: nil, image: "Catalina"),
			AppDownloadManager.AppDownload(name: "macOS Mojave", version: "10.14.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-mojave/id1398502828", DownloadLinkAlternate: nil, image: "Mojave"),
			AppDownloadManager.AppDownload(name: "macOS High Sierra", version: "10.13.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-high-sierra/id1246284741", DownloadLinkAlternate: nil, image: "High_Sierra"),
			AppDownloadManager.AppDownload(name: "macOS Sierra", version: "10.12.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-sierra/id1127487414", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg", image: "Sierra"),
			AppDownloadManager.AppDownload(name: "Mac OS X El Capitan", version: "10.11.6", DownloadLink: "macappstores://itunes.apple.com/app/os-x-el-capitan/id1147835434", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg", image: "El_Capitan")
			//this download is just a .pkg thing, not usable with tinu
			/*,App_download(name: "Mac OS X Yosemite", version: "10.10.6", DownloadLink: "", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg", image: NSImage(named: "Yosemite")!)*/
		]
		
		print(AppDownloadManager(downloads: apps).getEncoded()!)
		*/
		
		let apps = CodableCreation<AppDownloadManager>.createFromDefaultFile()!.downloads
		let segmentHeight: CGFloat = 100
		let segmentOffset: CGFloat = 20
		let segmentEdge:   CGFloat = 15
		
		plain = NSView(frame: CGRect(x: 0, y: 0, width: self.scroller.frame.width - 15, height: (segmentHeight + segmentOffset) * CGFloat(apps.count) + segmentOffset))
		
		var tmp: CGFloat = segmentOffset
		for app in apps.reversed(){
			let segment = DownloadAppItem(frame: CGRect(x: segmentEdge, y: tmp, width: plain.frame.size.width - segmentOffset, height: segmentHeight))
			
			//segment.isLast = (app == apps.last!)
			
			segment.associtaed = app
			
			plain.addSubview(segment)
			
			tmp += segmentHeight + segmentOffset
		}
		
		plain.backgroundColor = NSColor.windowBackgroundColor
		scroller.backgroundColor = plain.backgroundColor
		
		
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		if self.presentingViewController == nil{
		//if self.window != sharedWindow{
			closeButton.title = TextManager.getViewString(context: self, stringID: "backButton")
		}
		
		self.scroller.documentView = plain!
		
		spinner.stopAnimation(self)
		spinner.isHidden = true
	}
	
	/*
	override func viewDidSetVibrantLook() {
		super.viewDidSetVibrantLook()
		
	}
	*/

	@IBAction func buttonClick(_ sender: Any) {
		if self.presentingViewController == nil{
			self.window.close()
		}else{
			self.window.sheetParent?.endSheet(self.window)
		}
	}
}

fileprivate class DownloadAppItem: ShadowView, ViewID{
	let id: String = "DownloadAppItem"
	public var associtaed: AppDownloadManager.AppDownload!
	//public var isLast: Bool = false
	
	private var link: URL!
	
	private let name = NSTextField()
	private let version = NSTextField()
	private let icon = NSImageView()
	private let downloadButton = NSButton()
	private let separator = NSView()
	
	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		
		canShadow = true
		
		icon.frame.size = NSSize(width: 70, height: 70)
		icon.frame.origin = NSPoint(x: 5, y: (self.frame.height - icon.frame.height) / 2)
		icon.imageAlignment = .alignCenter
		icon.imageScaling = .scaleProportionallyUpOrDown
		icon.isEditable = false
		
		icon.image = NSImage(named: associtaed.image)!
		
		self.addSubview(icon)
		
		name.frame.size = NSSize(width: 250, height: 25)
		name.frame.origin = NSPoint(x: icon.frame.origin.x + icon.frame.size.width + 5, y: icon.frame.origin.y + icon.frame.size.height - name.frame.size.height )
		
		name.isEditable = false
		name.isSelectable = false
		name.drawsBackground = false
		name.isBordered = false
		name.isBezeled = false
		name.alignment = .left
		
		name.stringValue = associtaed.name
		
		//name.font = NSFont.systemFont(ofSize: NSFont.systemFontSize())
		name.font = NSFont.boldSystemFont(ofSize: 18)
		
		self.addSubview(name)
		
		version.frame.size = NSSize(width: 250, height: 17)
		version.frame.origin = NSPoint(x: name.frame.origin.x, y: name.frame.origin.y - version.frame.size.height - 5)
		
		version.isEditable = false
		version.isSelectable = false
		version.drawsBackground = false
		version.isBordered = false
		version.isBezeled = false
		version.alignment = .left
		
		version.stringValue = associtaed.version
		
		version.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
		
		self.addSubview(version)
		
		var isAlternate = false
			
		if #available(OSX 10.14, *){
			isAlternate = true
		}
		
		isAlternate = (isAlternate && (associtaed.DownloadLinkAlternate != nil)) || (associtaed.DownloadLink == "")
		
		if isAlternate{
			downloadButton.title = TextManager.getViewString(context: self, stringID: "downloadButtonApple")
			link = URL(string: associtaed.DownloadLinkAlternate!)
		}else{
			downloadButton.title = TextManager.getViewString(context: self, stringID: "downloadButtonAppStore")
			link = URL(string: associtaed.DownloadLink)
		}
		
		//downloadButton.bezelStyle = .roundRect
		downloadButton.bezelStyle = .rounded
		downloadButton.setButtonType(.momentaryPushIn)
		
		downloadButton.frame.size = NSSize(width: 150, height: 30)
		
		//downloadButton.frame.origin = NSPoint(x: self.frame.size.width - downloadButton.frame.size.width - 5, y: (self.frame.size.height - downloadButton.frame.height) / 2)
		
		downloadButton.frame.origin = NSPoint(x: self.frame.size.width - downloadButton.frame.size.width - 7, y: 7)
		
		downloadButton.font = NSFont.systemFont(ofSize: 12)
		downloadButton.isContinuous = true
		downloadButton.target = self
		downloadButton.action = #selector(self.downloadApp(_:))
		
		self.addSubview(downloadButton)
		
		/*
		if !isLast{
		separator.frame.origin = CGPoint(x: 30, y: 1)
		separator.frame.size = CGSize(width: self.frame.width - 60, height: 1)
		separator.wantsLayer = true
		separator.layer?.borderColor = NSColor.lightGray.cgColor
		separator.layer?.borderWidth = 1
		
		self.addSubview(separator)
		}*/
		
	}
	
	@objc func downloadApp(_ sender: Any){
		if link!.pathExtension == "dmg"{
			//if dialogCustomWarning(question: "Remeber to open the download", text: "The intaller file you are about to download will need to be opened after being downloaded in order to be usable with TINU", mainButtonText: "Continue", secondButtonText: "Cancel"){
			if dialogWithManager(self, name: "downloadDialog"){
				return
			}
			
		}
		
		NSWorkspace.shared.open(link!)
	}
}
