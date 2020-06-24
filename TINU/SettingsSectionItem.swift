//
//  File.swift
//  TINU
//
//  Created by Pietro Caruso on 11/02/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class SettingsSectionItem: NSView{
	
	var image = NSImageView()
	var name = NSTextField()
	
	var isSelected = false
	
	var id = CustomizationViewController.SectionsID(rawValue: 0)!
	
	var itemsScrollView: NSScrollView?
	
	let normalColor = NSColor.white.withAlphaComponent(0).cgColor
	var selectedColor = NSColor.selectedControlColor.cgColor
	
	//category switching for code reuse, not the best place for this stuff, but here it requires the less work
	var bootLoaderType: SupportedEFIFolders = .clover
	var isAdvanced = false
	
	
	override public func draw(_ dirtyRect: NSRect) {
		
		/*
		if isSelected{
			self.backgroundColor = NSColor.selectedControlColor
		}else{
			self.backgroundColor = NSColor.white.withAlphaComponent(0)
		}
		*/
		
		image.frame.size = NSSize(width: (self.frame.size.width / 5) - 10, height: self.frame.height - 10)
		
		image.frame.origin = NSPoint(x: 5, y: 5)
		
		image.imageAlignment = .alignCenter
		image.imageScaling = .scaleProportionallyUpOrDown
		image.isEditable = false
		
		self.addSubview(image)
		
		var h: CGFloat = 18
		
		var n: CGFloat = 1
		
		for c in name.stringValue{
			if c == "\n"{
				n += 1
			}
		}
		
		h *= n
		
		name.frame.size = NSSize(width: (self.frame.size.width / 5) * 4 - 5, height: h)
		
		name.frame.origin = NSPoint(x: image.frame.origin.x + image.frame.size.width + 5, y: self.frame.height / 2 - name.frame.height / 2)
		
		name.isEditable = false
		name.isSelectable = false
		name.drawsBackground = false
		name.isBordered = false
		name.isBezeled = false
		name.alignment = .left
		
		name.font = NSFont.systemFont(ofSize: 13)
		
		self.addSubview(name)
		
		
		
	}
	
	override public func updateLayer() {
		super.updateLayer()
		
		selectedColor = NSColor.selectedControlColor.cgColor
		
		if isSelected{
			self.layer?.backgroundColor = selectedColor
		}else{
			self.layer?.backgroundColor = normalColor
		}
	}
	
	override public func mouseDown(with event: NSEvent) {
		makeSelected()
		addSettingsToScrollView()
	}
	
	public func makeSelected(){
		
		for vv in (self.superview?.subviews)!{
			if let v = vv as? SettingsSectionItem{
				if v != self{
					v.makeNormal()
				}
			}
		}
		
		isSelected = true
		
		updateLayer()
	}
	
	public func makeNormal(){
		isSelected = false
		
		updateLayer()
	}
	
	public func addSettingsToScrollView(){
		
		if let scrollView = itemsScrollView{
			
			scrollView.documentView = NSView()
			
			scrollView.verticalScroller?.isHidden = false
			
			switch id{
			case CustomizationViewController.SectionsID.generalOptions:
				let surface = NSView()
				let itemHeigth: CGFloat = 30
				var isGray = true
				
				surface.frame.origin = CGPoint.zero
				surface.frame.size = NSSize.init(width: scrollView.frame.size.width - 20, height: itemHeigth * (CGFloat(oom.shared.otherOptions.count)))
				
				var count: CGFloat = 0
				
				for i in oom.shared.otherOptions.sorted(by: { $0.0.rawValue > $1.0.rawValue }){
					if i.value.isVisible && (i.value.isAdvanced == isAdvanced){
						let item = OtherOptionsCheckBox(frame: NSRect(x: 0, y: count, width: surface.frame.size.width, height: itemHeigth))
						
						item.option = i.value
						
						isGray = !isGray
						
						count += itemHeigth
						
						surface.addSubview(item)
						
						//surface.frame.size = CGSize(width: surface.frame.size.width, height: surface.frame.size.height + itemHeigth)
					}else{
						surface.frame.size.height -= itemHeigth
					}
					
				}
				
				if surface.frame.height < scrollView.frame.height{
					let h = scrollView.frame.height - 2
					let w = scrollView.frame.width - 2
					let delta = (h - surface.frame.height)
					
					surface.frame.size.height = h
					surface.frame.size.width = w
					scrollView.hasVerticalScroller = false
					//scrollView.verticalScrollElasticity = .none
					scrollView.verticalScrollElasticity = .automatic
					
					for item in surface.subviews{
						item.frame.size.width = w
						item.frame.origin.y += delta
					}
				}else{
					scrollView.hasVerticalScroller = true
					scrollView.verticalScrollElasticity = .automatic
				}
				
				scrollView.documentView = surface
				
				
			/*case CustomizationViewController.SectionsID.bootFilesReplacement:
				
				#if !macOnlyMode
				
				let fieldHeigth: CGFloat = 16 * 5
				
				let surface = NSView()
				let itemHeigth: CGFloat = 36//scrollView.frame.size.height / CGFloat(filesToReplace.count) - 1
				
				surface.frame.size = NSSize.init(width: scrollView.frame.size.width - 20, height: itemHeigth * (CGFloat(BootFilesReplacementManager.shared.filesToReplace.count)) + fieldHeigth) //CGSize(width: scrollView.frame.size.width, height: 0)
				
				
				let textField = NSTextField()
				
				textField.isEditable = false
				textField.isSelectable = false
				textField.drawsBackground = false
				textField.isBordered = false
				textField.isBezeled = false
				textField.alignment = .left
				
				
				
				textField.stringValue = "This section allows you to choose customized boot files for the bootable macOS installer.\n\nHere is a list of the files you can customize: "
				
				surface.addSubview(textField)
				
				var count: CGFloat = 0//itemHeigth
				
				var isGray = true
				
				for i in BootFilesReplacementManager.shared.filesToReplace.reversed(){
					if i.visible{
						let item = BootFilesReplacementItem(frame: NSRect(x: 0, y: /*surface.frame.size.height surface.frame.height -*/ count, width: surface.frame.size.width, height: itemHeigth))
						
						item.isGray = isGray
						
						item.textField.stringValue = i.filename
						
						item.textField.textColor = NSColor.textColor
						
						item.replaceFile = i
						
						isGray = !isGray
						
						count += itemHeigth
						
						surface.addSubview(item)
						
						//surface.frame.size = CGSize(width: surface.frame.size.width, height: surface.frame.size.height + itemHeigth)
					}else{
						surface.frame.size.height -= itemHeigth
					}
					
				}
				
				
				
				if surface.frame.height < scrollView.frame.height{
					let h = scrollView.frame.height - 2
					let w = scrollView.frame.width - 2
					let delta = (h - surface.frame.height)
					
					surface.frame.size.height = h
					surface.frame.size.width = w
					
					scrollView.hasVerticalScroller = false
					//scrollView.verticalScrollElasticity = .none
					scrollView.verticalScrollElasticity = .automatic
					
					for item in surface.subviews{
						item.frame.size.width = w
						item.frame.origin.y += delta
					}
					
				}else{
					scrollView.hasVerticalScroller = true
					scrollView.verticalScrollElasticity = .automatic
					
				}
				
				textField.frame.origin = NSPoint(x: 5, y: surface.frame.size.height - fieldHeigth)
				textField.frame.size = NSSize(width: surface.frame.width - textField.frame.origin.x, height: fieldHeigth)
				textField.font = NSFont.systemFont(ofSize: 13)
				
				scrollView.documentView = surface
				
				
				
				#else
					break
				#endif
				*/
			case CustomizationViewController.SectionsID.eFIfolderReplacement:
				//efi replacement menu
				#if useEFIReplacement && !macOnlyMode
					
					let surface = EFIReplacementView.init(frame: NSRect(origin: CGPoint.zero, size: NSSize(width: scrollView.frame.size.width - 17, height: scrollView.frame.size.height - 2)))
				
					scrollView.documentView = surface
				
					surface.bootloader = bootLoaderType
					
					scrollView.verticalScrollElasticity = .none
				
					surface.draw(surface.frame)
					
				#else
				
					break
					
				#endif
			default:
				break
			}
			
			if let documentView = scrollView.documentView{
				documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
			}
			
		}
	}
}
