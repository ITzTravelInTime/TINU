//
//  EFIFolderReplacementManager.swift
//  TINU
//
//  Created by Pietro Caruso on 26/05/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Foundation


#if useEFIReplacement && !macOnlyMode
	
	final class EFIFolderReplacementManager{
		
		static let shared = EFIFolderReplacementManager()
		
		private var sharedEFIFolderTempData: [String:Data?]!
		
		private let fm = FileManager.default
		
		private var firstDir = ""
		
		private let refData = "Directory".data(using: .utf8)
		
		private var cProgress: Double!
		
		private var oDirectory: String!
		
		private var missingFile: String!
		
		public var openedDirectory: String!{
			get{
				return oDirectory
			}
		}
		
		public var copyProcessProgress: Double!{
			get{
				return cProgress
			}
		}
		
		public var filesCount: Double!{
			get{
				return Double(sharedEFIFolderTempData.count)
			}
		}
		
		public var missingFileFromOpenedFolder: String!{
			get{
				return missingFile
			}
		}
		
		private let contentToCheck = ["/BOOT/BOOTX64.efi", "/CLOVER/CLOVERX64.efi", "/CLOVER/config.plist", "/CLOVER/kexts", "/CLOVER/kexts/Other", "/CLOVER/drivers64UEFI" /*, "/CLOVER/drivers64"*/ ]
		
		public func saveEFIFolder(_ toPath: String) -> Bool{
			if let c = checkSavedEFIFolder(){
				if c{
					
					let unit = 1 / filesCount
					
					cProgress = 0
					
					var res = true
					
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
					
					for f in sharedEFIFolderTempData{
						
						let file = URL(fileURLWithPath: cp.path + f.key)
						
						let parent = file.deletingLastPathComponent()
						
						print("        Replacing EFI Folder file: \(file.path)")
						
						do{
							if !fm.fileExists(atPath: parent.path){
								try fm.createDirectory(at: parent, withIntermediateDirectories: true, attributes: [:])
								print("      Creating EFI Folder subdirectory: \(parent.path)")
							}
						}catch let err{
							log("        EFI Folder subfolder error (\(parent.path))\n                \(err.localizedDescription)")
							res = false
							continue
						}
						
						do{
							
							if f.value != refData{
							
								try f.value?.write(to: file)
								
							}else{
								
								do{
									if !fm.fileExists(atPath: file.path) {
										try fm.createDirectory(at: file, withIntermediateDirectories: true, attributes: [:])
										print("      Creating EFI Folder subdirectory: \(parent.path)")
									}
									
								}catch let err{
									print("        EFI Folder subfolder creation error (\(parent.path))\n                \(err.localizedDescription)")
									res = false
									continue
								}
								
							}
							
						}catch let err{
							print("        EFI Folder file error (\(file.path))\n                \(err.localizedDescription)")
							res = false
							continue
						}
						
						cProgress! += unit
						
					}
					
					cProgress = nil
					return res
				}
			}else{
				print("No EFI Folder saved, impossible to proceed")
			}
			
			return false
		}
		
		public func unloadEFIFolder() -> Bool{
		
			if sharedEFIFolderTempData != nil{
				for var f in sharedEFIFolderTempData{
					if var data = sharedEFIFolderTempData[f.key]{
						print("Removing value from the saved EFI folder: \(f.key)")
						
						data?.removeAll()
						data = nil
					}
					
					sharedEFIFolderTempData.removeValue(forKey: f.key)
					
					f.key = ""
				}
				
				sharedEFIFolderTempData.removeAll()
				sharedEFIFolderTempData = nil
				
				print("Saved EFI folder cleaned and reset")
				
				oDirectory = nil
			}
			
			return true
			
		}
		
		public func loadEFIFolder(_ fromPath: String) -> Bool!{
			Swift.print("Try to read EFI folder: \(fromPath)")
			
			let _ = unloadEFIFolder()
			
			for c in contentToCheck{
				if !fm.fileExists(atPath: fromPath + c){
					print("Folder does not contain this needed file: \(c)")
					missingFile = c
					return nil
				}
			}
			
			sharedEFIFolderTempData = [:]
			
			firstDir = fromPath
			
			if scanDir(fromPath){
				if let check = checkSavedEFIFolder(){
					if !check{
						let _ = unloadEFIFolder()
						return nil
					}
				}else{
					let _ = unloadEFIFolder()
					return false
				}
			}else{
				let _ = unloadEFIFolder()
				return false
			}
			
			oDirectory = fromPath
			
			Swift.print("EFI folder readed with success")
			
			//print(sharedEFIFolderTempData)
			
			return true
		}
		
		private func scanDir(_ dir: String) -> Bool{
			Swift.print("Scanning EFI Folder's Directory: \(dir)")
			var r = true
			
			do{
				let cont = try fm.contentsOfDirectory(atPath: dir)
				
				for d in cont{
					let file =  (dir + "/" + d)
					
					var id: ObjCBool = false;
					
					if fm.fileExists(atPath: file, isDirectory: &id){
						var name = "/"
						
						if file != firstDir{
							name = file.substring(from: firstDir.endIndex)
						}
						
						let url = URL(fileURLWithPath: name, isDirectory: false)
						
						if id.boolValue{
							
							if url.deletingLastPathComponent().path == firstDir{
								if url.lastPathComponent != "BOOT" && url.lastPathComponent != "CLOVER"{
									continue
								}
							}
							
							r = scanDir(file)
							
							sharedEFIFolderTempData[name] = refData
							
							Swift.print("Finished scanning EFI Folder's Directory on: \(file)")
						}else{
							
							//todo: scan efi folder to check it, return nil in case it's a not usable directory
							
							//Swift.print("		File ID: " + file)
							
							if url.lastPathComponent == ".DS_Store"{
								continue
							}
							
							Swift.print("        File ID: " + name)
							
							sharedEFIFolderTempData[name] = try Data.init(contentsOf: URL(fileURLWithPath: file))
						}
					}
					
				}
				
				
			}catch let error{
				Swift.print("Open efi fodler error: \(error.localizedDescription)")
				r = false
			}
			
			return r
		}
		
		public func checkSavedEFIFolder() -> Bool!{
			print("Checking saved EFI folder")
			
			if sharedEFIFolderTempData == nil{
				print("No clover EFI folder saved")
				return nil
			}
			
			if sharedEFIFolderTempData.isEmpty{
				print("Saved clover EFI folder is empty")
				return false
			}
			
			var res = true
			
			for c in contentToCheck{
				if sharedEFIFolderTempData[c] == nil{
					print("        Needed file missing from the saved clover EFI folder: " + c)
					missingFile = c
					res = false
				}
			}
			
			if res{
				print("Saved clover EFI folder checked and seems to be a proper clover EFI folder")
			}else{
				print("Saved clover EFI folder checked and does not seems to be a proper clover EFI folder")
			}
			
			return res
		}
		
		public func resetMissingFileFromOpenedFolder(){
			missingFile = nil
		}
		
	}


#endif
