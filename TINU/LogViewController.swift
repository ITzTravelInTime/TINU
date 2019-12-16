//
//  LogViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//the view controller of the log window
class LogViewController: GenericViewController, NSSharingServicePickerDelegate, NSSharingServiceDelegate {
	
    @IBOutlet var text: NSTextView!
    @IBOutlet weak var scroller: NSScrollView!
    
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.view.superview?.wantsLayer = true
		self.view.wantsLayer = true
		
		text.font = NSFont(name: "Menlo", size: 12)
		
		/*
		if !(sharedIsOnRecovery || simulateDisableShadows){
			scroller.frame = CGRect.init(x: 0, y: scroller.frame.origin.y, width: self.view.frame.width, height: scroller.frame.height)
			scroller.borderType = .noBorder
			//scroller.drawsBackground = false
			
			setShadowViewsTopBottomOnly(respectTo: scroller, topBottomViewsShadowRadius: 5)
			setOtherViews(respectTo: scroller)
		}*/
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
		
		text.textColor = NSColor.textColor
		
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateLog(_:)), userInfo: nil, repeats: true)
    }
    
    func Close(_ sender: Any) {
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
    
    @objc public func copyLog(_ sender: Any) {
        let pasteBoard = NSPasteboard.general()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text.text as NSString])
		
		DispatchQueue.global(qos: .background).sync {
		let notification = NSUserNotification()
		
		notification.identifier = "org.tinu.TINU_LOG_COPY"
		
		notification.title = "Log copied"
		notification.informativeText = "TINU's log successfully copied to the clipboard"
		
		notification.hasActionButton = true
		notification.actionButtonTitle = "Ok"
		
		notification.soundName = NSUserNotificationDefaultSoundName
		
		NSUserNotificationCenter.default.deliver(notification)
		}
		
		print("Log copied to clipboard")
		
    }
    
    @objc public func saveLog(_ sender: Any) {
		let open = NSSavePanel()
		open.isExtensionHidden = false
		//open.showsHiddenFiles = true
		
		open.allowedFileTypes = ["txt"]
		
		/*if open.runModal() == NSModalResponseOK{
			if let u = open.url?.path{
				do{
					
					try text.text.write(toFile: u, atomically: true, encoding: .utf8)
					
				}catch let error{
					log(error.localizedDescription)
					msgBoxWarning("Error while saving the log file", "There was an error while saving the log file: \n\n" + error.localizedDescription)
				}
			}
		}*/
		
		open.beginSheetModal(for: self.window, completionHandler: { response in
			if response == NSModalResponseOK{
				if let u = open.url?.path{
					do{
						
						try self.text.text.write(toFile: u, atomically: true, encoding: .utf8)
						
					}catch let error{
						log(error.localizedDescription)
						msgBoxWarning("Error while saving the log file", "There was an error while saving the log file: \n\n" + error.localizedDescription)
					}
				}
			}
			
			})

    }
	
	@objc public func shareLog(_ sender: Any) {
		
		if let sen = sender as? NSView{
		
		let service = NSSharingServicePicker(items: [text.attributedString()])
		
		service.delegate = self
		
		service.show(relativeTo: sen.bounds, of: sen, preferredEdge: .minY)
			
		}
	}
	
	public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?){
		if let serv = service{
			serv.delegate = self
			
		}
	}
	
	public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate?{
		
		return self
	}
	
	func sharingService(_ sharingService: NSSharingService,
							   sourceWindowForShareItems items: [Any],
							   sharingContentScope: UnsafeMutablePointer<NSSharingService.SharingContentScope>) -> NSWindow?{
		return self.window
	}
}
