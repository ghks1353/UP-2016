//
//  ThemeData.swift
//  UP
//
//  Created by ExFl on 2017. 2. 11..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation

class ThemeData {
	
	/////// Key: LanguagesManager.LanguageCode
	/////// Value: Localized variables
	var name:[String:String] = [:]
	var description:[String:String] = [:]
	
	//////////////
	var themeCategory:ThemeManager.ThemeGroup = ThemeManager.ThemeGroup.Main
	
	var themeID:String = ""
	var themeBundleImageID:String = "" //optional
	var themeProductID:String = "" //optional
	
	var themeForceUnlocked:Bool = false
	var themeHidden:Bool = false
	
} //end class
