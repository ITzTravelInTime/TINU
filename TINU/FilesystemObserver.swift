//
//  FilesystemObserver.swift
//  TINU
//
//  Created by Pietro Caruso on 19/02/2019.
//  Copyright © 2019 Pietro Caruso. All rights reserved.
//

import Foundation

public class FileSystemObserver {
	
	private var fileHandle: CInt?
	private var eventSource: DispatchSourceProtocol?
	private var observingStarted: Bool = false
	
	private let path: String
	private let handler: () -> Void
	
	
	public var isObserving: Bool{
		return fileHandle != nil && eventSource != nil && observingStarted
	}
	
	deinit {
		
		stop()
		
	}
	
	public required init(path: String, changeHandler: @escaping ()->Void, startObservationNow: Bool = true) {
		assert(!path.isEmpty, "The filesystem object to observe must have a path!")
		self.path = path
		self.handler = changeHandler
		
		if startObservationNow{
			start()
		}
	}
	
	public convenience init(url: URL, changeHandler: @escaping ()->Void, startObservationNow: Bool = true) {
		self.init(path: url.path, changeHandler: { changeHandler() }, startObservationNow: startObservationNow)
	}
	
	
	public func stop() {
		self.eventSource?.cancel()
		if fileHandle != nil{
			close(fileHandle!)
		}
		
		self.eventSource = nil
		self.fileHandle = nil
		self.observingStarted = false
	}
	
	public func start() {
		
		if fileHandle != nil || eventSource != nil{
			stop()
		}
		
		self.fileHandle = open(path, O_EVTONLY)
		self.eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileHandle!, eventMask: .all, queue: DispatchQueue.global(qos: .utility))
		self.eventSource!.setEventHandler {
			self.handler()
		}
		self.eventSource!.resume()
		self.observingStarted = true
	}
	
}
