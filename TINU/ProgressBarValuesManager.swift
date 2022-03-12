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

/*
 
 Default values:
 
 let pMaxVal: Double = 10000
 let pMidDurationChunkCount: Double = 4
 let pMidDurationChunkCountDiff: Double = 1
 let pMaxMins: UInt64 = 50
 let pMidMins: UInt64 = 20
 
 //progress bar segments
 let uDen: Double = 5
 
 */

extension UIManager{
	
	//progressbar fine tuning, DO NOT RENAME STUFF
	struct ProcessProgressBarSettings: CodableDefaults, Codable, Equatable{
		
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
		static func checkInstance(_ new: ProcessProgressBarSettings) -> Bool{
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
		
		static let defaultResourceFileName = "ProgressBarSettings"
		static let defaultResourceFileExtension = "json"
		
	}
	
}
