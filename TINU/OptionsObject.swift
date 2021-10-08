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

extension CreationProcess.OptionsManager{
	//other options
	public struct Object{
		let id: ID
		let description: Description
		
		/**Determinates if the option will be executed or not*/
		var isActivated = false
		/**Determinates if the option needs to be shown to the user*/
		var isVisible = true
		/**Determinates if the option needs to be modifiable by the user if it's shown*/
		var isUsable = true
		/**Determinates if the option needs to be disaplyed into the advanced options section*/
		var isAdvanced = false
		
		func canBeUsed(_ referenceID: ID) -> Bool{
			return (id == referenceID) && isActivated && isVisible
		}
		
		func canBeUsed() -> Bool{
			return isActivated && isVisible
		}
		
		func copy() -> Object{
			return Object(from: self)
		}
	}
	
}

extension CreationProcess.OptionsManager.Object{
	init(from other: CreationProcess.OptionsManager.Object) {
		self.init(id: other.id, description: other.description)
		
		self = other
		
		//self.init(id: other.id, title: other.title, isActivated: other.isActivated, isVisible: other.isVisible, isUsable: other.isUsable, isAdvanced: other.isActivated, description: other.description)
	}
}
