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

import AppKit
import Command
import TINUSerialization

public extension Diskutil{
	
	struct List: Codable, Equatable, FastCodable{
		
		public let AllDisks: [BSDID]
		private var AllDisksAndPartitions: [Disk]
		public let VolumesFromDisks: [String]
		public let WholeDisks: [BSDID]
		
		public var allDisksAndPartitions: [Disk]{
			return AllDisksAndPartitions
		}
		
		private var apfsContainersPool: [BSDID]!
		private var coreStorageContainersPool: [BSDID]!
		
		public static func getPlist() -> String?{
			return Diskutil.performCommand(withArgs: ["list", "-plist"])?.outputString()
		}
		
		public init?(){
			guard let list = List.readFromTerminal() else { return nil }
			self = list
		}
		
		private static func readFromTerminal() -> List?{
			
			log("Getting diskutil data to detect storage devices")
			
			guard let out = List.getPlist() else{
				print("Can't get diskutil data")
				return nil
			}
			
			if sharedEnableDebugPrints{
				print(out)
			}
			
			log("Got diskutil data? " + (!out.isEmpty ? "YES" : "NO") )
			
			if out.isEmpty{
				return nil
			}
			
			//let out = Command.getOut(cmd: "diskutil list -plist") ?? ""
			guard var new = Self.init(fromPlistSerialisedString: out) else{
				print("Diskutil data can't be decoded")
				return nil
			}
			
			print("Diskutil data decoded with success")
			
			new.apfsContainersPool = []
			new.coreStorageContainersPool = []
			
			for d in new.AllDisksAndPartitions where !d.isVolume(){
				
				if d.isAPFSContainer(){
					if !(d.APFSPhysicalStores != nil && new.apfsContainersPool != nil){
						continue
					}
					
					var removelist = [Int]()
					
					for p in 0..<new.apfsContainersPool.count where d.APFSPhysicalStores!.contains(APFSStore(DeviceIdentifier: new.apfsContainersPool[p])){
							
						removelist.append(p)
					}
					
					for r in removelist{
						new.apfsContainersPool.remove(at: r)
					}
					continue
				}
				
				for p in d.Partitions!{
					let u = p.content
					if u == .aPFSContainer{
						if new.apfsContainersPool == nil{
							new.apfsContainersPool = []
						}
						
						new.apfsContainersPool.append(p.DeviceIdentifier)
					}else if u == .coreStorageContainer{
						if new.coreStorageContainersPool == nil{
							new.coreStorageContainersPool = []
						}
						
						new.coreStorageContainersPool.append(p.DeviceIdentifier)
					}
				}
			}
			
			for i in 0..<new.AllDisksAndPartitions.count{
				var d = new.AllDisksAndPartitions[i]
				if d.isAPFSContainer(){
					if d.APFSPhysicalStores == nil{
						d.APFSPhysicalStores = [APFSStore(DeviceIdentifier: new.apfsContainersPool!.first!)]
						new.apfsContainersPool!.removeFirst()
					}
				}
				new.AllDisksAndPartitions[i] = d
			}
			
			log("diskutil data successfully decoded and interpreted")
			
			return new
		}
	}
	
}
