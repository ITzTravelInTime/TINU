//
//  GenericViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/10/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

// This is used to manage the geric vcs of this app
import Cocoa

public class GenericViewController: NSViewController {
	
	let copyright = CopyrightLabel()
	
	var failureImageView: NSImageView!
	var failureLabel: NSTextField!
	var failureButtons: [NSButton] = []
	
	var titleLabel: NSTextField!
	
	func setTitleLabel(text: String){
		titleLabel = NSTextField()
		
		titleLabel.stringValue = text
		
		titleLabel.isEditable = false
		titleLabel.isSelectable = false
		titleLabel.drawsBackground = false
		titleLabel.isBordered = false
		titleLabel.isBezeled = false
		titleLabel.alignment = .center
		
		titleLabel.frame.origin.x = 18
		titleLabel.frame.size.height = 24
		
		titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
	}
	
	func showTitleLabel(){
		if let label = titleLabel{
			label.frame.size.width = self.view.frame.width - CGFloat(36)
			label.frame.origin.y = self.view.frame.height - 44
			label.isHidden = false
			label.autoresizingMask = [.viewWidthSizable, .viewMinYMargin, .viewMinXMargin, .viewMaxXMargin]
			self.view.addSubview(label)
		}
	}
	
	func hideTitleLabel(){
		if let label = titleLabel{
			label.isHidden = true
		}
	}
	
	func setFailureLabel(text: String){
		failureLabel = NSTextField()
		
		failureLabel.stringValue = text
		
		failureLabel.isEditable = false
		failureLabel.isSelectable = false
		failureLabel.drawsBackground = false
		failureLabel.isBordered = false
		failureLabel.isBezeled = false
		failureLabel.alignment = .center
		
		failureLabel.frame.origin.y = 114
        
		failureLabel.frame.origin.x = 18
		failureLabel.frame.size.height = 24
		
		failureLabel.font = NSFont.systemFont(ofSize: 16)
	}
	
	func showFailureLabel(){
		if let label = failureLabel{
			label.frame.size.width = self.view.frame.width - 36.0
			label.isHidden = false
			self.view.addSubview(label)
		}
	}
	
	func hideFailureLabel(){
		if let label = failureLabel{
			label.isHidden = true
		}
	}
	
	func setFailureImage(image: NSImage){
		failureImageView = NSImageView()
		failureImageView.isEditable = false
		failureImageView.imageAlignment = .alignCenter
		failureImageView.imageScaling = .scaleProportionallyUpOrDown
		failureImageView.image = image
		
		failureImageView.frame.size.width = 134
		failureImageView.frame.size.height = 134
		
		failureImageView.frame.origin.y = 144
	}
	
	func showFailureImage(){
		if let imageView = failureImageView{
			imageView.frame.origin.x = self.view.frame.size.width / 2.0 - imageView.frame.size.width / 2.0
			imageView.isHidden = false
			self.view.addSubview(imageView)
		}
	}
	
	func hideFailureImage(){
		if let imageView = failureImageView{
			imageView.isHidden = true
		}
	}
	
	func addFailureButton(buttonTitle: String, target: AnyObject, selector: Selector){
		let newButton = NSButton()
		newButton.target = target
		newButton.action = selector
		
		newButton.isContinuous = true
		
		newButton.bezelStyle = .texturedSquare
		newButton.setButtonType(.momentaryPushIn)
		
		newButton.title = buttonTitle
		
		newButton.frame.size.height = 32
		newButton.font = NSFont.systemFont(ofSize: 14)
        
        newButton.frame.origin.y = 70
		
		failureButtons.append(newButton)
	}
	
	func showFailureButtons(){
		let floatCount = CGFloat(failureButtons.count)
		let width: CGFloat = (floatCount == 1) ? 350 : 200
		let space = CGFloat(10)
		var tmpX = (self.view.frame.width - ((width * floatCount) + (space * (floatCount - 1)))) / 2.0
		for button in failureButtons{
			button.frame.origin.x = tmpX
			button.frame.size.width = width
			tmpX += width + space
			button.isHidden = false
			self.view.addSubview(button)
		}
        
        
        
	}
	
	func hideFailureButtons(){
		for button in failureButtons{
			button.isHidden = true
		}
	}
    
	override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //viewDidSetVibrantLook()
		
		if self.view.layer == nil{
			self.view.wantsLayer = true
		}
		
		self.view.addSubview(copyright)
		
		copyright.awakeFromNib()
    }
    
	override public func viewDidAppear() {
        //viewDidSetVibrantLook()
		
    }
	
    /**Function called when the aspect mode of tyhe window is changed, you can override it as well, just remember to call super.viewDidSetVibrantLook()*/
    /*func viewDidSetVibrantLook(){
        if canUseVibrantLook && sharedUseFocusArea{
            if styleView == nil{
                styleView = NSView.init(frame: CGRect.init(x: 0, y: 73, width: self.view.frame.width, height: 205))
                styleView.backgroundColor = NSColor.white
                self.view.addSubview(styleView, positioned: .below, relativeTo: self.view)
            }else{
                styleView.frame = CGRect.init(x: 0, y: 73, width: self.view.frame.width, height: 205)
                styleView.backgroundColor = NSColor.white
                self.view.addSubview(styleView, positioned: .below, relativeTo: self.view)
                for cc in self.view.subviews{
                    if let c = cc as? NSVisualEffectView{
                        self.view.addSubview(c, positioned: .below, relativeTo: self.view)
                    }
                }
                styleView.isHidden = false
            }
            
        }else{
            if styleView != nil{
                styleView.isHidden = true
            }
        }
    }*/
	
	/*
	override public func presentViewControllerAsSheet(_ viewController: NSViewController) {

		if let win = self.window.windowController as? GenericWindowController{
				win.deactivateVibrantWindow()
		}

		
		super.presentViewControllerAsSheet(viewController)
	}*/
	
	/*
	override public func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier,
											sender: Any?) -> Bool{
		if sharedUseVibrant{
			if let w =  self.window.windowController as? GenericWindowController{
				w.deactivateVibrantWindow()
			}
		}
		
		return true
	}*/
	
	/*
	override public func viewWillDisappear() {
		if sharedUseVibrant{
			if let w = sharedWindow.windowController as? GenericWindowController{
				w.activateVibrantWindow()
			}
		}
	}
*/
	
}
