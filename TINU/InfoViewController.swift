//
//  InfoViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 24/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//the first screen of the app, it has just some labels and a button
class InfoViewController: GenericViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        sharedStoryboard = self.storyboard
    }

    @IBAction func ok(_ sender: Any) {
        if showLicense{
            let _ = openSubstituteWindow(windowStoryboardID: "License", sender: self)
        }else{
            let _ = openSubstituteWindow(windowStoryboardID: "ChoseDrive", sender: self)
        }
    }

}
