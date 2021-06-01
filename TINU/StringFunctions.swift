//
//  StringFunctions.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import AppKit

public func parse(messange: String, keys: [String: String]) -> String{
	var ret = ""
	for piece in messange.split(separator: "$"){
		var s = String(piece)
		
		for key in keys{
			if s.starts(with: key.key){
				s.deletePrefix(key.key)
				s = key.value + s
				break
			}
		}
		
		ret += s
	}
	
	return ret
}

public func strFill(of section: String, length: UInt, startSeq: String! = nil, endSeq: String! = nil, forget: Bool = false) -> String{
	struct FillData: Equatable, Hashable{
		let section: String
		let length: UInt
		let startSeq: String!
		let endSeq: String!
		
		static var fills: [FillData: String] = [:]
	}
	
	let key = FillData(section: section, length: length, startSeq: startSeq, endSeq: endSeq)
	
	if let fill = FillData.fills[key]{
		if forget{
			FillData.fills[key] = nil
		}
		return fill
	}
	
	var tmp = startSeq ?? ""
	
	for _ in 0..<(length){
		tmp += section
	}
	
	tmp += (endSeq ?? "")
	
	if !forget{
		FillData.fills[key] = tmp
	}
	
	print(FillData.fills)
	
	return tmp
}
