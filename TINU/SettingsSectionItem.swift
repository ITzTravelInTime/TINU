//
//  File.swift
//  TINU
//
//  Created by Pietro Caruso on 11/02/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class SettingsSectionItem: NSView{
	
	static var surface: NSView!
	
	var image = NSImageView()
	var name = NSTextField()
	
	var isSelected = false
	
	var id = OtherOptionsViewController.SectionsID(rawValue: 0)!
	
	var itemsScrollView: NSScrollView?
	
	let normalColor = NSColor.transparent.cgColor
	var selectedColor = NSColor.selectedControlColor.cgColor
	
	override public func draw(_ dirtyRect: NSRect) {
		
		/*
		if isSelected{
			self.backgroundColor = NSColor.selectedControlColor
		}else{
			self.backgroundColor = NSColor.transparent
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
		
		guard let scrollView = itemsScrollView else { return }
		
		scrollView.documentView = NSView()
		
		scrollView.verticalScroller?.isHidden = false
		SettingsSectionItem.surface = NSView()
		
		switch id{
		case OtherOptionsViewController.SectionsID.generalOptions, OtherOptionsViewController.SectionsID.advancedOptions:
			let isAdvanced = (id == OtherOptionsViewController.SectionsID.advancedOptions)
			let itemHeigth: CGFloat = 30
			var isGray = true
			
			SettingsSectionItem.surface.frame.origin = CGPoint.zero
			SettingsSectionItem.surface.frame.size = NSSize.init(width: scrollView.frame.size.width - 20, height: itemHeigth * (CGFloat(oom.shared.otherOptions.count)))
			
			var count: CGFloat = 0
			
			for i in oom.shared.otherOptions.sorted(by: { $0.0.rawValue > $1.0.rawValue }){
				if !(i.value.isVisible && (i.value.isAdvanced == isAdvanced)){
					SettingsSectionItem.surface.frame.size.height -= itemHeigth
					continue
				}
				
				let item = OtherOptionsCheckBox(frame: NSRect(x: 0, y: count, width: SettingsSectionItem.surface.frame.size.width, height: itemHeigth))
				
				item.option = i.value
				
				isGray = !isGray
				
				count += itemHeigth
				
				SettingsSectionItem.surface.addSubview(item)
				
				//surface.frame.size = CGSize(width: surface.frame.size.width, height: surface.frame.size.height + itemHeigth)
				
			}
			
			if SettingsSectionItem.surface.frame.height < scrollView.frame.height{
				let h = scrollView.frame.height - 2
				let w = scrollView.frame.width - 2
				let delta = (h - SettingsSectionItem.surface.frame.height)
				
				SettingsSectionItem.surface.frame.size.height = h
				SettingsSectionItem.surface.frame.size.width = w
				scrollView.hasVerticalScroller = false
				//scrollView.verticalScrollElasticity = .none
				scrollView.verticalScrollElasticity = .automatic
				
				for item in SettingsSectionItem.surface.subviews{
					item.frame.size.width = w
					item.frame.origin.y += delta
				}
			}else{
				scrollView.hasVerticalScroller = true
				scrollView.verticalScrollElasticity = .automatic
			}
			
			scrollView.documentView = SettingsSectionItem.surface
			
		case OtherOptionsViewController.SectionsID.eFIFolderReplacementClover, OtherOptionsViewController.SectionsID.eFIFolderReplacementOpenCore:
			//efi replacement menu
			#if useEFIReplacement && !macOnlyMode
			SettingsSectionItem.surface = EFIReplacementView.init(frame: NSRect(origin: CGPoint.zero, size: NSSize(width: scrollView.frame.size.width - 17, height: scrollView.frame.size.height - 2))) as NSView
			
			scrollView.documentView = SettingsSectionItem.surface
			
			switch id{
			case OtherOptionsViewController.SectionsID.eFIFolderReplacementClover:
				(SettingsSectionItem.surface as? EFIReplacementView)!.bootloader = .clover
				break
			case OtherOptionsViewController.SectionsID.eFIFolderReplacementOpenCore:
				(SettingsSectionItem.surface as? EFIReplacementView)!.bootloader = .openCore
				break
			default:
				break
			}
			
			scrollView.verticalScrollElasticity = .none
			
			#else
			
			break
			
			#endif
		default:
			break
		}
		
		SettingsSectionItem.surface.draw(SettingsSectionItem.surface.frame)
		
		if let documentView = scrollView.documentView{
			documentView.scroll(NSPoint.init(x: 0, y: documentView.bounds.size.height))
		}
	}
}
