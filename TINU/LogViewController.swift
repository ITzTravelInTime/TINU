//
//  LogViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//the view controller of the log window
class LogViewController: GenericViewController {
    @IBOutlet var text: NSTextView!
    @IBOutlet weak var scroller: NSScrollView!
    
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidSetVibrantLook() {
        if canUseVibrantLook {
            scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
            scroller.borderType = .noBorder
            //scroller.drawsBackground = false
        }else{
            scroller.frame = CGRect.init(x: 20, y: scroller.frame.origin.y, width: self.view.frame.width - 40, height: scroller.frame.height)
            scroller.borderType = .bezelBorder
            //scroller.drawsBackground = true
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
        if timer.isValid{
            timer.invalidate()
        }
        
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
