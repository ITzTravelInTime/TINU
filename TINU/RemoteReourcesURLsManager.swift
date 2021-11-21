//
//  RemoteLinksManager.swift
//  TINU
//
//  Created by Pietro Caruso on 21/11/21.
//  Copyright © 2021 Pietro Caruso. All rights reserved.
//

import Foundation
import TINUSerialization
import TINURecovery

public final class RemoteResourcesURLsManager{
	private final class Inner: SimulatableDetectableOneTime{
		static var simulatedStatus: [String : String]?{
			return nil
		}
		
		static func calculateStatus() -> [String: String] {
			struct RemoteResources: Codable, Equatable{
				let urls: [String: String]
			}
			
			guard let file = Bundle.main.path(forResource: "RemoteURLs", ofType: "json") else{
				return [:]
			}
			
			guard let list = RemoteResources(fromFileAtPath: file)?.urls else{
				return [:]
			}
			
			return list
		}
		
		init(){}
		
		static var storedStatus: [String: String]?
		
		
	}
	
	public static var list: [String: String]{
		return Inner.status
	}
	
}

