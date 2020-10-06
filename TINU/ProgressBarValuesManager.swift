//
//  ProgressBarValuesManager.swift
//  TINU
//
//  Created by Pietro Caruso on 12/08/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

/*

Default values:

let pMaxVal: Double = 10000
let pMidDurationChunkCount: Double = 4
let pMidDurationChunkCountDiff: Double = 1
let pMaxMins: UInt64 = 50
let pMidMins: UInt64 = 20

//progress bar segments
let uDen: Double = 5

*/

//progressbar fine tuning
struct ProcessConsts: CodableDefaults, Codable, Equatable{
	
	/*

	functionality stuff
	
	*/
	
	//max value of the progressbar
	let pMaxVal: Double
	
	let pMidDurationChunkCount: Double
	let pMidDurationChunkCountDiff: Double
	
	//progress bar duration during the installer creation process
	let pMaxMins: UInt64
	let pMidMins: UInt64
	
	//progress number of bar segments
	let uDen: Double
	
	//progress bar durations
	var pMidDuration: Double{ return (pMaxVal * (1 - (2 / uDen))) }
	var pMidDurationChunk: Double{ return pMidDuration/pMidDurationChunkCount }
	var pExtDuration: Double{ return (pMaxVal / uDen) }
	var installerProgressValueSlow: Double { return (pMidDurationChunk) / (Double(pMaxMins - pMidMins) * 12) }
	var installerProgressValueFast: Double { return (pMidDurationChunk * (pMidDurationChunkCount - pMidDurationChunkCountDiff)) / (Double(pMidMins) * 12) }
	
	/*

	Initialization and check stuff

	*/
	
	//used to check if the instance of this structu is valid or not
	static func checkInstance(_ new: ProcessConsts) -> Bool{
		//Put the assertions about the values of the struct here
		
		if new.pMidDurationChunkCount <= new.pMidDurationChunkCountDiff{
			print("The number of chunks for this progress section can't be 0 or negative")
			return false
		}
		
		if new.pMaxMins <= new.pMidMins{
			print("pMaxMins can't be smaller or equal to pMidMins")
			return false
		}
		
		if new.uDen < 3{
			print("uDen can't be less than 3")
			return false
		}
		
		return true
	}
	/*
	//assumes the urls refers to a .json file
	static func createFrom(fileURL: URL, shouldWrite: Bool = true) -> ProcessConsts!{
		do{
			if FileManager.default.fileExists(atPath: fileURL.path){
				if fileURL.pathExtension == defaultResourceFileExtension{
					let data = try String.init(contentsOf: fileURL).data(using: .utf8)!
					let new = try JSONDecoder().decode(ProcessConsts.self, from: data)
					
					print(new)
					
					if !checkInstance(new){
						return nil
					}
					
					return new
				}
			}else{
				if shouldWrite{
					do{
						
						let defaultInit = ProcessConsts()
						
						let encoder = JSONEncoder()
						encoder.outputFormatting = .prettyPrinted
						let data = (try encoder.encode(defaultInit))
						let str = String(data: data, encoding: .utf8)!
						
						try str.write(to: fileURL, atomically: true, encoding: .utf8)
						
						return defaultInit
						
					}catch let err{
						print(err)
					}
				}
			}
			
		}catch let err{
			print(err)
		}
		
		return nil
	}
	
	//assumes the file string is a file path for a .json file
	static func createFrom(file: String, shouldWrite: Bool = true) -> ProcessConsts!{
		return createFrom(fileURL: URL(fileURLWithPath: file, isDirectory: false), shouldWrite: shouldWrite)
	}
	
	internal static let defaultResourceFileName = "ProgressBarSettings"
	internal static let defaultResourceFileExtension = "json"
	internal static var defaultFilePath: String { return (Bundle.main.resourceURL!.path + "/" + ProcessConsts.defaultResourceFileName + "." + ProcessConsts.defaultResourceFileExtension)}
	internal static var defaultFileURL: URL { return URL(fileURLWithPath: defaultFilePath, isDirectory: false)}
	
	static func createFromDefaultFile() -> ProcessConsts!{
		return createFrom(fileURL: defaultFileURL)
	}
*/
	
	static let defaultResourceFileName = "ProgressBarSettings"
	static let defaultResourceFileExtension = "json"
	
}

/*
extension ProcessConsts{
	
	init() {
		self.init(pMaxVal: 10000, pMidDurationChunkCount: 3, pMidDurationChunkCountDiff: 1, pMaxMins: 50, pMidMins: 15, uDen: 5)
	}
	
	init(from: ProcessConsts) {
		self.init()
		self = from
	}
	
	func copy() -> ProcessConsts{
		return ProcessConsts(from: self)
	}
}*/
