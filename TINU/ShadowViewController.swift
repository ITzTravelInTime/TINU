//
//  ShadowViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/09/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

public class ShadowViewController: AppViewController{
	let startZpos: CGFloat = 30
	
	var topView = ShadowPanel()
	var bottomView = ShadowPanel()
	
	var leftView = ShadowPanel()
	var rightView = ShadowPanel()
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.superview?.wantsLayer = true
		self.view.wantsLayer = true
	}
	
	func setShadowViewsAll(respectTo refView: NSView, topBottomViewsShadowRadius: CGFloat, sideViewsShadowRadius: CGFloat){
		if refView.layer == nil{
			refView.layer?.zPosition = startZpos
		}
		
		topView = ShadowPanel(frame: NSRect(x: 0, y: refView.frame.size.height + refView.frame.origin.y, width: self.view.frame.width, height: self.view.frame.size.height - (refView.frame.size.height + refView.frame.origin.y)))
		topView.customShadowRadius = topBottomViewsShadowRadius
		topView.useShadow = true
		topView.layer?.zPosition = startZpos + 1
		
		topView.autoresizingMask = [.viewWidthSizable, .viewMinYMargin, .viewMinXMargin, .viewMaxXMargin]
		
		self.view.addSubview(topView)
		
		bottomView = ShadowPanel(frame: NSRect(x: 0, y: 0, width: self.view.frame.width, height: refView.frame.origin.y))
		bottomView.customShadowRadius = topBottomViewsShadowRadius
		bottomView.useShadow = true
		bottomView.layer?.zPosition = startZpos + 1
		
		bottomView.autoresizingMask = [.viewWidthSizable]
		
		self.view.addSubview(bottomView)
		
		leftView = ShadowPanel(frame: NSRect(x: -10, y: refView.frame.origin.y, width: 10, height: refView.frame.size.height))
		leftView.customShadowRadius = sideViewsShadowRadius
		leftView.useShadow = true
		leftView.layer?.zPosition = startZpos + 1
		
		self.view.addSubview(leftView)
		
		rightView = ShadowPanel(frame: NSRect(x: refView.frame.size.width, y: refView.frame.origin.y, width: 10, height: refView.frame.size.height))
		rightView.customShadowRadius = sideViewsShadowRadius
		rightView.useShadow = true
		rightView.layer?.zPosition = startZpos + 1
		
		self.view.addSubview(rightView)
	}
	
	func setShadowViewsSidesOnly(respectTo refView: NSView, sideViewsShadowRadius: CGFloat){
		if refView.layer == nil{
			refView.layer?.zPosition = startZpos
		}
		
		leftView = ShadowPanel(frame: NSRect(x: -10, y: refView.frame.origin.y, width: 10, height: refView.frame.size.height))
		leftView.customShadowRadius = sideViewsShadowRadius
		leftView.useShadow = true
		leftView.layer?.zPosition = startZpos + 1
		
		self.view.addSubview(leftView)
		
		rightView = ShadowPanel(frame: NSRect(x: refView.frame.size.width, y: refView.frame.origin.y, width: 10, height: refView.frame.size.height))
		rightView.customShadowRadius = sideViewsShadowRadius
		rightView.useShadow = true
		rightView.layer?.zPosition = startZpos + 1
		
		self.view.addSubview(rightView)
	}
	
	func setOtherViews(respectTo refView: NSView){
		if refView.layer == nil{
			refView.layer?.zPosition = startZpos
		}
		
		for v in self.view.subviews{
			if v != refView && v != bottomView && v != topView{
				v.wantsLayer = true
				v.layer?.zPosition = startZpos + 2
			}
		}
		
	}
	
	func setShadowViewsTopBottomOnly(respectTo refView: NSView, topBottomViewsShadowRadius: CGFloat){
		if refView.layer == nil{
			refView.wantsLayer = true
			refView.layer?.zPosition = startZpos
		}
		
		topView = ShadowPanel(frame: NSRect(x: 0, y: refView.frame.size.height + refView.frame.origin.y, width: self.view.frame.width, height: self.view.frame.size.height - (refView.frame.size.height + refView.frame.origin.y)))
		topView.customShadowRadius = topBottomViewsShadowRadius
		topView.useShadow = true
		topView.layer?.zPosition = startZpos + 1
		
		topView.autoresizingMask = [.viewWidthSizable, .viewMinYMargin, .viewMinXMargin, .viewMaxXMargin]
		
		/*
		NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
		NSLayoutConstraint(item: topView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
		NSLayoutConstraint(item: topView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: ., multiplier: 1.0, constant: 0.0).isActive = true*/
		
		self.view.addSubview(topView)
		
		bottomView = ShadowPanel(frame: NSRect(x: 0, y: 0, width: self.view.frame.width, height: refView.frame.origin.y))
		bottomView.customShadowRadius = topBottomViewsShadowRadius
		bottomView.useShadow = true
		bottomView.layer?.zPosition = startZpos + 1
		
		bottomView.autoresizingMask = [.viewWidthSizable] 
		
		/*NSLayoutConstraint(item: bottomView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
		NSLayoutConstraint(item: bottomView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
		NSLayoutConstraint(item: bottomView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
		*/
		self.view.addSubview(bottomView)
	}
}
