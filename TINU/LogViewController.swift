//
//  LogViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController {
    @IBOutlet weak var background: NSVisualEffectView!

    @IBOutlet var text: NSTextView!
    
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if sharedIsOnRecovery || !sharedUseVibrant {
            background.isHidden = true
        }
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateLog(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func Close(_ sender: Any) {
        timer.invalidate()
        self.window.close()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        timer.invalidate()
    }
    
    @objc func updateLog(_ sender: AnyObject){
        //print("Log updated")
        if let l = readLog(){
            text.text = l
        }
    }
    
    @IBAction func copyLog(_ sender: Any) {
        let pasteBoard = NSPasteboard.general()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text.text as NSString])
    }
}
