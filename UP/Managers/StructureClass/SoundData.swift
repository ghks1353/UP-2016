//
//  SoundInfoObj.swift
//  UP
//
//  Created by ExFl on 2016. 2. 8..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class SoundData {
	
	init(soundName:String, fileName:String) {
		//Name from Language files
		soundLangName = LanguagesManager.$(soundName)
		soundFileName = fileName
	}
	
	var soundLangName:String = ""
	var soundFileName:String = ""
	
	/// if sound is custom sound, use this variable
	var soundURL:URL?
	
}
