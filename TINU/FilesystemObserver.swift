/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2022 Pietro Caruso (ITzTravelInTime)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
