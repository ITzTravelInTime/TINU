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

fileprivate struct AppDownloadManager: CodableDefaults, Codable, Equatable{
	fileprivate struct AppDownload: Codable, Equatable{
		var name: String
		var version: String
		var DownloadLink: String
		var DownloadLinkAlternate: String!
		var image: String!
		var imageURL: URL!
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
		
		self.plain = NSView(frame: CGRect(x: 0, y: 0, width: self.scroller.frame.width - 15, height: 10))
		
		self.plain.backgroundColor = self.scroller.backgroundColor//NSColor.windowBackgroundColor
		//scroller.backgroundColor = plain.backgroundColor
		//scroller.contentView.backgroundColor = plain.backgroundColor
		
		DispatchQueue.global(qos: .background).async {
			let apps = AppDownloadManager.init(fromRemoteFileAtUrl: RemoteResourcesURLsManager.list["installerAppDownloads"] ?? "")?.downloads ??  AppDownloadManager.init()!.downloads//.createFromDefaultFile()!.downloads
			
			DispatchQueue.main.sync {
				
				let segmentHeight: CGFloat = 100
				let segmentOffset: CGFloat = 20
				let segmentEdge:   CGFloat = 15
				
				//self.plain = NSView(frame: CGRect(x: 0, y: 0, width: self.scroller.frame.width - 15, height: (segmentHeight + segmentOffset) * CGFloat(apps.count) + segmentOffset))
				
				self.plain?.frame.size.height = (segmentHeight + segmentOffset) * CGFloat(apps.count) + segmentOffset
				
				var tmp: CGFloat = segmentOffset
				for app in apps.reversed(){
					let segment = DownloadAppItem(frame: CGRect(x: segmentEdge, y: tmp, width: self.plain.frame.size.width - segmentOffset, height: segmentHeight))
					
					//segment.isLast = (app == apps.last!)
					
					segment.associtaed = app
					
					self.plain.addSubview(segment)
					
					tmp += segmentHeight + segmentOffset
				}
				
				if self.presentingViewController == nil{
				//if self.window != sharedWindow{
					self.closeButton.title = TextManager.getViewString(context: self, stringID: "backButton")
					self.closeButton.image = NSImage(named: NSImage.stopProgressTemplateName)
				}else{
					self.closeButton.image = NSImage(named: NSImage.goLeftTemplateName)
				}
				
				self.scroller.documentView = self.plain!
				
				self.spinner.stopAnimation(self)
				self.spinner.isHidden = true
				
				self.window.maxSize = CGSize(width: self.view.frame.width, height: self.plain.frame.height + self.scroller.frame.origin.y + (self.view.frame.size.height - self.scroller.frame.origin.y - self.scroller.frame.size.height))
				self.window.minSize = CGSize(width: self.view.frame.width, height: 300)
				
			}
		}
		
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
			if !dialogWithManager(self, name: "downloadDialog"){
				return
			}
			
		}
		
		NSWorkspace.shared.open(link!)
	}
}
