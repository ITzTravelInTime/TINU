//
//  AppDownloadViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 17/03/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

fileprivate struct App_download: Equatable{
	var name: String
	var version: String
	var DownloadLink: String
	var DownloadLinkAlternate: String!
	var image: NSImage
}

public class DownloadAppViewController: ShadowViewController {

	@IBOutlet weak var closeButton: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
    @IBOutlet weak var spinner: NSProgressIndicator!
	
	private var plain: NSView!
    
	override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
        spinner.startAnimation(self)
        
		self.setTitleLabel(text: "Download a macOS installer")
		
		self.showTitleLabel()
		
		self.setShadowViewsTopBottomOnly(respectTo: scroller, topBottomViewsShadowRadius: 5)
		
		setOtherViews(respectTo: scroller)
		
		self.scroller.hasHorizontalScroller = false
        
		let apps: [App_download] = [
			App_download(name: "macOS Catalina", version: "10.15.x", DownloadLink: "macappstores://itunes.apple.com/app/macos-catalina/id1466841314", DownloadLinkAlternate: nil, image: NSImage(named: "Catalina")!),
			App_download(name: "macOS Mojave", version: "10.14.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-mojave/id1398502828", DownloadLinkAlternate: nil, image: NSImage(named: "Mojave")!),
			App_download(name: "macOS High Sierra", version: "10.13.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-high-sierra/id1246284741", DownloadLinkAlternate: nil, image: NSImage(named: "High_Sierra")!),
			App_download(name: "macOS Sierra", version: "10.12.6", DownloadLink: "macappstores://itunes.apple.com/app/macos-sierra/id1127487414", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg", image: NSImage(named: "Sierra")!),
			App_download(name: "Mac OS X El Capitan", version: "10.11.6", DownloadLink: "macappstores://itunes.apple.com/app/os-x-el-capitan/id1147835434", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg", image: NSImage(named: "El_Capitan")!)
			//this download is just a .pkg thing, not usable with tinu
			/*,App_download(name: "Mac OS X Yosemite", version: "10.10.6", DownloadLink: "", DownloadLinkAlternate: "http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg", image: NSImage(named: "Yosemite")!)*/
		]
		
		let segmentHeight: CGFloat = 100
		plain = NSView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 24, height: segmentHeight * CGFloat(apps.count)))
		
		var tmp: CGFloat = 0
		for app in apps.reversed(){
			let segment = DownloadAppItem(frame: CGRect(x: 0, y: tmp, width: plain.frame.size.width, height: segmentHeight))
			
			segment.isLast = (app == apps.last!)
			
			segment.associtaed = app
			
			plain.addSubview(segment)
			
			tmp += segmentHeight
		}
		
		
    }
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		if self.presenting == nil{
		//if self.window != sharedWindow{
			closeButton.stringValue = "Close"
			closeButton.title = "Close"
			closeButton.alternateTitle = "Close"
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
		if self.presenting == nil{
			self.window.close()
		}else{
			self.window.sheetParent?.endSheet(self.window)
		}
	}
}

fileprivate class DownloadAppItem: NSView{
	public var associtaed: App_download!
	public var isLast: Bool = false
	
	private var link: URL!
	
	private let name = NSTextField()
	private let version = NSTextField()
	private let icon = NSImageView()
	private let downloadButton = NSButton()
	private let separator = NSView()
	
	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		
		icon.frame.size = NSSize(width: 70, height: 70)
		icon.frame.origin = NSPoint(x: 5, y: (self.frame.height - icon.frame.height) / 2)
		icon.imageAlignment = .alignCenter
		icon.imageScaling = .scaleProportionallyUpOrDown
		icon.isEditable = false
		
		icon.image = associtaed.image
		
		self.addSubview(icon)
		
		name.frame.size = NSSize(width: 250, height: 17)
		name.frame.origin = NSPoint(x: icon.frame.origin.x + icon.frame.size.width + 5, y: icon.frame.origin.y + 30)
		
		name.isEditable = false
		name.isSelectable = false
		name.drawsBackground = false
		name.isBordered = false
		name.isBezeled = false
		name.alignment = .left
		
		name.stringValue = associtaed.name
		
		name.font = NSFont.systemFont(ofSize: NSFont.systemFontSize())
		
		self.addSubview(name)
		
		version.frame.size = NSSize(width: 250, height: 17)
		version.frame.origin = NSPoint(x: icon.frame.origin.x + icon.frame.size.width + 5, y: icon.frame.origin.y + 10)
		
		version.isEditable = false
		version.isSelectable = false
		version.drawsBackground = false
		version.isBordered = false
		version.isBezeled = false
		version.alignment = .left
		
		version.stringValue = associtaed.version
		
		version.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize())
		
		self.addSubview(version)
		
		var isAlternate = false
			
		if #available(OSX 10.14, *){
			isAlternate = true
		}
		
		isAlternate = (isAlternate && (associtaed.DownloadLinkAlternate != nil)) || (associtaed.DownloadLink == "")
		
		if isAlternate{
			downloadButton.title = "Download from Apple"
			link = URL(string: associtaed.DownloadLinkAlternate!)
		}else{
			downloadButton.title = "View in the App Store"
			link = URL(string: associtaed.DownloadLink)
		}
		
		downloadButton.bezelStyle = .roundRect
		downloadButton.setButtonType(.momentaryPushIn)
		
		downloadButton.frame.size = NSSize(width: 150, height: 20)
		
		downloadButton.frame.origin = NSPoint(x: self.frame.size.width - downloadButton.frame.size.width - 5, y: (self.frame.size.height - downloadButton.frame.height) / 2)
		
		downloadButton.font = NSFont.systemFont(ofSize: 12)
		downloadButton.isContinuous = true
		downloadButton.target = self
		downloadButton.action = #selector(self.downloadApp(_:))
		
		self.addSubview(downloadButton)
		
		if !isLast{
		separator.frame.origin = CGPoint(x: 30, y: 1)
		separator.frame.size = CGSize(width: self.frame.width - 60, height: 1)
		separator.wantsLayer = true
		separator.layer?.borderColor = NSColor.lightGray.cgColor
		separator.layer?.borderWidth = 1
		
		self.addSubview(separator)
		}
		
	}
	
	@objc func downloadApp(_ sender: Any){
		if link!.pathExtension == "dmg"{
			if dialogCustomWarning(question: "Remeber to open the download", text: "The intaller file you are about to download will need to be opened after being downloaded in order to be usable with TINU", mainButtonText: "Continue", secondButtonText: "Cancel"){
				return
			}
			
		}
		
		NSWorkspace.shared().open(link!)
	}
}
