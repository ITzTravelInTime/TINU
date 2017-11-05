//
//  CreditsViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 08/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Foundation
import Cocoa

public class CreditsViewController: NSViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        if let w = self.window{
            w.close()
        }
    }
    
}
