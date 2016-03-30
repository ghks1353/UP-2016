//
//  SkinManager.swift
//  UP
//
//  Created by ExFl on 2016. 3. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class SkinManager {
	
	static var skinPresetStr:String = "skin_";
	static var skinSelected:String = "default";
	static var skinList:Array<String> = [
		"default"
	];
	
	static func getAssetPresets() -> String {
		return skinPresetStr + skinSelected + "_";
	}
	static func getDefaultAssetPresets() -> String {
		//Default 고정
		return skinPresetStr + "default" + "_";

	}
	
}