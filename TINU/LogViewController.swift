//
//  LogViewController.swift
//  TINU
//
//  Created by ITzTravelInTime on 19/09/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

//the view controller of the log window
class LogViewController: GenericViewController, NSSharingServicePickerDelegate, NSSharingServiceDelegate, ViewID {
	let id: String = "LogViewController"
    @IBOutlet var content: NSTextView!
    @IBOutlet weak var scroller: NSScrollView!
    
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.view.superview?.wantsLayer = true
		self.view.wantsLayer = true
		
		content.font = NSFont(name: "Menlo", size: 12)
		
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
		
		content.textColor = NSColor.textColor
		
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateLog(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear() {
		
        super.viewWillDisappear()
        if timer.isValid{
            timer.invalidate()
        }
        
    }
    
	@objc func updateLog(_ sender: AnyObject){
        //print("Log updated")
        if let l = LogManager.readLog(){
            content.text = l
        }
    }
    
    @objc public func copyLog(_ sender: Any) {
		
		let text = self.content.text as NSString
		
		DispatchQueue.global(qos: .background).async {
			
			let pasteBoard = NSPasteboard.general
			pasteBoard.clearContents()
			pasteBoard.writeObjects([text])
			
			let _ = NotificationsManager.sendWith(id: "copyLog", image: nil)
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
			if response == NSApplication.ModalResponse.OK{
				if let u = open.url?.path{
					//read ui stuff just from the main thread
					let text = self.content.text
					DispatchQueue.global(qos: .userInteractive).async {
					do{
						
						try text.write(toFile: u, atomically: true, encoding: .utf8)
						
					}catch let error{
						log(error.localizedDescription)
						//msgBoxWarning("Error while saving the log file", "There was an error while saving the log file: \n\n" + error.localizedDescription)
						msgboxWithManager(self, name: "saveError", parseList: ["{desc}" : error.localizedDescription])
					}
					}
				}
			}
			
			})
		

    }
	
	@objc public func shareLog(_ sender: Any) {
		
		print("Share called")
		
		
		if let sen = sender as? NSView{
			
			print("Share good")
		
			let service = NSSharingServicePicker(items: [content.attributedString()])
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
