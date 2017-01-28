//
//  SoundInfoObj.swift
//  UP
//
//  Created by ExFl on 2016. 2. 8..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class SoundInfoObj {
	
	init(soundName:String, fileName:String) {
		//Name from Language files
		soundLangName = LanguagesManager.$(soundName); soundFileName = fileName;
	}
	
	internal var soundLangName:String = "";
	internal var soundFileName:String = "";
	
}
