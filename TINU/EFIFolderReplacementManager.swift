/*
TINU, the open tool to create bootable macOS installers.
Copyright (C) 2017-2021 Pietro Caruso (ITzTravelInTime)

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


#if useEFIReplacement && !macOnlyMode
	
	public final class EFIFolderReplacementManager{
		
		static var shared: EFIFolderReplacementManager! { return sharedi }
		static var sharedi: EFIFolderReplacementManager! = nil
		
		private var sharedEFIFolderTempData: [String : Data?]! = nil
		private var firstDir = ""
		private let refData = Data.init()
		
		private var cProgress: Double!
		private var oDirectory: String!
		private var missingFile: String!
		
		public var openedDirectory: String!{
			return oDirectory
		}
		
		public var copyProcessProgress: Double!{
			return cProgress
		}
		
		public var filesCount: Double!{
			return Double(sharedEFIFolderTempData.count)
		}
		
		public var missingFileFromOpenedFolder: String!{
			return missingFile
		}
		
		public var currentEFIFolderType: SupportedEFIFolders{
			return bootloader
		}
		
		private var bootloader: SupportedEFIFolders = .clover
		
		private var contentToCheck: [[String]]{
			switch bootloader {
				case .clover:
					return [["/BOOT/BOOTX64.efi"], ["/CLOVER/CLOVERX64.efi"], ["/CLOVER/config.plist"], ["/CLOVER/kexts"], ["/CLOVER/kexts/Other"], ["/CLOVER/drivers64UEFI", "/CLOVER/drivers/UEFI", "/CLOVER/drivers/BIOS", "/CLOVER/drivers64"]]
				case .openCore:
					return [["/BOOT/BOOTX64.efi"], ["/OC/OpenCore.efi"], ["/OC/config.plist"], ["/OC/Kexts"], ["/OC/Tools"], ["/OC/Drivers"], ["/OC/ACPI"]]
			}
		}
		
		public func saveEFIFolder(toDisk disk: EFIPartition) -> Bool{
			
			if isUsingStoredEFIFolder{
				return false
			}
			
			guard let c = checkSavedEFIFolder() else {
				log("No EFI Folder saved, impossible to proceed")
				return false
			}
			
			if !c {
				log("Saved EFI Folder is invalid, impossible to proceed")
				return false
			}
			
			let fm = FileManager.default
			
			let unit = 1 / filesCount
			
			cProgress = 0
			
			var res = true
			
			guard var toPath = disk.rawValue.mountPoint() else{
				log("Can't get the efi paertition's mount point")
				return false
			}
			
			if !FileManager.default.fileExists(atPath: toPath){
				log("    The mount point of the EFI partition does not exist!!!")
				return false
			}
			
			log("    Mount point for the EFI partition \(disk.rawValue.rawValue) is: \(toPath)")
			
			toPath += "/EFI"
			
			log("    Trying to copy the saved EFI folder in \(toPath)")
			
			let cp = URL(fileURLWithPath: toPath, isDirectory: true)
			
			do{
				if fm.fileExists(atPath: toPath){
					try fm.removeItem(at: cp)
				}
			}catch let err{
				print("        EFI Folder delete error (\(toPath))\n                \(err.localizedDescription)")
				res = false
				
				cProgress = nil
				return false
			}
			
			isUsingStoredEFIFolder = true
			for f in sharedEFIFolderTempData{
				
				let file = URL(fileURLWithPath: cp.path + f.key)
				
				let parent = file.deletingLastPathComponent()
				
				print("        Replacing EFI Folder file: \(file.path)")
				
				do{
					if !fm.fileExists(atPath: parent.path){
						try fm.createDirectory(at: parent, withIntermediateDirectories: true)
						print("      Creating EFI Folder subdirectory: \(parent.path)")
					}
				}catch let err{
					log("        EFI Folder subfolder error (\(parent.path))\n                \(err.localizedDescription)")
					res = false
					continue
				}
				
				if f.value != refData{
					
					do{
						
						try f.value!.write(to: file)
						
					}catch let err{
						print("        EFI Folder file error (\(file.path))\n                \(err.localizedDescription)")
						res = false
						continue
					}
					
				}else{
					
					do{
						if !fm.fileExists(atPath: file.path) {
							try fm.createDirectory(at: file, withIntermediateDirectories: true)
							print("      Creating EFI Folder subdirectory: \(file.path)")
						}
						
					}catch let err{
						print("        EFI Folder subfolder creation error (\(file.path))\n                \(err.localizedDescription)")
						res = false
						continue
					}
					
				}
				
				
				
				cProgress! += unit
				
			}
			
			cProgress = nil
			isUsingStoredEFIFolder = false
			return res
		}
		
		private var isUsingStoredEFIFolder = false
		
		public func unloadEFIFolder(){
		
			if sharedEFIFolderTempData == nil{
				return
			}
			
			if isUsingStoredEFIFolder{
				return
			}
			
			isUsingStoredEFIFolder = true
				
			for i in sharedEFIFolderTempData.keys{
				//in some instances
				if sharedEFIFolderTempData == nil{
					break
				}
				
				print("Removing value from the saved EFI folder: \(i)")
				sharedEFIFolderTempData[i] = nil
				sharedEFIFolderTempData.removeValue(forKey: i)
			}
			
			sharedEFIFolderTempData.removeAll()
			sharedEFIFolderTempData = nil
			
			print("Saved EFI folder cleaned and reset")
			
			isUsingStoredEFIFolder = false
			oDirectory = nil
		}
		
		public func loadEFIFolder(_ fromPath: String, currentBootloader: SupportedEFIFolders) -> Bool!{
			
			if isUsingStoredEFIFolder{
				return nil
			}
			
			unloadEFIFolder()
			
			print("Try to read EFI folder: \(fromPath)")
			
			self.bootloader = currentBootloader
			
			let fm = FileManager.default
			
			//Requirements chack
			for c in contentToCheck{
				var exits = true
				
				for i in c{
					exits = exits || fm.fileExists(atPath: fromPath + i)
					missingFile = i
				}
				
				if !exits{
					log("EFI Folder does not contain this needed element: \(missingFile!)")
					return nil
				}
			}
			
			sharedEFIFolderTempData = [:]
			
			firstDir = fromPath
			
			if scanDir(fromPath){
				if let check = checkSavedEFIFolder(){
					if !check{
						unloadEFIFolder()
						return nil
					}
				}else{
					unloadEFIFolder()
					return false
				}
			}else{
				unloadEFIFolder()
				return false
			}
			
			oDirectory = fromPath
			
			print("EFI folder readed with success")
			
			//print(sharedEFIFolderTempData)
			
			return true
		}
		
		private func scanDir(_ dir: String) -> Bool{
			print("Scanning EFI Folder's Directory: \n    \(dir)")
			var r = true
			let fm = FileManager.default
			
			if isUsingStoredEFIFolder{
				return false
			}
			
			isUsingStoredEFIFolder = true
			
			var cont = [String]()
			
			do{
				cont = try fm.contentsOfDirectory(atPath: dir)
			}catch let error{
				print("Open efi fodler error: \(error.localizedDescription)")
				isUsingStoredEFIFolder = false
				return false
			}
			
			for d in cont{
				let file =  (dir + "/" + d)
				
				var id: ObjCBool = false;
				
				if !fm.fileExists(atPath: file, isDirectory: &id){ continue }
				
				var name = "/"
				
				if file != firstDir{
					//name = file.substring(from: firstDir.endIndex)
					name = String(file[firstDir.endIndex...])
				}
				
				print("        Item name: \(name)")
				
				let url = URL(fileURLWithPath: file, isDirectory: id.boolValue)
				
				if url.deletingLastPathComponent().path == firstDir{
					if id.boolValue{
						if url.lastPathComponent != "BOOT" && url.lastPathComponent != "CLOVER" && url.lastPathComponent != "OC"{
							continue
						}
					}else{
						continue
					}
				}
				
				if id.boolValue{
					print("        Item is directory, scanning it's contants")
					
					isUsingStoredEFIFolder = false
					r = scanDir(file)
					isUsingStoredEFIFolder = true
					
					sharedEFIFolderTempData[name] = refData
					
					print("Finished scanning EFI Folder's Directory on: \n    \(file)")
					continue
				}
				
				if url.lastPathComponent == ".DS_Store"{
					continue
				}
				
				print("        Item is file")
				
				do{
					sharedEFIFolderTempData[name] = try Data.init(contentsOf: URL(fileURLWithPath: file))
				}catch let error{
					print("Open efi fodler error: \(error.localizedDescription)")
					r = false
					break
				}
				
			}
			
			isUsingStoredEFIFolder = false
			return r
		}
		
		public func checkSavedEFIFolder() -> Bool!{
			if isUsingStoredEFIFolder{
				return nil
			}
			
			isUsingStoredEFIFolder = true
			
			print("Checking saved EFI folder")
			
			if sharedEFIFolderTempData == nil{
				print("No EFI folder saved")
				isUsingStoredEFIFolder = false
				return nil
			}
			
			if sharedEFIFolderTempData.isEmpty{
				print("Saved EFI folder is empty")
				isUsingStoredEFIFolder = false
				return false
			}
			
			var res = true
			
			for c in contentToCheck{
				for i in c{
					res = res || sharedEFIFolderTempData[i] == nil
					missingFile = i
				}
				
				if !res{
					res = false
					print("        Needed file missing from the saved EFI folder: " + missingFile)
				}
				
			}
			
			if res{
				print("Saved EFI folder checked and seems to be a proper EFI folder for the selected type")
				missingFile = nil
			}else{
				print("Saved EFI folder checked and does not seems to be a proper EFI folder for the selected type")
			}
			
			isUsingStoredEFIFolder = false
			return res
		}
		
		public func resetMissingFileFromOpenedFolder(){
			missingFile = nil
		}
		
		class func reset(){
			if sharedi != nil{
				sharedi.unloadEFIFolder()
			}
			sharedi = nil
			sharedi = EFIFolderReplacementManager()
		}
		
	}


#endif
