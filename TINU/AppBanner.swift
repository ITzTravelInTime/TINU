//
//  AppBanner.swift
//  TINU
//
//  Created by Pietro Caruso on 28/09/2020.
//  Copyright © 2020 Pietro Caruso. All rights reserved.
//

import Foundation

public final class AppBanner{
	
	private static let sideBorder = "\u{2551}"
	private static let topBorder = "\u{2550}"
	
	private static let margin: UInt64 = 4
	
	private static var width: UInt64{
		struct MEM{
			static var w: UInt64 = 0
		}
		
		if MEM.w > 0{
			return MEM.w
		}
		
		var max: UInt64 = 0
		
		for c in bannerContents{
			let cc = UInt64(c.count)
			if cc > max{
				max = cc
			}
		}
		
		MEM.w = max
		
		return max
	}
	
	/*
	public static let banner = "\n" + """
	\(getRow(isUP: true))
	\u{2551}                                         \u{2551}
	\u{2551}         _/_ o                           \u{2551}
	\u{2551}         /  , _ _   ,  ,                 \u{2551}
	\u{2551}        (__(_( ( (_/(_/(__               \u{2551}
	\u{2551}        Version: \(getSpaces())\u{2551}
	\u{2551}                                         \u{2551}
	\u{2551}        Made with love using:            \u{2551}
	\u{2551}          __,                            \u{2551}
	\u{2551}         (           o  /) _/_           \u{2551}
	\u{2551}          `.  , , , ,  //  /             \u{2551}
	\u{2551}        (___)(_(_/_(_ //_ (__            \u{2551}
	\u{2551}                     /)                  \u{2551}
	\u{2551}                    (/                   \u{2551}
	\u{2551}                                         \u{2551}
	\(getRow(isUP: false))
	""" + "\n"
	*/
	
	//private static var cBanner = ""
	public static var banner: String{
		struct MEM{
			static var cBanner: String = ""
		}
		
		if !MEM.cBanner.isEmpty{
			return MEM.cBanner
		}
		
		let empty = getEmptyRow()
		let vfill = strFill(of: empty, length: margin / 2, startSeq: nil, endSeq: nil, forget: true)
		let m = strFill(of: " ", length: margin, startSeq: nil, endSeq: nil, forget: true)
		
		MEM.cBanner += getRow(true) + vfill
		
		for c in bannerContents{
			if c.isEmpty{
				MEM.cBanner += empty
				continue
			}
			
			let len = (width - UInt64(c.count))
			
			MEM.cBanner += sideBorder + m + c + strFill(of: " ", length: len, startSeq: nil, endSeq: nil, forget: true) + m + sideBorder + "\n"
		}
		
		MEM.cBanner += vfill + getRow(false)
		
		return MEM.cBanner
	}
	
	private static let bannerContents: [String] = [
		" _/_ o",
		" /  , _ _   ,  ,",
		"(__(_( ( (_/(_/(__",
		"Version: \(Bundle.main.version!)",
		"Build:   \(Bundle.main.build!)",
		"",
		"Made with love using:",
		"  __,",
		" (           o  /) _/_",
		"  `.  , , , ,  //  /",
		"(___)(_(_/_(_ //_ (__",
		"             /)",
		"            (/"
	]
	
	private static func getRow(_ isUP: Bool) -> String{
		let length = width + margin * 2
		
		/*
		
		var res = "\u{2554}"
		
		if !isUP{
		res = "\u{255A}"
		}
		
		for _ in 0..<(length){
		res += topBorder
		}
		
		if isUP{
		res += "\u{2557}"
		}else{
		res += "\u{255D}"
		}
		
		return res + "\n"
		*/
		
		if isUP{
			return strFill(of: topBorder, length: length, startSeq: "\u{2554}", endSeq: "\u{2557}\n", forget: true)
		}
		
		return strFill(of: topBorder, length: length, startSeq: "\u{255A}", endSeq: "\u{255D}\n", forget: true)
	}
	
	private static func getEmptyRow() -> String{
		/*
		struct MEM{
		static var emptyRow = ""
		}
		let length = width + margin * 2
		if !MEM.emptyRow.isEmpty{
		return MEM.emptyRow
		}
		
		MEM.emptyRow += sideBorder
		
		for _ in 0..<(length){
		MEM.emptyRow += " "
		}
		
		MEM.emptyRow += sideBorder + "\r"
		
		return MEM.emptyRow*/
		
		return strFill(of: " ", length: width + margin * 2, startSeq: sideBorder, endSeq: sideBorder + "\r", forget: true)
	}
	
}
