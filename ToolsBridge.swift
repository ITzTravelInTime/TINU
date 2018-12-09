//
//  ToolsBridge.swift
//  TINU
//
//  Created by Pietro Caruso on 08/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if TINU && !isTool
	public typealias AppViewController   =  GenericViewController
	public typealias AppWindowController =  GenericWindowController
#elseif EFIPM
	public typealias AppViewController   =  ShadowViewController
	public typealias AppWindowController =  NSWindowController
#else
	public typealias AppViewController   =  NSViewController
	public typealias AppWindowController =  NSWindowController
#endif

#if isTool
public var defaults = UserDefaults.init()

public var simulateRecovery = false

public var simulateUseScriptAuth = true

public var toolMainViewController: NSViewController!
#endif

#if EFIPM

public var startsAsMenu = true

#endif
