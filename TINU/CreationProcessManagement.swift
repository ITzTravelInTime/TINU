//
//  CreationProcessManager.swift
//  TINU
//
//  Created by Pietro Caruso on 22/06/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation

extension CreationProcess{
	
	//TODO: put this into it's own file
	class Management {
		
		enum Status: UInt8, CaseIterable, Codable, Equatable{
			case configuration = 0
			case preCreation
			case creation
			case postCreation
			case doneSuccess
			case doneFailure
			
			func isBusy() -> Bool{
				return (self == .creation || self == .preCreation || self == .postCreation)
			}
		}
		
		public var status: Status = .configuration
		public var startTime = Date()
		public var handle: Command.Handle!
	}

}
