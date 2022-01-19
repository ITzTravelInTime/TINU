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

public class OtherOptionsInfoViewController: GenericViewController, ViewID {
	
	public let id: String = "OtherOptionsInfoViewController"
	
	@IBOutlet var textView: NSTextView!
	
	@IBOutlet weak var button: NSButton!
	
	@IBOutlet weak var scroller: NSScrollView!
	
	public var optionID: CreationProcess.OptionsManager.ID!
	
	private var associatedOption: CreationProcess.OptionsManager.Object!{
		return CreationProcess.shared.options.list[optionID]
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
		scroller.borderType = .bezelBorder
		
		self.setTitleLabel(text: "")
		showTitleLabel()
		
		if let option = associatedOption{
			titleLabel.stringValue = TextManager.getViewString(context: self, stringID: "infoPrefix") + option.description.title
			
			if let desc = associatedOption?.description{
				textView.text = desc.desc
			}
		}
		
		textView.textColor = NSColor.textColor
		
	}
	
	override public func viewDidAppear() {
		super.viewDidAppear()
		
		textView.textColor = NSColor.textColor
		
		if associatedOption == nil{
			goBack()
		}
		
		self.window.minSize = CGSize(width: 620, height: 300)
	}
	
	@IBAction func buttonClick(_ sender: Any) {
		
		goBack()
	}
	
	@inline(__always) func goBack(){
		//CustomizationWindowManager.shared.referenceWindow = self.window.sheetParent
		CustomizationWindowManager.shared.referenceWindow.endSheet(self.window!)
	}
	
	/*override func viewDidSetVibrantLook() {
		if canUseVibrantLook {
			scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
			scroller.borderType = .noBorder
			//scroller.drawsBackground = false
		}else{
			scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
			scroller.borderType = .bezelBorder
			//scroller.drawsBackground = true
		}
	}*/
}
